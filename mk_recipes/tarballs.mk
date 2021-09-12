$(call check_defined, SRC_TARBALL)
$(call check_defined, SRC_TARBALL_FILENAME)
$(call check_defined, BINARY_TARBALL)
$(call check_defined, BINARY_TARBALL_FILENAME)
$(call check_defined, TMP_DIR)
################################################################################
# Source tarball targets
################################################################################
.PHONY: srctarball
srctarball: $(SRC_TARBALL)

$(SRC_TARBALL): _download/packages-V$(MAJOR_VERSION).tar.bz2 _download/poplogout.sh _download/poplogout.csh
	mkdir -p "$(@D)"
	rm -f "$@"; \
	ASSEMBLY_DIR="$$(umask u=rwx,go=r && mktemp --directory --tmpdir="$(TMP_DIR)")"; \
	POPLOG_TAR_DIR="$$ASSEMBLY_DIR/$(SRC_TARBALL_FILENAME)"; \
	mkdir -p "$$POPLOG_TAR_DIR"; \
	tar cf - --exclude=_build . | ( cd $$POPLOG_TAR_DIR && tar xf - ); \
	tar -C "$$ASSEMBLY_DIR" -czf "$@" "$(SRC_TARBALL_FILENAME)"; \
	rm -rf "$$ASSEMBLY_DIR"

.PHONY: binarytarball
binarytarball: $(BINARY_TARBALL)

# Pop-tree: can be untarred and used directly (as an alternative to
# installing via a poplog package e.g. deb/rpm etc)
$(BINARY_TARBALL): _build/Done.proxy
	mkdir -p "$(@D)"
	( cd _build/poplog_base/; tar cf - pop ) | gzip > $@
	[ -f $@ ] # Sanity check that we built the target
