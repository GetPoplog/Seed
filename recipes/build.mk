# Makefile fragment
# Assumes the following variables exist:
# - MAJOR_VERSION
# - SRC_TARBALL
# - SRC_TARBALL_FILENAME
# - BINARY_TARBALL
# - POPLOG_HOME_DIR
# - bindir
# - BUILD

USEPOP:=$(BUILD)/poplog_base
POPSYS:=$(USEPOP)/pop/pop
POPSRC:=$(USEPOP)/pop/src
POPCOM:=$(USEPOP)/pop/com
# $usepop is used by the `popinit.sh` script to set up environment and
# needs to be an absolute path
usepop:=$(abspath $(USEPOP))
# exporting the variable makes it available to all
export usepop
################################################################################
# Phony targets
################################################################################
.PHONY: build
build: $(BUILD)/Done.proxy
	# Target "build" completed

.PHONY: srctarball
srctarball: $(SRC_TARBALL)

################################################################################

$(SRC_TARBALL): _download/packages-V$(MAJOR_VERSION).tar.bz2 _download/poplogout.sh _download/poplogout.csh
	mkdir -p "$(@D)"
	rm -f "$@"; \
	ASSEMBLY_DIR="$$(umask u=rwx,go=r && mktemp --directory --tmpdir="$(TMP_DIR)")"; \
	POPLOG_TAR_DIR="$$ASSEMBLY_DIR/$(SRC_TARBALL_FILENAME)"; \
	mkdir -p "$$POPLOG_TAR_DIR"; \
	tar cf - --exclude=$(BUILD) . | ( cd $$POPLOG_TAR_DIR && tar xf - ); \
	tar -C "$$ASSEMBLY_DIR" -czf "$@" "$(SRC_TARBALL_FILENAME)"; \
	rm -rf "$$ASSEMBLY_DIR"
################################################################################
# Build targets
################################################################################
# The build process involves quite a lot of compilation and linking in-place, unfortunately.
# So this Makefile is driven by the creation of 'proxy files' in the $(BUILD) folder. Each proxy
# files stands for the completion of a major phase of the build process.
#
# Proxy files:
#
#     $(BUILD)/Base.proxy
#         This file is a script that represents the successful copying of the Base system
#         after its own Makefile has been successfully run.
#
#     $(BUILD)/Corepops.proxy
#         This file represents  the discovery of a viable corepop executable. This should
#         be sufficient to reconstruct working system tools.
#
#     $(BUILD)/Stage1.proxy
#         This file represents that the system-tools (popc, poplink, poplibr) are now
#         working and have been used to build a fresh corepop, which is in
#         $(BUILD)/poplog_base/pop/pop/newpop11 and moved to corepop.
#
#     $(BUILD)/Newpop.proxy
#         After Stage1, we need to get the critical newpop command working on top of
#         the fresh corepop we just built. This file signals that it has been built
#         successfully.
#
#     $(BUILD)/Stage2.proxy
#         This file represents a complete rebuilt Poplog system using the newpop
#         command and the full set of object files. It includes:
#             - basepop11 and all links to it in $popsys
#             - all system images (prolog.psv, clisp.psv etc).
#         It does not include documentation or Aaron Sloman's packages extension.
#         And by implication it does not include the doc indexes.
#
#     $(BUILD)/Packages.proxy
#         This represents the addition of the additional packages library
#         curated by Aaron Sloman into the build-tree.
#
#     $(BUILD)/MakeIndexes.proxy
#         Making indexes should be a very late stage as it will build index
#         files all over the place. The limitation of building index files statically
#         is a nuisance and it would be nice to replace this with a more
#         dynamic system so that user libraries automatically get added into
#         the search.
#
#     $(BUILD)/PoplogCommander.proxy
#         This represents the successful compilation of the commander-tool
#         and its insertion into the Poplog-tree.
#
#     $(BUILD)/Done.proxy
#         This file represents the completion of the build-tree in the
#         $(BUILD)/poplog_base folder. This can be moved to the appropriate
#         place.
#

$(BUILD)/Base.proxy: base
	mkdir -p "$(@D)"
	cp -rpP base $(BUILD)/
	$(MAKE) -C $(BUILD)/base build
	mkdir -p $(BUILD)/poplog_base
	( cd $(BUILD)/base; tar cf - pop ) | ( cd $(BUILD)/poplog_base; tar xf - )
	touch $@ # Create the proxy file to signal that we are done.

# This target ensures that we have an unpacked base system with a valid corepop file.
$(BUILD)/Corepops.proxy: $(BUILD)/Base.proxy
	mkdir -p "$(@D)"
	cp -rpP corepops $(BUILD)/corepops
	cp -p $(BUILD)/poplog_base/pop/pop/corepop $(BUILD)/corepops/supplied.corepop
	$(MAKE) -C $(BUILD)/corepops corepop
	cp -p $(BUILD)/corepops/corepop $(BUILD)/poplog_base/pop/pop/corepop
	touch $@

# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
$(BUILD)/Stage1.proxy: $(BUILD)/Corepops.proxy
	bash makeSystemTools.sh
	bash relinkCorepop.sh
	cp $(BUILD)/poplog_base/pop/pop/newpop11 $(BUILD)/poplog_base/pop/pop/corepop
	touch $@

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency
# on Stage1.
$(BUILD)/poplog_base/pop/pop/newpop.psv: $(BUILD)/Stage1.proxy
	export usepop=$(abspath ./$(BUILD)/poplog_base) \
        && . $(POPCOM)/popinit.sh \
        && (cd $$popsys; $$popsys/corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)

$(BUILD)/Newpop.proxy: $(BUILD)/poplog_base/pop/pop/newpop.psv
	touch $@

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
$(BUILD)/Stage2.proxy: $(BUILD)/Stage1.proxy $(BUILD)/Newpop.proxy
	bash makeSystemTools.sh
	bash makeStage2.sh
	touch $@

$(BUILD)/PoplogCommander.proxy: $(BUILD)/Stage2.proxy
	mkdir -p $(BUILD)/commander
	mkdir -p $(BUILD)/poplog_base/pop/bin
	GETPOPLOG_VERSION="$(GETPOPLOG_VERSION)" bash makePoplogCommander.sh > $(BUILD)/commander/poplog.c
	cd $(BUILD)/commander && $(CC) $(CFLAGS) -Wextra -Werror -Wpedantic -o poplog poplog.c
	cp -f $(BUILD)/commander/poplog $(BUILD)/poplog_base/pop/bin/
	touch $@

$(BUILD)/Packages.proxy: _download/packages-V$(MAJOR_VERSION).tar.bz2 $(BUILD)/Base.proxy
	(cd $(BUILD)/poplog_base/pop; tar jxf "../../../$<")
	./patchPackages.sh
	cd $(BUILD)/poplog_base/pop/packages/popvision/lib; mkdir -p bin/linux; for f in *.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	cd $(BUILD)/poplog_base/pop/packages/neural/; mkdir -p bin/linux; for f in src/c/*.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	touch $@

$(BUILD)/MakeIndexes.proxy: $(BUILD)/Stage2.proxy $(BUILD)/Packages.proxy
	. $(POPCOM)/popinit.sh && \
		$(POPCOM)/makeindexes > $(BUILD)/makeindexes.log
	touch $@

$(BUILD)/POPLOG_VERSION: $(BUILD)/Base.proxy
	$(BUILD)/poplog_base/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

$(BUILD)/NoInit.proxy: $(BUILD)/Base.proxy
	# Add the noinit files for poplog --run.
	mkdir -p $(POPCOM)/noinit
	cd $(POPCOM)/noinit; \
	  touch init.p; \
	  ln -sf init.p vedinit.p; \
	  ln -sf init.p init.pl; \
	  ln -sf init.p init.lsp; \
	  ln -sf init.p init.ml
	chmod a-w $(POPCOM)/noinit/*.*
	touch $@

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
$(BUILD)/ExtraScripts.proxy: $(POPCOM)/poplogout.sh $(POPCOM)/poplogout.csh
	touch $@

$(POPCOM)/poplogout.%: _download/poplogout.%
	mkdir -p "$(@D)"
	cp "$<" "$@"

$(BUILD)/poplog_base/UNINSTALL_INSTRUCTIONS.md:
	mkdir -p "$(@D)"
	bindir="$(bindir)" POPLOG_HOME_DIR="$(POPLOG_HOME_DIR)" sh writeUninstallInstructions.sh > $(BUILD)/poplog_base/UNINSTALL_INSTRUCTIONS.md

binarytarball: $(BINARY_TARBALL)
# Pop-tree: can be untarred and used directly (as an alternative to
# installing via a poplog package e.g. deb/rpm etc)
$(BINARY_TARBALL): $(BUILD)/Done.proxy
	mkdir -p "$(@D)"
	( cd $(BUILD)/poplog_base/; tar cf - pop ) | gzip > $@
	[ -f $@ ] # Sanity check that we built the target

$(BUILD)/Done.proxy: $(BUILD)/MakeIndexes.proxy $(BUILD)/PoplogCommander.proxy $(BUILD)/NoInit.proxy $(BUILD)/POPLOG_VERSION
	find $(BUILD)/poplog_base -name '*-' -exec rm -f {} \; # Remove the backup files
	find $(BUILD)/poplog_base -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@
