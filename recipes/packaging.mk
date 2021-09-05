################################################################################
# Packaging formats
################################################################################

#-- Debian *.deb packaging -----------------------------------------------------
# The following rules assume that the following dependencies are installed:
# - debmake
# - debhelper

.PHONY: deb
deb: $(BUILD)/artifacts/poplog_$(GETPOPLOG_VERSION)-1_amd64.deb

.PHONY: debsrc
debsrc: $(BUILD)/artifacts/poplog_$(GETPOPLOG_VERSION)-1.dsc $(BUILD)/artifacts/poplog_$(GETPOPLOG_VERSION)-1.tar.gz

$(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION): $(SRC_TARBALL) $(BUILD)/changelogs/CHANGELOG.debian
	mkdir -p "$@"
	rm -rf $(BUILD)/packaging/deb
	mkdir -p $(BUILD)/packaging/deb
	cp $(SRC_TARBALL) poplog_$(GETPOPLOG_VERSION).orig.tar.gz
	tar xf poplog_$(GETPOPLOG_VERSION).orig.tar.gz -C $(BUILD)/packaging/deb
	mkdir $(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION)/debian
	( cd packaging/deb && tar cf - . ) | ( cd $(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION)/debian && tar xf - )
	cp $(BUILD)/changelogs/CHANGELOG.debian $(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION)/debian/changelog

$(BUILD)/artifacts/poplog_$(GETPOPLOG_VERSION)-1_amd64.deb: $(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION)
	mkdir -p "$(@D)"
	cd $(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION) && debuild --no-lintian -i -us -uc -b
	mv $(BUILD)/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1_amd64.deb "$@"


$(BUILD)/artifacts/poplog_$(GETPOPLOG_VERSION)-1.dsc $(BUILD)/artifacts/poplog_$(GETPOPLOG_VERSION)-1.tar.gz &: $(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION)
	mkdir -p "$(@D)"
	cd $(BUILD)/packaging/deb/poplog-$(GETPOPLOG_VERSION) && dpkg-source -b .
	# https://en.opensuse.org/openSUSE:Build_Service_Debian$(BUILD)s#DEBTRANSFORM_tags
	# The following additional line is used by OBS to pick up the
	# correct tar.gz file. Without this additional field in the .dsc
	# file, OBS is unable to determine which file to use to build the
	# deb.
	echo "Debtransform-Tar: poplog-$(GETPOPLOG_VERSION).tar.gz" >> $(BUILD)/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1.dsc
	mv $(BUILD)/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1.dsc "$(@D)"
	mv $(BUILD)/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1.tar.gz "$(@D)"

#-- Redhat *.rpm packaging -----------------------------------------------------

.PHONY: rpm
rpm: $(BUILD)/artifacts/poplog-$(GETPOPLOG_VERSION)-1.x86_64.rpm

$(BUILD)/packaging/rpm/poplog.spec: packaging/rpm/poplog.spec.tmpl
	mkdir -p "$(@D)"
	cp "$<" "$@"
	sed -i 's/&VERSION&/$(GETPOPLOG_VERSION)/g' "$@"

$(BUILD)/artifacts/poplog-$(GETPOPLOG_VERSION)-1.x86_64.rpm: $(BUILD)/packaging/rpm/poplog.spec $(SRC_TARBALL)
	mkdir -p "$(@D)"
	rm -rf $(BUILD)/packaging/rpm/rpmbuild && mkdir -p $(BUILD)/packaging/rpm/rpmbuild
	cd $(BUILD)/packaging/rpm/rpmbuild && mkdir -p BUILD BUILDROOT RPMS SOURCES SPECS SRPMS
	cp "$(SRC_TARBALL)" $(BUILD)/packaging/rpm/rpmbuild/SOURCES/
	cd $(BUILD)/packaging/rpm && rpmbuild --define "_topdir `pwd`/rpmbuild" -bb poplog.spec
	mv $(BUILD)/packaging/rpm/rpmbuild/RPMS/x86_64/poplog-$(GETPOPLOG_VERSION)-1.x86_64.rpm "$@"  # mv is safe - rpmbuild is idempotent

#-- AppImage *.AppImage packaging ----------------------------------------------

.PHONY: dotappimage
dotappimage: $(BUILD)/Poplog-x86_64.AppImage

$(BUILD)/Poplog-x86_64.AppImage: $(BINARY_TARBALL)
	$(MAKE) buildappimage
	[ -f $@ ] # Sanity check that we built the target

# We need a target that the CircleCI script can use for a process that assumes
# BINARY_TARBALL exists and doesn't try to rebuild anything.
.PHONY: buildappimage
buildappimage: _download/appimagetool
	[ -f "$(BINARY_TARBALL)" ] # Enforce required tarball
	rm -rf $(BUILD)/AppDir
	mkdir -p $(BUILD)/AppDir
	( cd AppDir; tar cf - . ) | ( cd $(BUILD)/AppDir; tar xf - )
	mkdir -p $(BUILD)/AppDir$(POPLOG_VERSION_DIR)
	tar zxf "$(BINARY_TARBALL)" -C $(BUILD)/AppDir$(POPLOG_VERSION_DIR)
	mkdir -p $(BUILD)/AppDir/usr/lib
	# List the libraries needed (for debugging)
	ldd $(BUILD)/AppDir$(POPLOG_VERSION_DIR)/pop/pop/basepop11
	# Now create the local copies of the libraries
	for i in `ldd $(BUILD)/AppDir$(POPLOG_VERSION_DIR)/pop/pop/basepop11 | grep -v 'not found' | grep ' => ' | cut -f 3 -d ' '`; do \
		cp -p `realpath $$i` $(BUILD)/AppDir/usr/lib/`basename $$i`; \
	done
	# But we want to exclude libc and libdl.
	cd $(BUILD)/AppDir/usr/lib/; rm -f libc* libdl.*
	# Now to create systematically re-named symlinks.
	cd $(BUILD)/AppDir/usr/lib; for i in *.so.*; do ln -s $$i `echo "$$i" | sed 's/\.so\.[^.]*$$/.so/'`; done
	chmod a-w $(BUILD)/AppDir/usr/lib/*
	mkdir -p $(BUILD)/AppDir/usr/bin
	cd $(BUILD)/AppDir/usr/bin; ln -s ../..$(POPLOG_VERSION_DIR)/pop/bin/poplog .
	cd $(BUILD) && ARCH=x86_64 ../_download/appimagetool AppDir


#-- Snap (Ubuntu) *.snap packaging ---------------------------------------------
# See https://circleci.com/blog/circleci-and-snapcraft/

.PHONY: dotsnap
dotsnap: $(BUILD)/dotsnap/poplog_16.0.1_amd64.snap

$(BUILD)/dotsnap/poplog_16.0.1_amd64.snap: "$(BINARY_TARBALL)"
	$(MAKE) buildsnap
	[ -f $@ ] # Sanity check that we built the target

.PHONY: buildsnap
buildsnap:
	$(MAKE) buildsnapcraftready
	cd $(BUILD)/dotsnap; snapcraft

PREBUILT_DIR:=/prebuilt

.PHONY: buildsnapcraftready
buildsnapcraftready:
	[ -f "$(BINARY_TARBALL)" ] # Enforce required tarball
	mkdir -p $(BUILD)/dotsnap$(PREBUILT_DIR)$(POPLOG_VERSION_DIR)
	mkdir -p $(BUILD)/dotsnap$(PREBUILT_DIR)/usr/bin
	cat "$(BINARY_TARBALL)" | ( cd $(BUILD)/dotsnap$(PREBUILT_DIR)$(POPLOG_VERSION_DIR); tar zxf - )
	cd $(BUILD)/dotsnap$(PREBUILT_DIR)/usr/bin; ln -s ../..$(POPLOG_VERSION_DIR)/pop/bin/poplog .
	cp snapcraft.yaml $(BUILD)/dotsnap

