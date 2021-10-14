# This Makefile is meant to invoked directly and not included.

# Causes the commands in a recipe to be issued in the same shell
.ONESHELL:
SHELL:=/bin/bash
.SHELLFLAGS:=-e -o pipefail -c
.DEFAULT_GOAL:=all
.DELETE_ON_ERROR:
.SUFFIXES:

POP_X_CONFIG?=xm
POP_ARCH=x86_64
export POP__as?=/usr/bin/as
export usepop=$(shell pwd)/poplog_base
export popsys:=$(usepop)/pop/pop
popsrc:=$(usepop)/pop/src
popcom:=$(usepop)/pop/com
popobjlib:=$(usepop)/pop/obj
popsavelib:=$(usepop)/pop/lib/psv
poppackages:=$(usepop)/pop/packages

COREPOP:=$(popsys)/corepop
POPC:=$(popsys)/popc
POPLIBR:=$(popsys)/poplibr
POPLINK:=$(popsys)/poplink
PGLINK:=$(popsys)/pglink

MK_CROSS:=$(shell pwd)/../mk_cross
RUN_POPC:=source $(popcom)/popinit.sh && $(POPC)
RUN_POPLIBR:=source $(popcom)/popinit.sh && $(POPLIBR)
RUN_PGLINK:=source $(popcom)/popinit.sh && $(PGLINK)
RUN_MKIMAGE:=cd $$popsys && source $(popcom)/popinit.sh && ./pop11 %nort %noinit ../lib/lib/mkimage.p

ifeq ($(POP_X_CONFIG),xm)
PGLINK_X_FLAG:=-xm
else ifeq ($(POP_X_CONFIG),xt)
PGLINK_X_FLAG:=-xt
else ifeq ($(POP_X_CONFIG),nox)
PGLINK_X_FLAG:=-nox
else
$(error Invalid POP_X_CONFIG setting '$(POP_X_CONFIG)', please set one of: 'xm', 'xt', 'nox')
endif


# GUARD is a function which calculates md5sum for its argument variable name.
# Used to make a target depend on the value of a variable
# Taken from https://stackoverflow.com/questions/11647859/make-targets-depend-on-variables
GUARD = $(1)_GUARD_$(shell echo $($(1)) | md5sum | cut -d ' ' -f 1)

POP_X_CONFIG_FILE:=$(call GUARD,POP_X_CONFIG)
$(POP_X_CONFIG_FILE):
	rm -rf POP_X_CONFIG*
	touch $@

$(popsrc)/syscomp/$(POP_ARCH)/asmout.p: $(popsrc)/syscomp/$(POP_ARCH)/asmout.p.template
	trap "rm -f test.c" EXIT
	echo 'void test(){}' > test.c
	if `(/usr/bin/gcc -no-pie -c test.c 2>&1)`; then
		POP__CC_OPTIONS="-v -no-pie -Wl,-export-dynamic -Wl,-no-as-needed"
	else
		POP__CC_OPTIONS="-v -Wl,-export-dynamic -Wl,-no-as-needed"
	fi
	test ! -z "$$POP__CC_OPTIONS" # ensure variable was set in previous block
	# Substitute the template-parameter that looks like
	# {{{POP__CC_OPTIONS:_random_text_}}} with the compiler options.
	sed -e "s/{{{POP__CC_OPTIONS:[^}]*}}}/$$POP__CC_OPTIONS/" < $< > $@


LIBPOP_SRC:=$(addprefix $(usepop)/pop/extern/lib/,\
			c_bignum.c c_callback.c c_core.c c_sysinit.c \
			ext_arm.c pop_encoding.c pop_poll.c pop_stat.c \
			pop_timer.c XtPoplog.c)
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


$(POPLINK): $(POPLINK).psv $(COREPOP)
	cd $(popsys)
	ln -sf corepop poplink

$(POPC): $(POPC).psv $(COREPOP)
	cd $(popsys)
	ln -sf corepop popc

$(POPLIBR): $(POPLIBR).psv
	cd $(popsys)
	ln -sf corepop poplibr

POP_COMPILER_TOOLS:=$(POPC) $(POPLIBR) $(POPLINK)
POP_COMPILER_TOOL_IMAGES:=$(addsuffix .psv,$(POP_COMPILER_TOOLS))
$(POP_COMPILER_TOOL_IMAGES) &: $(COREPOP) $(popsrc)/syscomp/$(POP_ARCH)/asmout.p ../mk_cross
	. "$(usepop)/pop/com/popinit.sh"
	export usepop
	export POP__as
	cd $(popsrc)
	rm -f ./{popc,poplibr,poplink}.psv*
	$(MK_CROSS) -d -a=$(POP_ARCH) popc poplibr poplink

SRC_WLB_SRC:=$(wildcard $(popsrc)/*.p $(popsrc)/$(POP_ARCH)/*.[ps])
SRC_WLB_HEADERS:=$(wildcard $(popsrc)/*.ph)
SRC_WLB_HEADERS+=$(addsuffix .ph,$(addprefix $(usepop)/pop/lib/include/,ast doc_index itemise pop11_flags sigdefs subsystem sysdefs unix_errno vedfile_struct vedscreendefs vm_flags))
SRC_WLB_OBJECTS:=$(patsubst %.p,%.w,$(filter %.p,$(SRC_WLB_SRC))) \
				 $(patsubst %.s,%.w,$(filter %.s,$(SRC_WLB_SRC)))
SRC_WLB_OBJECTS:=$(addprefix $(popsrc)/,$(notdir $(SRC_WLB_OBJECTS)))
SRC_WLB:=$(popobjlib)/src.wlb
$(SRC_WLB_OBJECTS) &: $(SRC_WLB_SRC) $(SRC_WLB_HEADERS) $(POPC)
	cd $(popsrc)
	rm -f $@
	$(RUN_POPC) -c -nosys $(POP_ARCH)/*.[ps] ./*.p

$(SRC_WLB): $(SRC_WLB_OBJECTS) $(POPLIBR)
	cd $(popsrc)
	rm -f $@
	$(RUN_POPLIBR) -c $@ $(shell realpath --relative-to $(popsrc) $(SRC_WLB_OBJECTS))


VED_WLB_SRC:=$(wildcard $(usepop)/pop/ved/src/*.p)
VED_WLB_HEADERS:=$(wildcard $(usepop)/pop/ved/src/*.ph) \
				 $(popsrc)/syspop.ph \
				 $(usepop)/pop/lib/include/ved_declare.ph \
				 $(usepop)/pop/lib/include/vedfile_struct.ph \
				 $(usepop)/pop/lib/include/vedscreendefs.ph
VED_WLB_OBJECTS:=$(patsubst %.p,%.w,$(filter %.p,$(VED_WLB_SRC)))
VED_WLB:=$(popobjlib)/vedsrc.wlb
$(VED_WLB_OBJECTS) &: $(VED_WLB_SRC) $(VED_WLB_HEADERS) $(POPC)
	cd $(usepop)/pop/ved/src
	rm -f $@
	$(RUN_POPC) -c -nosys -wlib \( ../../src/ \) ./*.p

$(VED_WLB): $(popobjlib)/src.wlb $(VED_WLB_OBJECTS) $(POPLIBR)
	cd $(usepop)/pop/ved/src
	rm -f $@
	$(RUN_POPLIBR) -c $@ ./*.w

ifneq ($(POP_X_CONFIG),nox)
XPW_TARGET=$(LIBXPW)
endif
XSRC_WLB_SRC:=$(wildcard $(usepop)/pop/x/src/*.p)
XSRC_WLB_HEADERS:=$(wildcard $(usepop)/pop/x/src/*.ph)
XSRC_WLB_OBJECTS:=$(patsubst %.p,%.w,$(filter %.p,$(XSRC_WLB_SRC)))
XSRC_WLB:=$(popobjlib)/xsrc.wlb
$(XSRC_WLB_OBJECTS) &: $(XSRC_WLB_SRC) $(XSRC_WLB_HEADERS) $(XPW_TARGET) $(POPC)
	cd $(usepop)/pop/x/src
	rm -f $@
	$(RUN_POPC) -c -nosys -wlib \( ../../src/ \) ./*.p

$(XSRC_WLB): $(popobjlib)/src.wlb $(XSRC_WLB_OBJECTS) $(POPLIBR)
	cd $(usepop)/pop/x/src
	rm -f $@
	$(RUN_POPLIBR) -c $@ ./*.w


.PHONY: corepop
corepop: $(popsys)/new_corepop
$(popsys)/new_corepop: $(LIBPOP) $(SRC_WLB) $(PGLINK) $(POP_COMPILER_TOOLS) 
	cd $(popsys)
	$(RUN_PGLINK) -core
	mv newpop11 $@

ifneq ($(POP_X_CONFIG),nox)
XSRC_TARGET=$(XSRC_WLB)
endif
$(addprefix $(popsys)/,pop11 basepop11 basepop11.stb basepop11.map) &: $(XSRC_TARGET) $(SRC_WLB) $(VED_WLB) $(LIBPOP) $(PGLINK) $(POP_COMPILER_TOOLS) $(POP_X_CONFIG_FILE)
	cd $(popsys)
	$(RUN_PGLINK) $(PGLINK_X_FLAG) -map
	mv newpop11 basepop11
	mv newpop11.map basepop11.map
	mv newpop11.stb basepop11.stb
	ln -sf basepop11 pop11
	ln -f basepop11 ved

$(popsavelib)/startup.psv: $(popsys)/basepop11
	source $(popcom)/popinit.sh && cd $$popsys && ./basepop11 %nort %noinit ../lib/lib/mkimage.p -nodebug -nonwriteable -install $@ startup

$(popsavelib)/clisp.psv: $(popsys)/pop11 $(popsavelib)/startup.psv $(popsys)/popenv.sh
	@rm -f $@
	cd $(popsys)
	ln -f basepop11 clisp
	$(RUN_MKIMAGE) -install -subsystem lisp $@ ../lisp/src/clisp.p

$(popsavelib)/prolog.psv: $(popsys)/pop11 $(popsavelib)/startup.psv $(popsys)/popenv.sh
	@rm -f $@
	cd $(popsys)
	ln -f basepop11 prolog
	$(RUN_MKIMAGE) -nodebug -install -flags prolog \( \) $@ ../plog/src/prolog.p

$(popsavelib)/pml.psv: $(popsys)/pop11 $(popsavelib)/startup.psv $(popsys)/popenv.sh
	@rm -f $@
	cd $(popsys)
	ln -f basepop11 pml
	$(RUN_MKIMAGE) -nodebug -install -flags ml \( \) $@ ../pml/src/ml.p

.PHONY: images
images: $(addsuffix .psv,$(addprefix $(popsavelib)/,startup clisp prolog pml))

ifneq ($(POP_X_CONFIG),nox)
$(popsavelib)/xved.psv: $(popsys)/pop11 $(popsavelib)/startup.psv $(popsys)/popenv.sh
	@rm -f $@
	cd $(popsys)
	ln -f basepop11 xved
	$(RUN_MKIMAGE) -nodebug -nonwriteable -install -entry xved_standalone_setup $@ mkxved
images: $(popsavelib)/xved.psv
endif



$(popsys)/popenv.sh: ../makePopEnv.sh $(POP_X_CONFIG_FILE) $(popsavelib)/startup.psv
	../makePopEnv.sh $@ $(if $(filter nox,$(POP_X_CONFIG)),false,true)

COMMAND_TARGETS:=$(addsuffix .psv,$(addprefix $(popsavelib)/,clisp pml prolog))
ifneq ($(POP_X_CONFIG),nox)
COMMAND_TARGETS+=$(popsavelib)/xved.psv
endif

environments/$(POP_X_CONFIG)-base0: $(COMMAND_TARGETS) ../echoEnv.sh
	../echoEnv.sh $$PWD/poplog_base $(POP_X_CONFIG) "$@"

environments/$(POP_X_CONFIG)-base0-cmp: $(COMMAND_TARGETS) ../echoEnv.sh $(popsys)/popenv.sh
	../echoEnv.sh $$PWD/poplog_base/pop/.. $(POP_X_CONFIG) "$@"

.PHONY: build_envs
build_envs: environments/$(POP_X_CONFIG)-base0 environments/$(POP_X_CONFIG)-base0-cmp

NEURAL_DIR:=$(poppackages)/neural
NEURAL_LIB_DIR:=$(NEURAL_DIR)/bin/linux
NEURAL_SRC_DIR:=$(NEURAL_DIR)/src/c
NEURAL_LIBS:=$(addprefix $(NEURAL_LIB_DIR)/,backprop.so complearn.so ranvecs.so)
$(NEURAL_LIBS): CFLAGS+=-I$(NEURAL_SRC_DIR) -O3 -fpic -shared
$(NEURAL_LIBS): $(NEURAL_LIB_DIR)/%.so: $(NEURAL_SRC_DIR)/%.c $(NEURAL_SRC_DIR)/neural.h
	$(CC) $(CFLAGS) -o $@ $<

VISION_DIR:=$(poppackages)/popvision
VISION_SRC_DIR:=$(VISION_DIR)/lib
VISION_LIB_DIR:=$(VISION_DIR)/lib/bin/linux
VISION_LIBS:=$(addsuffix .so,$(notdir $(wildcard $(VISION_LIB_DIR)/*.c)))
$(VISION_LIBS): CFLAGS+=-I$(VISION_LIB_DIR) -O3 -fpic -shared
$(VISION_LIBS): $(VISION_LIB_DIR)/%.so: $(VISION_SRC_DIR)/%.c $(addprefix $(VISION_SRC_DIR)/,arrpack.h arrscan.h)
	$(CC) $(CFLAGS) -o $@ $<

PackagesNativeExtensions.proxy: $(NEURAL_LIBS) $(VISION_LIBS)
	touch $@

.PHONY: all
all: $(popsys)/pop11 $(COMMAND_TARGETS) build_envs PackagesNativeExtensions.proxy
