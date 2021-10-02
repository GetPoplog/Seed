# This Makefile is meant to invoked directly and not included. 

.ONESHELL:
SHELL:=/bin/bash


POP_arch=x86_64
export POP__as=$(shell which as)
export usepop=$(shell pwd)/poplog_base
popsys:=$(usepop)/pop/pop
popsrc:=$(usepop)/pop/src
popexternlib:=$(usepop)/pop/extern/lib

.PHONY: all
all: $(addprefix $(popsys),poplibr poplibr.psv popc popc.psv poplink poplink.psv)

$(popsrc)/syscomp/x86_64/asmout.p: $(popsrc)/syscomp/x86_64/asmout.p.template
	echo 'void test(){}' > test.c
	if `(cd _build; /usr/bin/gcc -no-pie -c test.c 2>&1)`; then \
		POP__CC_OPTIONS=-v -Wl,-export-dynamic -Wl,-no-as-needed; \
	else \
		POP__CC_OPTIONS=-v -no-pie -Wl,-export-dynamic -Wl,-no-as-needed; \
	fi
	test ! -z "$$POP__CC_OPTIONS" # test variable was set in previous block
	# Substitute the template-parameter that looks like
	# {{{POP__CC_OPTIONS:_random_text_}}} with the compiler options.
	sed -e 's/{{{POP__CC_OPTIONS:[^}]*}}}/$$POP__CC_OPTIONS/' < $< > $@


POPLOG_COMMANDER:=poplog_base/pop/bin/poplog

LIBPOP_SRC:=$(wildcard base/pop/extern/lib/*.c)
LIBPOP_HEADERS:=$(wildcard base/pop/extern/lib/*.h)
LIBPOP_OBJ:=$(LIBPOP_SRC:base/%.c=poplog_base/%.o)
LIBPOP:=poplog_base/pop/extern/libpop.a

$(LIBPOP_OBJ): poplog_base/%.o: base/%.c $(LIBPOP_HEADERS)
	mkdir -p $(@D)
	$(CC) -c -O $(CFLAGS) -o $@ $<

$(LIBPOP): $(LIBPOP_OBJ)
	mkdir -p $(@D)
	$(AR) rc $@ $^

X11_CFLAGS:=$(shell pkg-config --cflags x11) -I/usr/include/X11
X11_LDFLAGS:=$(shell pkg-config --libs x11)

LIBXPW_SRC:=$(wildcard base/pop/x/Xpw/*.c)
LIBXPW_HEADERS:=$(wildcard base/pop/x/Xpw/*.h)
LIBXPW_OBJ:=$(LIBXPW_SRC:base/%.c=poplog_base/%.o)
LIBXPW:=poplog_base/pop/extern/lib/libXpw.so

$(LIBXPW_OBJ): CFLAGS=$(X11_CFLAGS) -Ibase/pop/x/Xpw/ -fpic -g
$(LIBXPW_OBJ): poplog_base/%.o: base/%.c $(LIBXPW_HEADERS)
	mkdir -p $(@D)
	$(CC) -c $(CFLAGS) -o $@ $<

$(LIBXPW): LDFLAGS+=$(X11_LDFLAGS)
$(LIBXPW): $(LIBXPW_OBJ)
	mkdir -p $(@D)
	$(CC) -shared $(LDFLAGS) -o $@ $^

Done.proxy: MakeIndexes.proxy $(POPLOG_COMMANDER) NoInit.proxy POPLOG_VERSION
	find poplog_base -name '*-' -exec rm -f {} \; # Remove the backup files
	find poplog_base -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@

POPLOG_VERSION:
	$(popsys)/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

NoInit.proxy:
	# Add the noinit files for poplog --run.
	mkdir -p poplog_base/pop/com/noinit
	cd poplog_base/pop/com/noinit; \
	  touch init.p; \
	  ln -sf init.p vedinit.p; \
	  ln -sf init.p init.pl; \
	  ln -sf init.p init.lsp; \
	  ln -sf init.p init.ml
	chmod a-w poplog_base/pop/com/noinit/*.*
	touch $@

commander/poplog.c: makePoplogCommander.sh
	mkdir -p $(@D)
	bash makePoplogCommander.sh > $@

$(POPLOG_COMMANDER): CFLAGS+=-Wextra -Werror -Wpedantic
$(POPLOG_COMMANDER): commander/poplog.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@

MakeIndexes.proxy: Stage2.proxy Packages.proxy
	export usepop=$(abspath ./poplog_base) \
        && . ./poplog_base/pop/com/popinit.sh \
        && $(usepop)/pop/com/makeindexes > makeindexes.log
	touch $@


Packages.proxy: _download/packages-V$(MAJOR_VERSION).tar.bz2
	(cd poplog_base/pop; tar jxf "../../../$<")
	./patchPackages.sh
	cd poplog_base/pop/packages/popvision/lib; mkdir -p bin/linux; for f in *.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	cd poplog_base/pop/packages/neural/; mkdir -p bin/linux; for f in src/c/*.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	touch $@

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
Stage2.proxy: Stage1.proxy Newpop.proxy $(LIBPOP) $(LIBXPW)
	bash makeSystemTools.sh
	bash makeStage2.sh
	touch $@

Newpop.proxy: poplog_base/pop/pop/newpop.psv
	touch $@

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency
# on Stage1.
poplog_base/pop/pop/newpop.psv: Stage1.proxy
	export usepop=$(abspath ./poplog_base) \
        && . ./poplog_base/pop/com/popinit.sh \
        && (cd $$popsys; $$popsys/corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)

POP_COMPILER_TOOLS:=$(addprefix poplog_base/pop/pop/,poplibr popc poplink)
POP_COMPILER_TOOL_IMAGES:=$(addsuffix .psv,$(POP_COMPILER_TOOLS))
$(POP_COMPILER_TOOLS) $(POP_COMPILER_TOOL_IMAGES) &: poplog_base/pop/pop/corepop poplog_base/pop/src/syscomp/x86_64/asmout.p
	TOP="$$(pwd)"
	. "$${usepop}/pop/com/popinit.sh"
	export usepop
	export POP__as
	export POP_arch
	pushd $$popsrc
	$$TOP/mk_cross -d -a=$(POP_arch) popc poplibr poplink
	popd

	pushd poplog_base/pop/pop
	ln -sf corepop popc
	ln -sf corepop poplibr
	ln -sf corepop poplink
	popd


# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
Stage1.proxy: Corepops.proxy
	bash makeSystemTools.sh
	bash relinkCorepop.sh
	cp poplog_base/pop/pop/newpop11 poplog_base/pop/pop/corepop
	touch $@
