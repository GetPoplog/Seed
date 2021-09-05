# Makefile fragment.
#
# Assumes the following variables exist
#
# - DESTDIR
# - bindir
# - POPLOG_VERSION_DIR
# - POPLOCAL_HOME_DIR
# - SYMLINK

################################################################################
# Installation targets
################################################################################
# At the start of the installation we must be able to cope with all these use-cases.
#   1. $(POPLOG_HOME_DIR) does not exist. We will mkdir -p the folder and then install V16
#      and set the current_usepop symlink to it.
#   2. $(POPLOG_HOME_DIR) exists and does not have a copy of this distribution.
#      We will delete the symlink (if it exists) and continue as case 1.
#   3. $(POPLOG_HOME_DIR) exists and has already got a copy of this distribution. We will
#      backup the old distro to V16.origin and continue as case 1.
#   4. $(POPLOG_HOME_DIR) exists and has already got a copy of this distribution AND a backup
#      already exists in V16.orig. We will backup the V16 distro to V16.prev, and then continue
#      as case 1.
#   5. $(POPLOG_HOME_DIR) exists and has already got a copy of this distribution AND
#      a backup already exists in V16.orig AND a prev version already exists. In this case
#      we obliterate the V16.prev and continue as case 4.
.PHONY: install
install:
	[ -f $(BUILD)/Done.proxy ] # We have successfully built the new distro? Else fail!
	if [ -d $(DESTDIR)$(POPLOG_VERSION_DIR) ] \
	&& [ -d $(DESTDIR)$(POPLOG_VERSION_DIR).orig ] \
	&& [ -d $(DESTDIR)$(POPLOG_VERSION_DIR).prev ]; then \
	    rm -rf $(DESTDIR)$(POPLOG_VERSION_DIR).prev; \
	fi
	if [ -d $(DESTDIR)$(POPLOG_VERSION_DIR) ] \
	&& [ -d $(DESTDIR)$(POPLOG_VERSION_DIR).orig ]; then \
	    mv $(DESTDIR)$(POPLOG_VERSION_DIR) $(DESTDIR)$(POPLOG_VERSION_DIR).prev; \
	fi
	if [ -d $(DESTDIR)$(POPLOG_VERSION_DIR) ]; then \
	    mv $(DESTDIR)$(POPLOG_VERSION_DIR) $(DESTDIR)$(POPLOG_VERSION_DIR).orig; \
	fi
	mkdir -p $(DESTDIR)$(POPLOG_VERSION_DIR)
	( cd $(BUILD)/poplog_base; tar cf - . ) | ( cd $(DESTDIR)$(POPLOG_VERSION_DIR); tar xf - )
	cd $(DESTDIR)$(POPLOG_HOME_DIR); ln -sf $(VERSION_DIR) $(SYMLINK)
	mkdir -p $(DESTDIR)$(bindir)
	ln -sf $(POPLOG_VERSION_SYMLINK)/pop/bin/poplog $(DESTDIR)$(bindir)/
	# Target "install" completed

.PHONY: install-poplocal
install-poplocal:
	mkdir -p $(DESTDIR)$(POPLOCAL_HOME_DIR)
	( cd poplocal; tar cf - --exclude=.gitkeep . ) | ( cd $(DESTDIR)$(POPLOCAL_HOME_DIR); tar xf - . )
	# Target "install-poplocal" completed.

.PHONY: add-uninstall-instructions
add-uninstall-instructions: $(BUILD)/poplog_base/UNINSTALL_INSTRUCTIONS.md

# No messing around - this is not a version change (we don't have a target for that)
# but a complete removal of all installed Poplogs. This is potentially disasterous,
# so we make a backup and shove it in /tmp and hope that the system cleanup policy
# will clean it up eventually.
.PHONY: uninstall
uninstall:
	(cd $(POPLOG_HOME_DIR); tar cf - .) | gzip > /tmp/POPLOG_HOME_DIR.tgz
	$(MAKE) really-uninstall-poplog
	# A BACKUP HAS BEEN LEFT IN /tmp/POPLOG_HOME_DIR.tgz. REMOVE THIS TO SAVE SPACE.
	# Target "uninstall" completed

.PHONY: really-uninstall-poplog
really-uninstall-poplog:
	# A sanity check to protect against a mistake with a bad $(POPLOG_HOME_DIR).
	[ -f $(POPLOG_VERSION_DIR)/pop/com/popenv.sh ] # Can we find a characteristic file?
	# OK, let's take out the home-directory.
	rm -rf $(POPLOG_HOME_DIR)
	rm -f $(bindir)/poplog

.PHONY: verify-uninstall
verify-uninstall:
	# A sanity check that the Poplog installation has actually been removed.
	test ! -e $(POPLOG_VERSION_DIR)
	test ! -e $(bindir)/poplog

.PHONY: verify-install
verify-install:
	# A sanity check that the Poplog installation has actually been installed.
	test -d $(POPLOG_VERSION_DIR)
	test -f $(bindir)/poplog
