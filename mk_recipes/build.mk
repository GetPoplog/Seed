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
#     _build/Corepops.proxy
#         This file represents  the discovery of a viable corepop executable. This should
#         be sufficient to reconstruct working system tools.
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
#     _build/PoplogCommander.proxy
#         This represents the successful compilation of the commander-tool
#         and its insertion into the Poplog-tree.
#
#     _build/Done.proxy
#         This file represents the completion of the build-tree in the
#         _build/poplog_base folder. This can be moved to the appropriate
#         place.

POPLOG_COMMANDER:=_build/poplog_base/pop/bin/poplog

.PHONY: build
build: _build/Done.proxy
	# Target "build" completed

_build/Done.proxy: _build/MakeIndexes.proxy $(POPLOG_COMMANDER) _build/NoInit.proxy _build/POPLOG_VERSION
	find _build/poplog_base -name '*-' -exec rm -f {} \; # Remove the backup files
	find _build/poplog_base -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@

_build/POPLOG_VERSION: _build/Base.proxy
	_build/poplog_base/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

_build/NoInit.proxy: _build/Base.proxy
	# Add the noinit files for poplog --run.
	mkdir -p _build/poplog_base/pop/com/noinit
	cd _build/poplog_base/pop/com/noinit; \
	  touch init.p; \
	  ln -sf init.p vedinit.p; \
	  ln -sf init.p init.pl; \
	  ln -sf init.p init.lsp; \
	  ln -sf init.p init.ml
	chmod a-w _build/poplog_base/pop/com/noinit/*.*
	touch $@

_build/commander/poplog.c: makePoplogCommander.sh
	mkdir -p $(@D)
	bash makePoplogCommander.sh > $@
	
$(POPLOG_COMMANDER): CFLAGS+=-Wextra -Werror -Wpedantic
$(POPLOG_COMMANDER): _build/commander/poplog.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@

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

_build/Packages.proxy: _download/packages-V$(MAJOR_VERSION).tar.bz2 _build/Base.proxy
	(cd _build/poplog_base/pop; tar jxf "../../../$<")
	./patchPackages.sh
	cd _build/poplog_base/pop/packages/popvision/lib; mkdir -p bin/linux; for f in *.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	cd _build/poplog_base/pop/packages/neural/; mkdir -p bin/linux; for f in src/c/*.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	touch $@

LIBPOP_SRC:=$(wildcard base/pop/extern/lib/*.c)
LIBPOP_HEADERS:=$(wildcard base/pop/extern/lib/*.h)
LIBPOP_OBJ:=$(LIBPOP_SRC:base/%.c=_build/poplog_base/%.o)
LIBPOP:=_build/poplog_base/pop/extern/libpop.a

$(LIBPOP_OBJ): _build/poplog_base/%.o: base/%.c $(LIBPOP_HEADERS)
	mkdir -p $(@D)
	$(CC) -c -O $(CFLAGS) -o $@ $<

$(LIBPOP): $(LIBPOP_OBJ)
	mkdir -p $(@D)
	$(AR) rc $@ $^

X11_CFLAGS:=$(shell pkg-config --cflags x11) -I/usr/include/X11
X11_LDFLAGS:=$(shell pkg-config --libs x11)

LIBXPW_SRC:=$(wildcard base/pop/x/Xpw/*.c)
LIBXPW_HEADERS:=$(wildcard base/pop/x/Xpw/*.h)
LIBXPW_OBJ:=$(LIBXPW_SRC:base/%.c=_build/poplog_base/%.o)
LIBXPW:=_build/poplog_base/pop/extern/lib/libXpw.so

$(LIBXPW_OBJ): CFLAGS=$(X11_CFLAGS) -Ibase/pop/x/Xpw/ -fpic -g
$(LIBXPW_OBJ): _build/poplog_base/%.o: base/%.c $(LIBXPW_HEADERS)
	mkdir -p $(@D)
	$(CC) -c $(CFLAGS) -o $@ $<

$(LIBXPW): LDFLAGS+=$(X11_LDFLAGS)
$(LIBXPW): $(LIBXPW_OBJ)
	mkdir -p $(@D)
	$(CC) -shared $(LDFLAGS) -o $@ $^

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
_build/Stage2.proxy: _build/Stage1.proxy _build/Newpop.proxy $(LIBPOP) $(LIBXPW)
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
_build/Stage1.proxy: _build/Corepops.proxy
	bash makeSystemTools.sh
	bash relinkCorepop.sh
	cp _build/poplog_base/pop/pop/newpop11 _build/poplog_base/pop/pop/corepop
	touch $@

# This target ensures that we have an unpacked base system with a valid corepop file.
_build/Corepops.proxy: _build/Base.proxy
	mkdir -p "$(@D)"
	cp -rpP corepops _build/corepops
	cp -p _build/poplog_base/pop/pop/corepop _build/corepops/supplied.corepop
	$(MAKE) -C _build/corepops corepop
	cp -p _build/corepops/corepop _build/poplog_base/pop/pop/corepop
	touch $@

_build/Base.proxy: base
	mkdir -p "$(@D)"
	cp -rpP base _build/
	$(MAKE) -C _build/base build
	mkdir -p _build/poplog_base
	( cd _build/base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	touch $@ # Create the proxy file to signal that we are done.
