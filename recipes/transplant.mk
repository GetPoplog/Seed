################################################################################
# Transplant targets
################################################################################
# The transplant target is useful to get the $(BUILD) folder fully
# built and then the whole GetPoplog-tree is captured as a tarball.
# This is used on host X in order to relink on host Y. The process
# is as follows:
#   On host X
#       make transplant
#       scp $(BUILD)/transplant-getpoplog.tgz $hostY:transplant-getpoplog.tgz
#   On host Y
#       mkdir Seed
#       cd Seed
#       tar zxf ../transplant-getpoplog.tgz
#       make relink-and-build
#
.PHONY: transplant
transplant: $(BUILD)/transplant-getpoplog.tgz
	true

$(BUILD)/transplant-getpoplog.tgz: $(BUILD)/Done.proxy
	TMPFILE=`mktemp` \
	; echo TMPFILE=$$TMPFILE \
	; ( tar cf - . | gzip ) > "$$TMPFILE" \
	; mv "$$TMPFILE" $@

# If no valid corepop image is found in Corepops then the normal
# build process will stop. Quite often it is sufficient to relink
# on the new system and then the process can be restarted. This
# target assists with that process.
#
# Start on a host X on which GetPoplog successfully builds. Copy
# the whole GetPoplog-tree onto the new host Y. (One way to do that
# is to use the phony target `transplant`, which leaves
# its result in $(BUILD)/transplant-getpoplog.tgz.)
#
# Once the GetPoplog-tree assives on host Y, use this target
# to attempt the relinking of a new Poplog executable on host Y.
# If this generates a working 'corepop' image then the normal
# build process is attempted with the new image substituted.
.PHONY: relink-and-build
relink-and-build:
	[ -f $(BUILD)/Done.proxy ] # Sanity check that we are starting from a pre-built tree.
	export usepop=$(abspath ./$(BUILD)/poplog_base) \
        && . ./$(BUILD)/poplog_base/pop/com/popinit.sh \
        && cd $$popsys \
        && $$usepop/pop/pop/poplink_cmnd
	output=`./$(BUILD)/poplog_base/pop/pop/newpop11 ":sysexit()" 2>&1` && [ -z "$$output" ] # Check the rebuilt newpop11 works
	mv $(BUILD)/poplog_base/pop/pop/newpop11 .
	$(MAKE) clean && $(MAKE) $(BUILD)/Base.proxy
	mv newpop11 $(BUILD)/poplog_base/pop/pop/corepop
	$(MAKE) build

