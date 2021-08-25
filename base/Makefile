.SHELL :=/bin/bash
.ONESHELL:

CFLAGS=-v -Wl,-export-dynamic -Wl,-no-as-needed

.PHONEY: all
all: pop/src/syscomp/x86_64/asmout.p

.PHONEY: help
help:
	# Valid targets include:
	#
	#   all - instantiates any templated files (only pop/src/syscomp/x86_64/asmout.p at present)
	#   clean - removed any instantiated files

.PHONEY: clean
clean:
	rm -f pop/src/syscomp/x86_64/asmout.p

pop/src/syscomp/x86_64/asmout.p: pop/src/syscomp/x86_64/asmout.p.template
	src_filepath=$$(mktemp -p .)
	echo 'int main(){ return 0; }' > $$src_filepath
	NO_PIE_FLAG=""
	# check to see if compiler supports -no-pie
	if $(CC) $(CFLAGS) -no-pie -c $$src_filepath >/dev/null; then
		NO_PIE_FLAG=" -no-pie"
	fi
	sed -e "s/{{{POP__CC_OPTIONS:[^}]*}}}/$(CFLAGS)$$NO_PIE_FLAG/" < $< > $@
	rm $$src_filepath
