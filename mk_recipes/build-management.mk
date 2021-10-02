OS:=$(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH:=$(shell uname -m)
COREPOPS:=$(wildcard corepops/$(OS)/$(ARCH)/*.c)

build: _build/BuildPrep.proxy
	$(MAKE) -C _build all

_build/BuildPrep.proxy: _build/mk_cross _build/poplog_base _build/poplog_base/pop/packages _build/poplog_base/pop/pop/corepop _build/Makefile

_build/mk_cross: mk_cross
	mkdir -p $(@D)
	cp $< $@

_build/Makefile: mk_recipes/build-inplace.mk
	mkdir -p $(@D)
	cp $< $@

_build/poplog_base/pop/pop/corepop: corepops/find.sh $(COREPOPS)
	mkdir -p $(@D)
	COREPOP=$$(./corepops/find.sh)
	[ $$? -eq 0 ]
	cp $$COREPOP $@

_build/poplog_base: base
	mkdir -p $@
	( cd $<; tar cf - pop ) | ( cd $@; tar xf - )

_build/poplog_base/pop/packages: _download/packages-V$(MAJOR_VERSION).tar.bz2
	mkdir -p $(@D)
	( cd _build/poplog_base/pop; tar jxf "../../../$<" )
	./patchPackages.sh

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
_build/poplog_base/pop/com/poplogout.%: _download/poplogout.%
	mkdir -p "$(@D)"
	cp "$<" "$@"
