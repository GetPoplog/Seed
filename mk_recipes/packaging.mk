$(call check_defined, GETPOPLOG_VERSION)
$(call check_defined, SRC_TARBALL)
$(call check_defined, BINARY_TARBALL)
$(call check_defined, POPLOG_VERSION_DIR)

################################################################################
# Packaging formats
################################################################################

#-- Debian *.deb packaging -----------------------------------------------------
# The following rules assume that the following dependencies are installed:
# - debmake
# - debhelper

.PHONY: deb
deb: _build/artifacts/poplog_$(GETPOPLOG_VERSION)-1_amd64.deb

.PHONY: debsrc
debsrc: _build/artifacts/poplog_$(GETPOPLOG_VERSION)-1.dsc _build/artifacts/poplog_$(GETPOPLOG_VERSION)-1.tar.gz

_build/packaging/deb/poplog-$(GETPOPLOG_VERSION): $(SRC_TARBALL) _build/changelogs/CHANGELOG.debian
	mkdir -p "$@"
	rm -rf _build/packaging/deb
	mkdir -p _build/packaging/deb
	cp $(SRC_TARBALL) poplog_$(GETPOPLOG_VERSION).orig.tar.gz
	tar xf poplog_$(GETPOPLOG_VERSION).orig.tar.gz -C _build/packaging/deb
	mkdir _build/packaging/deb/poplog-$(GETPOPLOG_VERSION)/debian
	( cd packaging/deb && tar cf - . ) | ( cd _build/packaging/deb/poplog-$(GETPOPLOG_VERSION)/debian && tar xf - )
	cp _build/changelogs/CHANGELOG.debian _build/packaging/deb/poplog-$(GETPOPLOG_VERSION)/debian/changelog

_build/artifacts/poplog_$(GETPOPLOG_VERSION)-1_amd64.deb: _build/packaging/deb/poplog-$(GETPOPLOG_VERSION)
	mkdir -p "$(@D)"
	( cd _build/packaging/deb/poplog-$(GETPOPLOG_VERSION) && debuild --no-lintian -i -us -uc -b )
	mv _build/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1_amd64.deb "$@"


_build/artifacts/poplog_$(GETPOPLOG_VERSION)-1.dsc _build/artifacts/poplog_$(GETPOPLOG_VERSION)-1.tar.gz &: _build/packaging/deb/poplog-$(GETPOPLOG_VERSION)
	mkdir -p "$(@D)"
	( cd _build/packaging/deb/poplog-$(GETPOPLOG_VERSION) && dpkg-source -b . )
	# https://en.opensuse.org/openSUSE:Build_Service_Debian_builds#DEBTRANSFORM_tags
	# The following additional line is used by OBS to pick up the
	# correct tar.gz file. Without this additional field in the .dsc
	# file, OBS is unable to determine which file to use to build the
	# deb.
	echo "Debtransform-Tar: poplog-$(GETPOPLOG_VERSION).tar.gz" >> _build/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1.dsc
	mv _build/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1.dsc "$(@D)"
	mv _build/packaging/deb/poplog_$(GETPOPLOG_VERSION)-1.tar.gz "$(@D)"

#-- Redhat *.rpm packaging -----------------------------------------------------

.PHONY: rpm
rpm: _build/artifacts/poplog-$(GETPOPLOG_VERSION)-1.x86_64.rpm

_build/packaging/rpm/poplog.spec: packaging/rpm/poplog.spec.tmpl
	mkdir -p "$(@D)"
	cp "$<" "$@"
	sed -i 's/&VERSION&/$(GETPOPLOG_VERSION)/g' "$@"

_build/artifacts/poplog-$(GETPOPLOG_VERSION)-1.x86_64.rpm: _build/packaging/rpm/poplog.spec $(SRC_TARBALL)
	mkdir -p "$(@D)"
	rm -rf _build/packaging/rpm/rpmbuild && mkdir -p _build/packaging/rpm/rpmbuild
	( cd _build/packaging/rpm/rpmbuild && mkdir -p BUILD BUILDROOT RPMS SOURCES SPECS SRPMS )
	cp "$(SRC_TARBALL)" _build/packaging/rpm/rpmbuild/SOURCES/
	( cd _build/packaging/rpm && rpmbuild --define "_topdir `pwd`/rpmbuild" -bb poplog.spec )
	mv _build/packaging/rpm/rpmbuild/RPMS/x86_64/poplog-$(GETPOPLOG_VERSION)-1.x86_64.rpm "$@"  # mv is safe - rpmbuild is idempotent

#-- AppImage *.AppImage packaging ----------------------------------------------

.PHONY: dotappimage
dotappimage: _build/Poplog-x86_64.AppImage

_build/Poplog-x86_64.AppImage: $(BINARY_TARBALL)
	$(MAKE) buildappimage
	[ -f $@ ] # Sanity check that we built the target

# We need a target that the CircleCI script can use for a process that assumes
# BINARY_TARBALL exists and doesn't try to rebuild anything.
.PHONY: buildappimage
buildappimage: _download/appimagetool
	[ -f "$(BINARY_TARBALL)" ] # Enforce required tarball
	rm -rf _build/AppDir
	mkdir -p _build/AppDir
	( cd AppDir; tar cf - . ) | ( cd _build/AppDir; tar xf - )
	mkdir -p _build/AppDir$(POPLOG_VERSION_DIR)
	tar zxf "$(BINARY_TARBALL)" -C _build/AppDir$(POPLOG_VERSION_DIR)
	mkdir -p _build/AppDir/usr/lib
	# List the libraries needed (for debugging)
	ldd _build/AppDir$(POPLOG_VERSION_DIR)/pop/pop/basepop11
	# Now create the local copies of the libraries
	for i in `ldd _build/AppDir$(POPLOG_VERSION_DIR)/pop/pop/basepop11 | grep -v 'not found' | grep ' => ' | cut -f 3 -d ' '`; do \
		cp -p `realpath $$i` _build/AppDir/usr/lib/`basename $$i`; \
	done
	# But we want to exclude libc and libdl.
	( cd _build/AppDir/usr/lib/; rm -f libc* libdl.* )
	# Now to create systematically re-named symlinks.
	( cd _build/AppDir/usr/lib; for i in *.so.*; do ln -s $$i `echo "$$i" | sed 's/\.so\.[^.]*$$/.so/'`; done )
	chmod a-w _build/AppDir/usr/lib/*
	mkdir -p _build/AppDir/usr/bin
	( cd _build/AppDir/usr/bin; ln -s ../..$(POPLOG_VERSION_DIR)/pop/bin/poplog . )
	( cd _build && ARCH=x86_64 ../_download/appimagetool AppDir )


#-- Snap (Ubuntu) *.snap packaging ---------------------------------------------
# See https://circleci.com/blog/circleci-and-snapcraft/

.PHONY: dotsnap
dotsnap: _build/dotsnap/poplog_16.0.1_amd64.snap

_build/dotsnap/poplog_16.0.1_amd64.snap: "$(BINARY_TARBALL)"
	$(MAKE) buildsnap
	[ -f $@ ] # Sanity check that we built the target

.PHONY: buildsnap
buildsnap:
	$(MAKE) buildsnapcraftready
	( cd _build/dotsnap; snapcraft )

PREBUILT_DIR:=/prebuilt

.PHONY: buildsnapcraftready
buildsnapcraftready:
	[ -f "$(BINARY_TARBALL)" ] # Enforce required tarball
	mkdir -p _build/dotsnap$(PREBUILT_DIR)$(POPLOG_VERSION_DIR)
	mkdir -p _build/dotsnap$(PREBUILT_DIR)/usr/bin
	cat "$(BINARY_TARBALL)" | ( cd _build/dotsnap$(PREBUILT_DIR)$(POPLOG_VERSION_DIR); tar zxf - )
	( cd _build/dotsnap$(PREBUILT_DIR)/usr/bin; ln -s ../..$(POPLOG_VERSION_DIR)/pop/bin/poplog . )
	cp snapcraft.yaml _build/dotsnap


