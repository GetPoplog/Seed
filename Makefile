POP__CC_OPTIONS=-v -no-pie -Wl,-export-dynamic -Wl,-no-as-needed

.PHONEY: help
help:
	# Valid targets include:
	#
	#   build - instantiates any templated files
	#   build-without-no-pie - instantiates any templated files if -no-pie option unavailable
	#   clean - removed any instantiated files
	#

.PHONEY: clean
clean:
	rm -f pop/src/syscomp/x86_64/asmout.p

.PHONEY: build
build: pop/src/syscomp/x86_64/asmout.p

.PHONEY: build-without-no-pie
build-without-no-pie: POP__CC_OPTIONS=-v -Wl,-export-dynamic -Wl,-no-as-needed
build-without-no-pie: pop/src/syscomp/x86_64/asmout.p


pop/src/syscomp/x86_64/asmout.p: pop/src/syscomp/x86_64/asmout.p.template
	sed -e 's/{{{POP__CC_OPTIONS:[^}]*}}}/$(POP__CC_OPTIONS)/' < $< > $@


