# This Makefile fragment is responsible for orchestrating the build of
# the poplog system.
#
# This is a somewhat complicated process given that
# poplog is a bootstrapped system. At a high-level the build works as
# follows:
# 1. Assemble files for an in-place build.
# 2. Build a new corepop from an existing one.
# 3. Build Xt, Motif, and no X variants of the poplog system.
# 4. Build the poplog commander and other supporting files.
#
# In more detail, the build process can be delimited into the following
# major phases:
#
# Phase 1: Assemble build directory (`_build/BuildPrep.proxy`)
#
#    This phase copies all source files into _build/poplog_base and copies
#    the inplace Makefile (`mk_recipes/buildInplace.mk`) into the
#    directory.
#
# Phase 2: Build a new corepop (`_build/NewCorepop.proxy`)
#
#   This phase generates a new corepop that will be used to build the full
#   system.
#
# Phase 3: Build the system (`_build/BuildEnvs.proxy`)
#
#   This phase compiles the poplog system 3 times. Once for each different
#   system configuration we ship: Xt, Motif and without X. This process
#   starts from the new corepop we built in phase 2.
#
# Phase 4: Build the poplog commander (`_build/poplog_base/pop/bin/poplog`)
#
#   This phase builds a C program that is used to interact with the
#   poplog system. The program is generated from a mix of bash and templated C
#   which depends upon all 3 poplog builds having been produced.
#
# Phase 5: Complete the build (`_build/Done.proxy`, `_build/MakeIndexes.proxy`)
#
#   This phase performs a few minor tasks, the first being to generate
#   indexes used by ved for the pop packages, the second task is to
#   clean up the dirty parts of the pop tree (dead symlink etc).

OS:=$(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH:=$(shell uname -m)
COREPOPS:=$(wildcard corepops/$(OS)/$(ARCH)/*.c)
POPLOG_COMMANDER:=_build/poplog_base/pop/bin/poplog
usepop:=_build/poplog_base

build: _build/Done.proxy

_build/Makefile: mk_recipes/buildInplace.mk
	mkdir -p $(@D)
	cp $< $@

# This proxy target represents the initial corepop being installed in
# place into the poplog tree. This is a necessity for building the new
# corepop.
_build/BootstrapCorepop.proxy: corepops/find.sh $(COREPOPS)
	mkdir -p _build/poplog_base/pop/pop/
	COREPOP=$$(./corepops/find.sh)
	[ $$? -eq 0 ] || { echo "No valid corepop found"; exit 1; }
	cp $$COREPOP _build/poplog_base/pop/pop/corepop
	touch $@

# This proxy target represents copying the poplog tree into _build.
_build/CopyBase.proxy:
	mkdir -p _build/poplog_base
	( cd base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	touch $@

# This proxy target represents copying the pop packages into the poplog
# build tree.
_build/CopyPackages.proxy: _download/packages-V$(MAJOR_VERSION).tar.bz2
	mkdir -p _build/poplog_base/pop/packages
	( cd _build/poplog_base/pop; tar jxf "../../../$<" )
	./patchPackages.sh
	touch $@

_build/poplog_base/pop/com/poplogout.%: _download/poplogout.%
	mkdir -p "$(@D)"
	cp "$<" "$@"

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
_build/ExtraScripts.proxy: _build/poplog_base/pop/com/poplogout.sh _build/poplog_base/pop/com/poplogout.csh
	touch $@

# This proxy target indicates that all files have been put into place in
# the _build directory to perform an inplace build.
_build/BuildPrep.proxy: _build/Makefile _build/BootstrapCorepop.proxy _build/CopyBase.proxy _build/CopyPackages.proxy
	touch $@

# This proxy target indicates a new corepop has been built using the
# provided corepop.
_build/NewCorepop.proxy: _build/BuildPrep.proxy
	$(MAKE) -C _build corepop
	mv $(usepop)/pop/pop/{new_corepop,corepop}
	find $(usepop) -iname '*.w' -o -iname '*.wlb' -o -iname '*.olb' -o -iname '*.psv' -delete
	touch $@

# This is the main build proxy target. Once complete, this recipe will
# have created 3 different poplog builds: one linked against motif, one
# against xt, and one without X. Each of these will produce a
# file in _build/environment/ which is used by the makePoplogCommander
# build script to generate the C source for the poplog commander.
_build/BuildEnvs.proxy: _build/NewCorepop.proxy
	tar_fromdir_todir() {
	  ( cd "$$1"; tar cf - . ) | ( cd "$$2"; tar xf - )
	}

	@rm -f _build/poplog_base/pop/lib/psv/*
	POP_X_CONFIG=nox $(MAKE) -C _build all
	mkdir -p $(usepop)/pop/pop-nox
	mkdir -p $(usepop)/pop/lib/psv-nox
	tar_fromdir_todir $(usepop)/pop/pop{,-nox}
	tar_fromdir_todir $(usepop)/pop/lib/psv{,-nox}

	@rm -f _build/poplog_base/pop/lib/psv/*
	POP_X_CONFIG=xt $(MAKE) -C _build all
	mkdir -p $(usepop)/pop/pop-xt
	mkdir -p $(usepop)/pop/lib/psv-xt
	tar_fromdir_todir $(usepop)/pop/pop{,-xt}
	tar_fromdir_todir $(usepop)/pop/lib/psv{,-xt}

	@rm -f _build/poplog_base/pop/lib/psv/*
	POP_X_CONFIG=xm $(MAKE) -C _build all
	mkdir -p $(usepop)/pop/pop-xm
	mkdir -p $(usepop)/pop/lib/psv-xm
	tar_fromdir_todir $(usepop)/pop/pop{,-xm}
	tar_fromdir_todir $(usepop)/pop/lib/psv{,-xm}
	touch $@

# The poplog commander requires the poplog system to be built first as
# it uses the environment files that are generated as part of the build.
# These environment files indicate what variables need to be set by the
# poplog commander when using different built variants (motif/xt/nox).
_build/commander/poplog.c: makePoplogCommander.sh _build/BuildEnvs.proxy
	mkdir -p $(@D)
	( bash makePoplogCommander.sh > $@; ) || rm -f $@

$(POPLOG_COMMANDER): CFLAGS+=-Wextra -Werror -Wpedantic
$(POPLOG_COMMANDER): _build/commander/poplog.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@


# This proxy target indicates that the indexes for ved have been built.
# These are used to look up symbols.
_build/MakeIndexes.proxy: _build/BuildEnvs.proxy
	export usepop=$(usepop)
	. ./_build/poplog_base/pop/com/popinit.sh
	$$usepop/pop/com/makeindexes > _build/makeindexes.log
	touch $@

# This proxy target indicates that empty init files have been installed
# into the poplog tree. By default if there are no `init.*` files
# present in `$poplib`, poplog will look for a `init.p` file in the
# current working directory, if it is present it will run the contents.
# This is bad for security thus we install dummy init files by default
# to prevent this behaviour.
_build/NoInit.proxy: _build/BuildPrep.proxy
	# Add the noinit files for poplog --run.
	mkdir -p $(usepop)/pop/com/noinit
	( cd $(usepop)/pop/com/noinit; \
	  touch init.p; \
	  ln -sf init.p vedinit.p; \
	  ln -sf init.p init.pl; \
	  ln -sf init.p init.lsp; \
	  ln -sf init.p init.ml )
	chmod a-w $(usepop)/pop/com/noinit/*.*
	touch $@

# This file records the version of poplog. Note that it depends on
# running the new corepop, not the old one, so we get the latest corepop
# version.
_build/POPLOG_VERSION: _build/NewCorepop.proxy
	$(usepop)/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

# This proxy target indicates that the whole poplog system has been
# built. Make can be invoked to build this target and the user can
# expect a valid system to be present at _build/poplog_base upon
# completion.
_build/Done.proxy: _build/MakeIndexes.proxy $(POPLOG_COMMANDER) _build/NoInit.proxy _build/POPLOG_VERSION
	find $(usepop) -name '*-' -exec rm -f {} \; # Remove the backup files
	find $(usepop) -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@
