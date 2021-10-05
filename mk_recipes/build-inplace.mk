# This Makefile is meant to invoked directly and not included. 

.ONESHELL:
SHELL:=/bin/bash


POP_ARCH=x86_64
export POP__as=$(shell which as)
export usepop=$(shell pwd)/poplog_base
popsys:=$(usepop)/pop/pop
popsrc:=$(usepop)/pop/src
popcom:=$(usepop)/pop/com
popobj:=$(usepop)/pop/obj


POPC:=$(popsys)/popc
POPLIBR:=$(popsys)/poplibr
POPLINK:=$(popsys)/poplink
PGLINK:=$(popsys)/pglink

RUN_POPC:=source $(popcom)/popinit.sh && $(POPC)
RUN_POPLIBR:=source $(popcom)/popinit.sh && $(POPLIBR)
RUN_POPLINK:=source $(popcom)/popinit.sh && $(POPLINK)
RUN_PGLINK:=source $(popcom)/popinit.sh && $(PGLINK)


$(popsrc)/syscomp/$(POP_ARCH)/asmout.p: $(popsrc)/syscomp/$(POP_ARCH)/asmout.p.template
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

LIBPOP_SRC:=$(wildcard $(usepop)/pop/extern/lib/*.c)
LIBPOP_HEADERS:=$(wildcard $(usepop)/pop/extern/lib/*.h)
LIBPOP_OBJ:=$(LIBPOP_SRC:%.c=%.o)
LIBPOP:=$(usepop)/pop/extern/lib/libpop.a

$(LIBPOP_OBJ): %.o: %.c $(LIBPOP_HEADERS)
	mkdir -p $(@D)
	$(CC) -c -O $(CFLAGS) -o $@ $<

$(LIBPOP): $(LIBPOP_OBJ)
	mkdir -p $(@D)
	$(AR) rc $@ $^

X11_CFLAGS:=$(shell pkg-config --cflags x11) -I/usr/include/X11
X11_LDFLAGS:=$(shell pkg-config --libs x11)

LIBXPW_SRC:=$(wildcard $(usepop)/pop/x/Xpw/*.c)
LIBXPW_HEADERS:=$(wildcard $(usepop)/pop/x/Xpw/*.h)
LIBXPW_OBJ:=$(LIBXPW_SRC:%.c=%.o)
LIBXPW:=$(usepop)/pop/extern/lib/libXpw.so

$(LIBXPW_OBJ): CFLAGS=$(X11_CFLAGS) -Ibase/pop/x/Xpw/ -fpic -g
$(LIBXPW_OBJ): %.o: %.c $(LIBXPW_HEADERS)
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

POP_COMPILER_TOOLS:=$(POPC) $(POPLIBR) $(POPLINK)
POP_COMPILER_TOOL_IMAGES:=$(addsuffix .psv,$(POP_COMPILER_TOOLS))
$(POP_COMPILER_TOOLS) $(POP_COMPILER_TOOL_IMAGES) &: poplog_base/pop/pop/corepop poplog_base/pop/src/syscomp/x86_64/asmout.p
	TOP="$$(pwd)"
	. "$${usepop}/pop/com/popinit.sh"
	export usepop
	export POP__as
	pushd $$popsrc
	$$TOP/mk_cross -d -a=$(POP_ARCH) popc poplibr poplink
	popd

	pushd poplog_base/pop/pop
	ln -sf corepop popc
	ln -sf corepop poplibr
	ln -sf corepop poplink
	popd


# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
Stage1.proxy: Corepops.proxy
    # DONE bash makeSystemTools.sh
	bash relinkCorepop.sh
	cp poplog_base/pop/pop/newpop11 poplog_base/pop/pop/corepop
	touch $@

SRC_WLB_SRC:=$(wildcard $(popsrc)/*.p $(popsrc)/$(POP_ARCH)/*.[ps])
SRC_WLB_HEADERS:=$(wildcard $(popsrc)/*.ph)
SRC_WLB_HEADERS+=$(addsuffix .ph,$(addprefix $(usepop)/pop/lib/include/,ast doc_index itemise pop11_flags sigdefs subsystem sysdefs unix_errno vedfile_struct vedscreendefs vm_flags))
SRC_WLB_OBJECTS:=$(patsubst %.p,%.w,$(filter %.p,$(SRC_WLB_SRC))) \
				 $(patsubst %.s,%.w,$(filter %.s,$(SRC_WLB_SRC)))
SRC_WLB_OBJECTS:=$(addprefix $(popsrc)/,$(notdir $(SRC_WLB_OBJECTS)))
SRC_WLB:=$(popobj)/src.wlb
$(SRC_WLB_OBJECTS) &: $(SRC_WLB_SRC) $(SRC_WLB_HEADERS) $(POPC)
	cd $(popsrc)
	$(RUN_POPC) -c -nosys $(POP_ARCH)/*.[ps] ./*.p

$(SRC_WLB): $(SRC_WLB_OBJECTS) $(POPLIBR)
	cd $(popsrc)
	$(RUN_POPLIBR) -c $@ $(shell realpath --relative-to $(popsrc) $(SRC_WLB_OBJECTS))


VED_WLB_SRC:=$(wildcard $(usepop)/pop/ved/src/*.p)
VED_WLB_HEADERS:=$(wildcard $(usepop)/pop/ved/src/*.ph) \
				 $(popsrc)/syspop.ph \
				 $(usepop)/pop/lib/include/ved_declare.ph \
				 $(usepop)/pop/lib/include/vedfile_struct.ph \
				 $(usepop)/pop/lib/include/vedscreendefs.ph
VED_WLB_OBJECTS:=$(patsubst %.p,%.w,$(filter %.p,$(VED_WLB_SRC)))
VED_WLB:=$(popobj)/vedsrc.wlb
$(VED_WLB_OBJECTS) &: $(VED_WLB_SRC) $(VED_WLB_HEADERS) $(POPC)
	cd $(usepop)/pop/ved/src
	$(RUN_POPC) -c -nosys -wlib \( ../../src/ \) ./*.p

$(VED_WLB): $(popobj)/src.wlb $(VED_WLB_OBJECTS) $(POPLIBR)
	cd $(usepop)/pop/ved/src
	$(RUN_POPLIBR) -c $@ ./*.w


XSRC_WLB_SRC:=$(wildcard $(usepop)/pop/x/src/*.p)
XSRC_WLB_HEADERS:=$(wildcard $(usepop)/pop/x/src/*.ph)
XSRC_WLB_OBJECTS:=$(patsubst %.p,%.w,$(filter %.p,$(XSRC_WLB_SRC)))
XSRC_WLB:=$(popobj)/xsrc.wlb
$(XSRC_WLB_OBJECTS) &: $(XSRC_WLB_SRC) $(XSRC_WLB_HEADERS) $(POPC)
	cd $(usepop)/pop/x/src
	$(RUN_POPC) -c -nosys -wlib \( ../../src/ \) ./*.p

XSRC_WLB: $(popobj)/src.wlb $(XSRC_WLB_OBJECTS) $(POPLIBR)
	cd $(usepop)/pop/x/src
	$(RUN_POPLIBR) -c $@ ./*.w

$(popsys)/newpop11: $(SRC_WLB) $(VED_WLB) $(LIBPOP) $(PGLINK)
	cd $(popsys)
	$(RUN_PGLINK) -core

.PHONY: all
all: $(popsys)/newpop11 $(LIBXPW) $(popobj)/xsrc.wlb
