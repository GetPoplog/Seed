.PHONEY: help
help:
	# Valid targets include:
	#
	#   build - instantiates any templated files (only pop/src/syscomp/x86_64/asmout.p at present)
	#   clean - removed any instantiated files
	#

.PHONEY: clean
clean:
	rm -f pop/src/syscomp/x86_64/asmout.p
	rm -rf _build


.PHONEY: build
build: 
	mkdir -p _build
	echo 'void test(){}' > _build/test.c
	if `(cd _build; /usr/bin/gcc -no-pie -c test.c 2>&1)`; then make buildNoPie; else make buildWithoutNoPie; fi

.PHONEY: buildWithoutNoPie
buildWithoutNoPie: POP__CC_OPTIONS=-v -Wl,-export-dynamic -Wl,-no-as-needed
buildWithoutNoPie: pop/src/syscomp/x86_64/asmout.p
	true

.PHONEY: buildNoPie
buildNoPie: POP__CC_OPTIONS=-v -no-pie -Wl,-export-dynamic -Wl,-no-as-needed
buildNoPie: pop/src/syscomp/x86_64/asmout.p
	true

# Must be called without buildWithoutNoPie or buildNoPie. The sed command
# is used to replace a template-parameter that looks like {{{POP__CC_OPTIONS:_random_text_}}}.
pop/src/syscomp/x86_64/asmout.p: pop/src/syscomp/x86_64/asmout.p.template
	test ! -z "$(POP__CC_OPTIONS)" # Protect against being called from the wrong context.
	sed -e 's/{{{POP__CC_OPTIONS:[^}]*}}}/$(POP__CC_OPTIONS)/' < $< > $@

