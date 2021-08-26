GETPOPLOG_VERSION:=$(shell cat VERSION)
MAJOR_VERSION?=16

################################################################################
# Build targets
################################################################################
# The build process involves quite a lot of compilation and linking in-place, unfortunately.
# So this Makefile is driven by the creation of 'proxy files' in the _build folder. Each proxy
# files stands for the completion of a major phase of the build process.
#
# Proxy files:
#
#     _build/Base.proxy
#         This file is a script that represents the successful copying of the Base system
#         after its own Makefile has been successfully run.
#
#     _build/Stage1.proxy
#         This file represents that the system-tools (popc, poplink, poplibr) are now
#         working and have been used to build a fresh corepop, which is in
#         _build/poplog_base/pop/pop/newpop11 and moved to corepop.
#
#     _build/Newpop.proxy
#         After Stage1, we need to get the critical newpop command working on top of
#         the fresh corepop we just built. This file signals that it has been built
#         successfully.
#
#     _build/Stage2.proxy
#         This file represents a complete rebuilt Poplog system using the newpop
#         command and the full set of object files. It includes:
#             - basepop11 and all links to it in $popsys
#             - all system images (prolog.psv, clisp.psv etc).
#         It does not include documentation or Aaron Sloman's packages extension.
#         And by implication it does not include the doc indexes.
#
#     _build/Packages.proxy
#         This represents the addition of the additional packages library
#         curated by Aaron Sloman into the build-tree.
#
#     _build/MakeIndexes.proxy
#         Making indexes should be a very late stage as it will build index
#         files all over the place. The limitation of building index files statically
#         is a nuisance and it would be nice to replace this with a more
#         dynamic system so that user libraries automatically get added into
#         the search.
#
#     _build/Done.proxy
#         This file represents the completion of the build-tree in the
#         _build/poplog_base folder. This can be moved to the appropriate
#         place.
#
BASE_FILES:=$(shell find base -type f)
NOINIT_FILES:=$(addprefix _build/poplog_base/pop/com/noinit/,vedinit.p init.pl init.lsp init.ml) _build/poplog_base/pop/com/noinit/init.p
POPLOG_COMMANDER:=_build/poplog_base/pop/bin/poplog


.PHONY: build
build: _build/Done.proxy
	# Target "build" completed


_build/Done.proxy: _build/MakeIndexes.proxy $(POPLOG_COMMANDER) $(NOINIT_FILES) _build/POPLOG_VERSION
	find _build/poplog_base -name '*-' -exec rm -f {} \; # Remove the backup files
	find _build/poplog_base -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@

_build/POPLOG_VERSION: _build/poplog_base/pop/pop/corepop
	_build/poplog_base/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

binarytarball: $(BINARY_TARBALL)
# Pop-tree: can be untarred and used directly (as an alternative to
# installing via a poplog package e.g. deb/rpm etc)
$(BINARY_TARBALL): _build/Done.proxy
	mkdir -p "$(@D)"
	( cd _build/poplog_base/; tar cf - pop ) | gzip > $@
	[ -f $@ ] # Sanity check that we built the target


_build/poplog_base/pop/com/noinit/init.p:
	mkdir -p $(@D)
	touch $@
	chmod a-w $@

$(filter-out _build/poplog_base/pop/com/noinit/init.p,$(NOINIT_FILES)): _build/poplog_base/pop/com/noinit/init.p
	[ -f $(@D)/init.p ]
	cd $(@D) && ln -sf init.p $(notdir $@)
	chmod a-w $@

_build/commander/poplog.c: makePoplogCommander.sh _build/Stage2.proxy
	mkdir -p $(@D)
	GETPOPLOG_VERSION="$(GETPOPLOG_VERSION)" bash makePoplogCommander.sh > _build/commander/poplog.c

_build/commander/poplog: _build/commander/poplog.c
	$(CC) $(CFLAGS) -Wextra -Werror -Wpedantic -o $@ $<

$(POPLOG_COMMANDER): _build/commander/poplog
	mkdir -p $(@D)
	cp --force $< $@

_build/MakeIndexes.proxy: _build/Stage2.proxy _build/Packages.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popinit.sh \
        && $$usepop/pop/com/makeindexes > _build/makeindexes.log
	touch $@

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
_build/ExtraScripts.proxy: _build/poplog_base/pop/com/poplogout.sh _build/poplog_base/pop/com/poplogout.csh
	touch $@

_build/poplog_base/pop/com/poplogout.%: _download/poplogout.%
	mkdir -p "$(@D)"
	cp "$<" "$@"

_build/ExtractPackages.proxy: _download/packages-V$(MAJOR_VERSION).tar.bz2 
	mkdir -p _build/poplog_base/pop
	(cd _build/poplog_base/pop; tar jxf "../../../$<")
	touch $@

_build/PatchPackages.proxy: _build/ExtractPackages.proxy
	./patchPackages.sh
	touch $@

VISION_DIR:=_build/poplog_base/pop/packages/popvision
VISION_LIBS:=$(addprefix $(VISION_DIR)/lib/bin/linux/,$(notdir $(patsubst %.c,%.so,$(wildcard $(VISION_DIR)/lib/*.c))))
$(VISION_LIBS): $(VISION_DIR)/lib/bin/linux/%.so: $(VISION_DIR)/lib/%.c _build/PatchPackages.proxy
	mkdir -p $(@D)
	$(CC) -o $@ -O3 -fpic -I$(VISION_DIR)/lib -shared $<

NEURAL_DIR:=_build/poplog_base/pop/packages/neural
NEURAL_LIBS:=$(addprefix $(NEURAL_DIR)/bin/linux/,$(notdir $(patsubst %.c,%.so,$(wildcard $(NEURAL_DIR)/src/c/*.c))))
$(NEURAL_LIBS): $(NEURAL_DIR)/bin/linux/%.so: $(NEURAL_DIR)/src/c/%.c _build/PatchPackages.proxy
	mkdir -p $(@D)
	$(CC) -o $@ -O3 -fpic -I$(NEURAL_DIR)/src/c -shared $<

_build/Packages.proxy: _build/Base.proxy $(VISION_LIBS) $(NEURAL_LIBS) _build/ExtractPackages.proxy
	touch $@

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
_build/Stage2.proxy: _build/Stage1.proxy _build/Newpop.proxy
	bash makeSystemTools.sh
	bash makeStage2.sh
	touch $@

_build/Newpop.proxy: _build/poplog_base/pop/pop/newpop.psv
	touch $@

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency
# on Stage1.
_build/poplog_base/pop/pop/newpop.psv: _build/Stage1.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popinit.sh \
        && (cd $$popsys; $$popsys/corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)

# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
_build/Stage1.proxy: _build/poplog_base/pop/pop/corepop
	bash makeSystemTools.sh
	bash relinkCorepop.sh
	cp _build/poplog_base/pop/pop/newpop11 _build/poplog_base/pop/pop/corepop
	touch $@

# This target ensures that we have an unpacked base system with a valid corepop file.
_build/poplog_base/pop/pop/corepop: _build/Base.proxy
	mkdir -p $(@D)
	cp -rpP corepops _build/corepops
	$(MAKE) -C _build/corepops corepop
	cp -p _build/corepops/corepop $@
	touch $@

_build/Base.proxy: $(BASE_FILES)
	mkdir -p "$(@D)"
	-rm -rf _build/poplog_base
	cp -rpP base _build/poplog_base
	$(MAKE) -C _build/poplog_base
	touch $@ # Create the proxy file to signal that we are done.
