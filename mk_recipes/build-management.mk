OS:=$(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH:=$(shell uname -m)
COREPOPS:=$(wildcard corepops/$(OS)/$(ARCH)/*.c)
POPLOG_COMMANDER:=_build/poplog_base/pop/bin/poplog
usepop:=_build/poplog_base

build: _build/Done.proxy
	$(MAKE) -C _build all

_build/Makefile: mk_recipes/build-inplace.mk
	mkdir -p $(@D)
	cp $< $@

_build/BootstrapCorepop.proxy: corepops/find.sh $(COREPOPS)
	mkdir -p _build/poplog_base/pop/pop/
	COREPOP=$$(./corepops/find.sh)
	[ $$? -eq 0 ] || { echo "No valid corepop found"; exit 1; }
	cp $$COREPOP _build/poplog_base/pop/pop/corepop
	touch $@

_build/CopyBase.proxy:
	mkdir -p _build/poplog_base
	( cd base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	touch $@

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

_build/BuildPrep.proxy:  _build/BootstrapCorepop.proxy _build/Makefile _build/CopyBase.proxy _build/CopyPackages.proxy
	touch $@

_build/NewCorepop.proxy: _build/BuildPrep.proxy
	$(MAKE) -C _build corepop
	mv $(usepop)/pop/pop/{new_corepop,corepop}
	find $(usepop) -iname '*.w' -o -iname '*.wlb' -o -iname '*.olb' -o -iname '*.psv' -delete
	touch $@

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

_build/commander/poplog.c: makePoplogCommander.sh _build/BuildEnvs.proxy
	mkdir -p $(@D)
	( bash makePoplogCommander.sh > $@; ) || rm -f $@

$(POPLOG_COMMANDER): CFLAGS+=-Wextra -Werror -Wpedantic
$(POPLOG_COMMANDER): _build/commander/poplog.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@


_build/MakeIndexes.proxy: _build/BuildEnvs.proxy
	export usepop=$(usepop)
	. ./_build/poplog_base/pop/com/popinit.sh
	$$usepop/pop/com/makeindexes > _build/makeindexes.log
	touch $@

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

_build/POPLOG_VERSION: _build/NewCorepop.proxy
	$(usepop)/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

_build/Done.proxy: _build/MakeIndexes.proxy $(POPLOG_COMMANDER) _build/NoInit.proxy _build/POPLOG_VERSION
	find $(usepop) -name '*-' -exec rm -f {} \; # Remove the backup files
	find $(usepop) -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@

