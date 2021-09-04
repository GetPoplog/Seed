################################################################################
# The build process
################################################################################
# Poplog has quite a complicated build process based on a bootstrapping
# approach. An initial `corepop` is needed to drive the process, this is
# a compiled version of pop11 that is needed to rebuild the pop11
# tooling.
#
# Step 1: Obtaining a working `corepop`
#
#   The first step is to find a `corepop` that works on the machine
#   we're currently building on. This is delegated to rules in
#   `corepops/Makefile` whose `corepop` target will select a working
#   `corepop` out of a set of `corepop`s we have gathered.
#
# Step 2: Build the poplog tools: popc, poplibr, and poplink
#    Prereqs: Step 1
#
#   `pop11` executables (including `corepop`) function differently
#   depending on the their filename. To 'make' `popc`, `poplibr` and
#   `poplink` we can simply symlink `corepop` to each of these
#   executable names. When run, the actual executable file `corepop`
#   will look for a pop11 saved image the same name as the file being
#   executed. For example, if `popc` is symlinked to `corepop` and
#   invoked, then a saved image called `popc.psv` will be invoked.
#   We rebuild these saved images for `popc`, `poplibr` and `poplink`
#   before using them in subsequent stages of the build.
#   @STEVE: Why do we do this?
#
# Step 3: Build the pop11 system library src.wlb
#    Prereqs: Step 2
#
#   `src.wlb` is the core part of the pop11 system. It is built from all
#   the files in pop/src/*.p and pop/src/<arch>/*.[ps]. These files are
#   first compiled to object files (with `.o` and `.w` suffixes) and
#   then combined into `src.wlb` using `poplibr`.
#
# Step 4: Build libpop.a
#    Prereqs: None
#
#    Another core part of the pop11 system is `libpop.a`, built from C
#    source files `pop/extern/lib/*.[ch]`. It includes the very base
#    parts of the pop11 system like memory allocation, bignum upon which
#    the rest of the system is built.
#
# Step 5: Build newpop11
#    Prereqs: Step 3, Step 4
#
#    Eventually we want to dispense with our `corepop` that we use to
#    bootstrap the system. This step accomplishes that goal. `libpop.a`
#    and `src.wlb` are combined into `newpop11`.
#
# Step 6: Building the X widgets library: Xpw
#    Prereqs: None
#
#    pop11 has a library, Xpw, used to build X GUIs. This is written in
#    C and needs to be compiled into a shared library. The files from
#    `pop/extern/lib/*.[ch]` need to be compiled into a `libXpw.so` file
#
# Step 7: Build pop11 X bindings
#    Prereqs: Step 2, Step 4
#
#    All the files in `pop/x/src/*.p` are compiled using `popc` into
#    `*.w` and `*.o` files and combined into a library `xsrc.wlb` using
#    `poplibr`. This lib will later used in producing the saved images
#    that form the pop11 system.
#
# Step 8: Build ved
#    Prereqs: Step 2, Step 4
#
#    All the files in `pop/ved/src/*.p` are compiled using `popc` into
#    `*.w` and `*.o` files and combined into a library `vedsrc.wlb`
#    using `poplibr`. This lib will later used in producing the saved
#    images that form the pop11 system.
#
# Step 9: Build newpop.psv
#    Prereqs: Step 1
#
#    We next build newpop.psv that encapsulates the steps necessary for
#    building a new poplog distribution.

GETPOPLOG_VERSION:=$(shell cat VERSION)
MAJOR_VERSION?=16
POP_ARCH:=x86_64
BUILD_DIR?=_build  # set from the outer Makefile, but included as a safe guard.
BUILD_DIR:=$(abspath $(BUILD_DIR))


################################################################################
# Build targets
################################################################################
# The build process involves quite a lot of compilation and linking
# in-place, unfortunately.  So this Makefile is driven by the creation
# of 'proxy files' in the $(BUILD_DIR) folder. Each proxy files stands
# for the completion of a major phase of the build process.
#
# Proxy files:
#
#     $(BUILD_DIR)/Base.proxy
#         This file is a script that represents the successful copying
#         of the Base system after its own Makefile has been
#         successfully run.
#
#     $(BUILD_DIR)/Stage1.proxy
#         This file represents that the system-tools (popc, poplink,
#         poplibr) are now working and have been used to build a fresh
#         corepop, which is in $(BUILD_DIR)/poplog_base/pop/pop/newpop11
#         and moved to corepop.
#
#     $(BUILD_DIR)/Newpop.proxy
#         After Stage1, we need to get the critical newpop command
#         working on top of the fresh corepop we just built. This file
#         signals that it has been built successfully.
#
#     $(BUILD_DIR)/Stage2.proxy
#         This file represents a complete rebuilt Poplog system using
#         the newpop command and the full set of object files. It
#         includes:
#         - basepop11 and all links to it in $popsys
#         - all system images (prolog.psv, clisp.psv etc).
#         It does not include documentation or Aaron Sloman's packages
#         extension.  And by implication it does not include the doc
#         indexes.
#
#     $(BUILD_DIR)/Packages.proxy
#         This represents the addition of the additional packages
#         library curated by Aaron Sloman into the build-tree.
#
#     $(BUILD_DIR)/MakeIndexes.proxy
#         Making indexes should be a very late stage as it will build
#         index files all over the place. The limitation of building
#         index files statically is a nuisance and it would be nice to
#         replace this with a more dynamic system so that user libraries
#         automatically get added into the search.
#
#     $(BUILD_DIR)/Done.proxy
#         This file represents the completion of the build-tree in the
#         $(BUILD_DIR)/poplog_base folder. This can be moved to the
#         appropriate place.

USEPOP:=$(BUILD_DIR)/poplog_base
POPSYS:=$(USEPOP)/pop/pop
POPCOM:=$(USEPOP)/pop/com

POPC:=$(POPSYS)/popc
POPLIBR:=$(POPSYS)/poplibr
POPLINK:=$(POPSYS)/poplink
PGLINK:=$(POPSYS)/pglink

RUN_POPC:=source $(POPCOM)/popinit.sh && $(POPC)
RUN_POPLIBR:=source $(POPCOM)/popinit.sh && $(POPLIBR)
RUN_POPLINK:=source $(POPCOM)/popinit.sh && $(POPLINK)
RUN_PGLINK:=source $(POPCOM)/popinit.sh && $(PGLINK)

BASE_SRC:=$(shell find base -type f)
NOINIT_FILES:=$(addprefix $(POPCOM)/noinit/,vedinit.p init.pl init.lsp init.ml) $(POPCOM)/noinit/init.p
POPLOG_COMMANDER:=$(USEPOP)/pop/bin/poplog


COREPOP:=$(POPSYS)/corepop
NEWPOP11:=$(POPSYS)/newpop11


.PHONY: build
build: $(BUILD_DIR)/Done.proxy
	# Target "build" completed

$(BUILD_DIR)/Done.proxy: $(BUILD_DIR)/MakeIndexes.proxy $(POPLOG_COMMANDER) $(NOINIT_FILES) $(BUILD_DIR)/POPLOG_VERSION
	find $(BUILD_DIR)/poplog_base -name '*-' -exec rm -f {} \; # Remove the backup files
	find $(BUILD_DIR)/poplog_base -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@

$(BUILD_DIR)/POPLOG_VERSION: $(BUILD_DIR)/poplog_base/pop/pop/corepop
	$(BUILD_DIR)/poplog_base/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

binarytarball: $(BINARY_TARBALL)
# Pop-tree: can be untarred and used directly (as an alternative to
# installing via a poplog package e.g. deb/rpm etc)
$(BINARY_TARBALL): $(BUILD_DIR)/Done.proxy
	mkdir -p "$(@D)"
	( cd $(BUILD_DIR)/poplog_base/; tar cf - pop ) | gzip > $@
	[ -f $@ ] # Sanity check that we built the target


$(POPCOM)/noinit/init.p:
	mkdir -p $(@D)
	touch $@
	chmod a-w $@

$(filter-out $(POPCOM)/noinit/init.p,$(NOINIT_FILES)): $(POPCOM)/noinit/init.p
	[ -f $(@D)/init.p ]
	cd $(@D) && ln -sf init.p $(notdir $@)
	chmod a-w $@

$(BUILD_DIR)/commander/poplog.c: makePoplogCommander.sh $(BUILD_DIR)/Stage2.proxy
	mkdir -p $(@D)
	GETPOPLOG_VERSION="$(GETPOPLOG_VERSION)" bash makePoplogCommander.sh > $(BUILD_DIR)/commander/poplog.c

$(POPLOG_COMMANDER): CFLAGS+=-Wextra -Werror -Wpedantic
$(POPLOG_COMMANDER): $(BUILD_DIR)/commander/poplog.c
	mkdir $(@D)
	$(CC) $(CFLAGS) -o $@ $<


$(BUILD_DIR)/MakeIndexes.proxy: $(BUILD_DIR)/Stage2.proxy $(BUILD_DIR)/Packages.proxy
	export usepop=$(USEPOP) \
        && . $(POPCOM)/popinit.sh \
        && $$usepop/pop/com/makeindexes > $(BUILD_DIR)/makeindexes.log
	touch $@

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
$(BUILD_DIR)/ExtraScripts.proxy: $(BUILD_DIR)/poplog_base/pop/com/poplogout.sh $(BUILD_DIR)/poplog_base/pop/com/poplogout.csh
	touch $@

$(BUILD_DIR)/poplog_base/pop/com/poplogout.%: _download/poplogout.%
	mkdir -p "$(@D)"
	cp --preserve=mode,ownership "$<" "$@"

$(BUILD_DIR)/ExtractPackages.proxy: _download/packages-V$(MAJOR_VERSION).tar.bz2 
	mkdir -p $(BUILD_DIR)/poplog_base/pop
	(cd $(BUILD_DIR)/poplog_base/pop; tar jxf "../../../$<")
	touch $@

$(BUILD_DIR)/PatchPackages.proxy: $(BUILD_DIR)/ExtractPackages.proxy
	./patchPackages.sh
	touch $@

VISION_DIR:=$(BUILD_DIR)/poplog_base/pop/packages/popvision
VISION_LIBS:=$(addprefix $(VISION_DIR)/lib/bin/linux/,$(notdir $(patsubst %.c,%.so,$(wildcard $(VISION_DIR)/lib/*.c))))
$(VISION_LIBS): $(VISION_DIR)/lib/bin/linux/%.so: $(VISION_DIR)/lib/%.c $(BUILD_DIR)/PatchPackages.proxy
	mkdir -p $(@D)
	$(CC) -o $@ -O3 -fpic -I$(VISION_DIR)/lib -shared $<

NEURAL_DIR:=$(BUILD_DIR)/poplog_base/pop/packages/neural
NEURAL_LIBS:=$(addprefix $(NEURAL_DIR)/bin/linux/,$(notdir $(patsubst %.c,%.so,$(wildcard $(NEURAL_DIR)/src/c/*.c))))
$(NEURAL_LIBS): $(NEURAL_DIR)/bin/linux/%.so: $(NEURAL_DIR)/src/c/%.c $(BUILD_DIR)/PatchPackages.proxy
	mkdir -p $(@D)
	$(CC) -o $@ -O3 -fpic -I$(NEURAL_DIR)/src/c -shared $<

$(BUILD_DIR)/Packages.proxy: $(BUILD_DIR)/Base.proxy $(VISION_LIBS) $(NEURAL_LIBS) $(BUILD_DIR)/ExtractPackages.proxy
	touch $@

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
$(BUILD_DIR)/Stage2.proxy: $(BUILD_DIR)/Stage1.proxy $(BUILD_DIR)/Newpop.proxy
	bash makeSystemTools.sh
	bash makeStage2.sh
	touch $@

$(BUILD_DIR)/Newpop.proxy: $(BUILD_DIR)/poplog_base/pop/pop/newpop.psv
	touch $@

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency
# on Stage1.
$(BUILD_DIR)/poplog_base/pop/pop/newpop.psv: $(BUILD_DIR)/Stage1.proxy
	export usepop=$(USEPOP) \
        && . $(POPCOM)/popinit.sh \
        && (cd $$popsys; $$popsys/corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)
	
POP_SYSTOOLS:=$(POPC) $(POPLIBR) $(POPLINK)
POP_SYSTOOLS_IMAGES:=$(addsuffix .psv,$(POP_SYSTOOLS))
$(POP_SYSTOOLS_IMAGES): mk_cross $(BUILD_DIR)/Base.proxy $(COREPOP)
	top_level="$$(pwd)"; \
	export usepop="$(USEPOP)"; \
	export POP_arch=x86_64; \
	export POP__as=$$(which as); \
	source $(POPCOM)/popinit.sh; \
	cd $$popsrc && "$$top_level/mk_cross" -d -a="$$POP_arch" $(basename $(notdir $@))


$(POP_SYSTOOLS): %: %.psv $(COREPOP)
	cd $(@D) && [ -f corepop ] && ln -sf corepop $(notdir $@)

LIBXPW_OBJECTS:=$(wildcard base/pop/x/Xpw/*.c)
$(LIBXPW): $(LIBXPW_OBJECTS)
	$(CC) $(CFLAGS) -shared -o $@ $^

SRC_WLB_SRC:=$(wildcard base/pop/src/*.p base/pop/src/$(POP_ARCH)/*.[ps])
SRC_WLB_SRC:=$(SRC_WLB_SRC:base/%=$(BUILD_DIR)/poplog_base/%)
SRC_WLB_OBJECTS:=$($(SRC_WLB_SRC:%.p=%.w):%.s:%.w)
$(SRC_WLB_OBJECTS): %.w: %.p $(BUILD_DIR)/poplog_base/pop/pop/popc
	$(RUN_POPC) -c -nosys $(filter %.p,%^)


$(BUILD_DIR)/poplog_base/pop/obj/src.wlb: $(SRC_WLB_OBJECTS) $(BUILD_DIR)/poplog_base/pop/pop/poplibr
	$(BUILD_DIR)/poplog_base/pop/pop/poplibr -c $@ $^

$(USEPOP)/pop/%.o $(USEPOP)/pop/%.w: $(POPSRC)/%.p $(POPC)
	$(RUN_POPC) -c -nosys $@

LIBPOP_SRC:=$(wildcard base/pop/extern/lib/*.c)
LIBPOP_SRC:=$(LIBPOP_SRC:base/%=$(BUILD_DIR)/poplog_base/%)
LIBPOP_OBJECTS:=$(patsubst %.c,%.o,$(LIBPOP_SRC))
$(LIBPOP_OBJECTS): CFLAGS+=-Wall
$(POPSYS)/libpop.a: $(LIBPOP_OBJECTS)
	$(AR) rc $@ $^

# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
$(BUILD_DIR)/Stage1.proxy: $(BUILD_DIR)/poplog_base/pop/pop/corepop $(POP_SYSTOOLS) $(NEWPOP11)
	#bash makeSystemTools.sh
	#bash relinkCorepop.sh
	touch $@

$(NEWPOP11): $(LIBPOP) $(POP_SYSTOOLS) $(LIBXPW)
	cd $(POPSYS) && $(RUN_PGLINK) -core

# This target ensures that we have an unpacked base system with a valid corepop file.
$(BUILD_DIR)/poplog_base/pop/pop/corepop: $(BUILD_DIR)/Base.proxy
	mkdir -p $(@D)
	cp -rpP corepops $(BUILD_DIR)/corepops
	$(MAKE) -C $(BUILD_DIR)/corepops corepop
	cp --preserve=mode,ownership $(BUILD_DIR)/corepops/corepop $@

$(BUILD_DIR)/Base.proxy: $(BASE_SRC)
	mkdir -p "$(@D)"
	-rm -rf $(BUILD_DIR)/poplog_base
	cp --preserve=mode,ownership -rP base $(BUILD_DIR)/poplog_base
	$(MAKE) -C $(BUILD_DIR)/poplog_base
	touch $@ # Create the proxy file to signal that we are done.
