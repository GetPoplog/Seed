# This is a makefile that can be used to acquire Poplog, build and install it locally.
# It will be installed into $(POPLOG_HOME_DIR), which is by default /usr/local/poplog.
# This folder supports multiple versions via the symlink current_usepop.
# 
# e.g   /usr/local/poplog
#           Makefile            <- this file
#           current_usepop      <- symlink to the currently active Poplog version e.g. versions/V16
#           versions/V16        <- an example  Poplog system
#
# For help on how to use this Makefile please try "make help". The rest of this intro explains
# the strategy used for the fairly elaborate build process.
#
# The build process involves quite a lot of compilation and linking in-place, unfortunately.
# So this Makefile is driven by the creation of 'proxy files' in the _build folder. Each proxy
# files stands for the completion of a major phase of the build process.
#
# Proxy files:
#
#     _build/Base.proxy
#         This file is a script that represents the successful copying of the Base system
#         after its own Makefile has been successfully run.
#
#     _build/Corepops.proxy
#         This file represents the download of the Corepops repo and the
#         discovery of a viable executable. This should be sufficient to reconstruct working
#         system tools.
#
#     _build/Stage1.proxy
#         This file represents that the system-tools (popc, poplink, poplibr) are now
#         working and have been used to build a fresh corepop, which is in
#         _build/poplog_base/pop/pop/newpop11 and moved to corepop.
#
#     _build/Newpop.proxy
#         After Stage1, we need to get the critical newpop command working on top of
#         the fresh corepop we just built. This file signals that it has been built
#         successfully.
#
#     _build/Stage2.proxy
#         This file represents a complete rebuilt Poplog system using the newpop
#         command and the full set of object files. It includes:
#             - basepop11 and all links to it in $popsys
#             - all system images (prolog.psv, clisp.psv etc).
#         It does not include documentation or Aaron Sloman's packages extension.
#         And by implication it does not include the doc indexes.
#
#     _build/Packages.proxy
#         This represents the addition of the additional packages library
#         curated by Aaron Sloman into the build-tree.
#
#     _build/MakeIndexes.proxy
#         Making indexes should be a very late stage as it will build index
#         files all over the place. The limitation of building index files statically
#         is a nuisance and it would be nice to replace this with a more
#         dynamic system so that user libraries automatically get added into
#         the search.
#
#     _build/PoplogCommander.proxy
#         This represents the successful compilation of the commander-tool
#         and its insertion into the Poplog-tree.
#
#     _build/Done.proxy
#         This file represents the completion of the build-tree in the
#         _build/poplog_base folder. This can be moved to the appropriate 
#         place.
#

# CONVENTION: If we want to allow the user of the Makefile to set via the CLI 
# then we use ?= to bind it. If it's an internal variables then we use :=

# The PREFIX variable is used to set up POPLOG_HOME_DIR and EXEC_DIR (and 
# nowhere else, please). It is provided in order to fit in with the conventions 
# of Makefiles. 
DESTDIR?=
PREFIX?=$(DESTDIR)/usr/local

# This is the folder in which the new Poplog build will be installed. To install Poplog 
# somewhere different, such as /opt/poplog either edit this line or try:
#     make install POPLOG_HOME_DIR=/opt/poplog
# Resulting values would be:
#	POPLOG_HOME_DIR 			/opt/poplog        		$usepop/..
#	POPLOG_VERSION_DIR			/opt/poplog/V16			$usepop
#	POPLOG_VERSION_SYMLINK		/opt/poplog/current_usepop -> /opt/poplog/V16
#   POPLOCAL_HOME_DIR           /opt/poplog				$poplocal = $usepop/..
POPLOG_HOME_DIR:=$(PREFIX)/poplog
MAJOR_VERSION:=16
MINOR_VERSION:=1
FULL_VERSION:=$(MAJOR_VERSION).$(MINOR_VERSION)
VERSION_DIR:=V$(MAJOR_VERSION)
POPLOG_VERSION_DIR:=$(POPLOG_HOME_DIR)/$(VERSION_DIR)
SYMLINK:=current_usepop
POPLOG_VERSION_SYMLINK:=$(POPLOG_HOME_DIR)/$(SYMLINK)

POPLOCAL_HOME_DIR:=$(POPLOG_VERSION_DIR)/../../poplocal

# This is the folder where the link to the poplog-shell executable will be installed.
EXEC_DIR:=$(PREFIX)/bin

# Allow overriding of the branches used for the different repositories.
DEFAULT_BRANCH:=main
BASE_BRANCH:=$(DEFAULT_BRANCH)
COREPOPS_BRANCH:=$(DEFAULT_BRANCH)

BASE_TARBALL_URL:=https://github.com/GetPoplog/Base/archive/$(BASE_BRANCH).tar.gz
COREPOPS_TARBALL_URL:=https://github.com/GetPoplog/Corepops/archive/$(COREPOPS_BRANCH).tar.gz

.PHONY: all
all:
	$(MAKE) build
	# Target "all" completed

.PHONY: help
help:
	# This is a makefile that can be used to acquire Poplog, build and install it locally.
	# Poplog will be installed in $$(POPLOG_HOME_DIR) which is typically /usr/local/poplog.
	# A supported use-case is keeping this Makefile in $(POPLOG_HOME_DIR), cloned  
	# from the git repo at https://github.com/GetPoplog/Seed.git and pulling updates to the
	# script with git pull :). 
	#
	# Within $$(POPLOG_HOME_DIR) there may be multiple versions of Poplog living 
	# side-by-side. The current version will be symlinked via a link called
	# current_usepop. You must have write-access to this folder during the 
	# "make install" step. (And during all the steps if you keep the Makefile
	# in the home-dir.)
	#
	# Note that targets marked with a [^] normally require root privileges and 
	# should be run using sudo (or as root).
	#
	# Valid targets are:
	#   all [^] - installs dependencies and produces a build-tree.
	#   download - downloads all the archives required by the build process.
	#   build - creates a complete build-tree in _build/poplog_base.
	#   install [^] - installs Poplog into $(POPLOG_HOME) folder as V16.
	#   install-poplocal - installs a 'skeleton' folder for $$poplocal. Optional.
	#   uninstall [^] - removes Poplog entirely, leaving a backup in /tmp/POPLOG_HOME_DIR.tgz.
	#   systests - runs self-checks on an installed Poplog system
	#   really-uninstall-poplog [^] - removes Poplog and does not create a backup.
	#   use-repos - tells the build script to assume that the sister repos have
	#       been cloned/downloaded and that there is no need to download them.
	#   relink-and-build - a more complex build process that can relink the 
	#       corepop executable and is useful for O/S upgrades.
	#   jumpstart-ubuntu [^] - installs the packages a Ubuntu system needs.
	#   jumpstart-fedora [^] - installs the packages a Fedora system needs.
	#   jumpstart-* [^] - and more, try `make help-jumpstart`.
	#   clean - removes all the build artifacts.
	#   help - this explanation, for more info read the Makefile comments.

.PHONY: help-jumpstart
help-jumpstart:
	# Jumpstarts are targets that install the dependencies for a particular
	# Linux distribution. Installing dependencies are not part of a normal
	# build process and they are provided as a convenience to admins.
	# These will need to be run with sudo e.g.
	#	sudo make jumpstart-debian
	#
	# Valid targets are:
	#   jumpstart-debian - installs the packages a Debian system needs
	#   jumpstart-ubuntu - installs the packages an Ubuntu system needs
	#   jumpstart-fedora - installs the packages a Fedora system needs.
	#   jumpstart-opensuse-leap - installs the packages a openSUSE Leap system needs.
	#

.PHONY: build
build: _build/Done.proxy
	# Target "build" completed

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
	[ -f _build/Done.proxy ] # We have successfully built the new distro? Else fail!
	if [ -d $(POPLOG_VERSION_DIR) ] \
	&& [ -d $(POPLOG_VERSION_DIR).orig ] \
	&& [ -d $(POPLOG_VERSION_DIR).prev ]; then \
	    rm -rf $(POPLOG_VERSION_DIR).prev; \
	fi
	if [ -d $(POPLOG_VERSION_DIR) ] \
	&& [ -d $(POPLOG_VERSION_DIR).orig ]; then \
	    mv $(POPLOG_VERSION_DIR) $(POPLOG_VERSION_DIR).prev; \
	fi
	if [ -d $(POPLOG_VERSION_DIR) ]; then \
	    mv $(POPLOG_VERSION_DIR) $(POPLOG_VERSION_DIR).orig; \
	fi
	mkdir -p $(POPLOG_VERSION_DIR)
	( cd _build/poplog_base; tar cf - . ) | ( cd $(POPLOG_VERSION_DIR); tar xf - )
	cd $(POPLOG_HOME_DIR); ln -sf $(VERSION_DIR) $(SYMLINK)
	mkdir -p $(EXEC_DIR)
	ln -sf $(POPLOG_VERSION_SYMLINK)/pop/pop/poplog $(EXEC_DIR)/
	# Target "install" completed

.PHONY: install-poplocal
install-poplocal:
	mkdir -p $(POPLOCAL_HOME_DIR)
	( cd poplocal; tar cf - --exclude=.gitkeep . ) | ( cd $(POPLOCAL_HOME_DIR); tar xf - . )
	# Target "install-poplocal" completed.



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
	rm -f $(EXEC_DIR)/poplog

.PHONY: verify-uninstall
verify-uninstall:
	# A sanity check that the Poplog installation has actually been removed.
	test ! -e $(POPLOG_VERSION_DIR)
	test ! -e $(EXEC_DIR)/poplog

.PHONY: verify-install
verify-install:
	# A sanity check that the Poplog installation has actually been installed.
	test -d $(POPLOG_VERSION_DIR)
	test -f $(EXEC_DIR)/poplog	

.PHONY: clean
clean:
	rm -rf ./_build
	# Target "clean" completed

.PHONY: deepclean
deepclean: clean
	rm -rf ./_download

# We used nose2 to drive a simple test-discovery process. It turns out that we
# could have used pytest if we made use of the @pytest.mark.parameterize
# decorator.
.PHONY: systests
systests:
	cd systests; \
	if [ -e venv ]; then \
	    . venv/bin/activate; \
	fi; \
	nose2

# Installs the dependencies
#   Needed to fetch resources:
#       make curl
#   Needed for building Poplog:  
#       build-essential libc6 libncurses5 libncurses5-dev 
#       libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev
#   Needed for building popvision
#       csh
#   Needed at run-time by some tutorials
#       espeak
#   Optional - not included as these are not part of the essential package but
#   are properly supported by Poplog.
#       tcsh xterm
#
.PHONY: jumpstart-debian
jumpstart-debian:
	apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
	make curl \
	gcc build-essential libc6 libncurses5 libncurses5-dev \
	libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev \
	csh \
	espeak

.PHONY: jumpstart-ubuntu
jumpstart-ubuntu:
	$(MAKE) jumpstart-debian

.PHONY: jumpstart-fedora
jumpstart-fedora:
	dnf install \
	curl make bzip2 \
	gcc glibc-devel ncurses-devel libXext-devel libX11-devel \
	libXt-devel openmotif-devel xterm espeak csh

.PHONY: jumpstart-opensuse-leap
jumpstart-opensuse-leap:
	zypper --non-interactive install \
	curl make bzip2 \
	gcc libstdc++6 libncurses5 ncurses5-devel \
	libXext6 libX11-6 libX11-devel libXt-devel openmotif-devel \
	xterm espeak csh

.PHONY: download
download: _download/Base.Downloaded.proxy _download/Corepops.Downloaded.proxy _download/Packages.Downloaded.proxy

# Instructs the build process to assume that the sister github repos have been
# cloned and/or downloaded and reside in ../Base etc. This does not
# include Aaron Sloman's packages at this time. 
.PHONY: use-repos
use-repos: _download/Packages.Downloaded.proxy
	mkdir -p _download/Corepops
	( cd ../Corepops; tar cf - . ) | ( cd _download/Corepops; tar xf - )
	mkdir -p _download/Base
	( cd ../Base; tar cf - . ) | ( cd _download/Base; tar xf - )
	touch _download/Base.Downloaded.proxy _download/Corepops.Downloaded.proxy

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the Base repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
_build/ExtraScripts.proxy: _build/poplog_base/pop/com/poplogout.sh _build/poplog_base/pop/com/poplogout.csh
	touch $@

_build/Packages.proxy: _download/packages-V16.tar.bz2 _build/Base.proxy
	(cd _build/poplog_base/pop; tar jxf "../../../$<")
	cd _build/poplog_base/pop/packages/popvision/lib; mkdir -p bin/linux; for f in *.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	touch $@

_download/Packages.Downloaded.proxy: _download/packages-V16.tar.bz2
	touch $@

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
_build/Stage2.proxy: _build/Stage1.proxy _build/Newpop.proxy
	sh makeSystemTools.sh
	sh makeStage2.sh
	touch $@
	
# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop 
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
_build/Stage1.proxy: _build/Corepops.proxy
	sh makeSystemTools.sh
	sh relinkCorepop.sh
	cp _build/poplog_base/pop/pop/newpop11 _build/poplog_base/pop/pop/corepop
	touch $@

_build/Newpop.proxy: _build/poplog_base/pop/pop/newpop.psv
	touch $@

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency 
# on Stage1.
_build/poplog_base/pop/pop/newpop.psv: _build/Stage1.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popinit.sh \
        && (cd $$popsys; $$popsys/corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)

# This target ensures that we have an unpacked base system with a valid corepop file.
_build/Corepops.proxy: _build/Base.proxy _download/Corepops.Downloaded.proxy
	cp -rpP _download/Corepops _build/
	cp _build/poplog_base/pop/pop/corepop _build/Corepops/supplied.corepop
	$(MAKE) -C _build/Corepops corepop
	cp _build/Corepops/corepop _build/poplog_base/pop/pop/corepop
	touch $@

_download/Corepops.Downloaded.proxy:
	mkdir -p _download/Corepops
	curl -LsS $(COREPOPS_TARBALL_URL) | ( cd _download/Corepops; tar zxf - --strip-components=1 )
	touch $@

_build/Base.proxy: _download/Base.Downloaded.proxy
	mkdir -p _build
	cp -r _download/Base/ _build/
	$(MAKE) -C _build/Base build
	mkdir -p _build/poplog_base
	( cd _build/Base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	touch $@ # Create the proxy file to signal that we are done.

_build/POPLOG_VERSION: _build/Base.proxy
	_build/poplog_base/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

_download/Base.Downloaded.proxy:
	mkdir -p _download/Base
	curl -LsS $(BASE_TARBALL_URL) | ( cd _download/Base; tar zxf - --strip-components=1)
	touch $@

_build/poplog_base/pop/com/poplogout.%: _build/poplogout.%
	(cd _build; cp poplogout.*sh poplog_base/pop/com/)

_build/poplogout.%:
	mkdir -p _build
	curl -LsS https://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/$(notdir $@) > $@

_download/packages-V16.tar.bz2:
	mkdir -p _download
	curl -LsS http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/packages-V16.tar.bz2 > $@

_build/PoplogCommander.proxy: _build/Stage2.proxy
	mkdir -p _build/cmdr
	GET_POPLOG_VERSION=`cat VERSION` sh makePoplogCommander.sh > _build/cmdr/poplog.c
	( cd _build/cmdr && gcc -Wall -o poplog poplog.c )
	rm -f _build/poplog_base/pop/pop/poplog
	cp _build/cmdr/poplog _build/poplog_base/pop/pop/
	touch $@

_build/MakeIndexes.proxy: _build/Stage2.proxy _build/Packages.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popinit.sh \
        && $$usepop/pop/com/makeindexes > _build/makeindexes.log
	touch $@

_build/NoInit.proxy: _build/Base.proxy
	# Add the noinit files for poplog --run.
	mkdir -p _build/poplog_base/pop/com/noinit
	cd _build/poplog_base/pop/com/noinit; \
	  touch init.p; \
	  ln -s init.p vedinit.p; \
	  ln -s init.p init.pl; \
	  ln -s init.p init.lsp; \
	  ln -s init.p init.ml
	chmod a-w _build/poplog_base/pop/com/noinit/*.*
	touch $@

_build/Done.proxy: _build/MakeIndexes.proxy _build/PoplogCommander.proxy _build/NoInit.proxy
	find _build/poplog_base -name '*-' -exec rm -f {} \; # Remove the backup files
	touch $@

# The transplant target is useful to get the _build folder fully
# built and then the whole GetPoplog-tree is captured as a tarball.
# This is used on host X in order to relink on host Y. The process 
# is as follows:
#   On host X
#       make transplant
#       scp _build/transplant-getpoplog.tgz $hostY:transplant-getpoplog.tgz
#   On host Y
#       mkdir Seed
#       cd Seed
#       tar zxf ../transplant-getpoplog.tgz
#       make relink-and-build
#
.PHONY: transplant
transplant: _build/transplant-getpoplog.tgz
	true

_build/transplant-getpoplog.tgz: _build/Done.proxy
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
# its result in _build/transplant-getpoplog.tgz.) 
# 
# Once the GetPoplog-tree assives on host Y, use this target 
# to attempt the relinking of a new Poplog executable on host Y.
# If this generates a working 'corepop' image then the normal
# build process is attempted with the new image substituted.
.PHONY: relink-and-build
relink-and-build: 
	[ -f _build/Done.proxy ] # Sanity check that we are starting from a pre-built tree.
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popinit.sh \
        && cd $$popsys \
        && $$usepop/pop/pop/poplink_cmnd
	output=`./_build/poplog_base/pop/pop/newpop11 ":sysexit()" 2>&1` && [ -z "$$output" ] # Check the rebuilt newpop11 works
	mv _build/poplog_base/pop/pop/newpop11 .
	$(MAKE) clean && $(MAKE) _build/Base.proxy
	mv newpop11 _build/poplog_base/pop/pop/corepop
	$(MAKE) build

.PHONY: full
full:
	echo $(FULL_VERSION)

################################################################################
# Packaging formats
################################################################################

#-- Pop-tree, the fundamental basis of packaging -------------------------------

.PHONY: dottgz
dottgz: _build/poplog.tar.gz

_build/poplog.tar.gz: _build/Done.proxy
	( cd _build/poplog_base/; tar cf - pop ) | gzip > $@
	[ -f $@ ] # Sanity check that we built the target

#-- Debian *.deb packaging -----------------------------------------------------

.PHONY: dotdeb
dotdeb: _build/poplog_$(FULL_VERSION)-1_amd64.deb

_build/poplog_$(FULL_VERSION)-1_amd64.deb: _build/poplog.tar.gz
	$(MAKE) builddeb
	[ -f $@ ] # Sanity check that we built the target

# We need a target that the CircleCI script can use for a process that assumes
# _build/poplog.tar.gz exists and doesn't try to rebuild anything.
.PHONY: builddeb
builddeb:
	[ -f _build/poplog.tar.gz ] # Enforce required tarball
	rm -rf _build/dotdeb
	mkdir -p _build/dotdeb$(POPLOG_VERSION_DIR)
	mkdir -p _build/dotdeb$(EXEC_DIR)
	tar cf - DEBIAN | ( cd _build/dotdeb; tar xf - )
	cat _build/poplog.tar.gz | ( cd _build/dotdeb$(POPLOG_VERSION_DIR); tar zxf - )
	cd _build/dotdeb$(POPLOG_HOME_DIR); ln -sf $(VERSION_DIR) $(SYMLINK)
	P=`realpath -ms --relative-to=$(EXEC_DIR) $(POPLOG_VERSION_SYMLINK)/pop/pop`; ln -s "$$P/poplog" _build/dotdeb$(EXEC_DIR)/poplog
	Q=`realpath -ms --relative-to=$(EXEC_DIR) $(POPLOG_VERSION_DIR)/pop/pop`; ln -s "$$Q/poplog" _build/dotdeb$(EXEC_DIR)/poplog$(VERSION_DIR)
	cd _build; dpkg-deb --build dotdeb poplog_$(FULL_VERSION)-1_amd64.deb

#-- Redhat *.rpm packaging -----------------------------------------------------

.PHONY: dotrpm
dotrpm: _build/poplog-$(FULL_VERSION)-1.x86_64.rpm

# Use this target when working standalone.
_build/poplog-$(FULL_VERSION)-1.x86_64.rpm: _build/poplog.tar.gz
	$(MAKE) buildrpm
	[ -f $@ ] # Sanity check that we built the target

# We need a target that the CircleCI script can use for a process that assumes
# _build/poplog.tar.gz exists and doesn't try to rebuild anything.
.PHONY: buildrpm
buildrpm:
	[ -f _build/poplog.tar.gz ] # Enforce required tarball
	rm -rf _build/rpmbuild
	mkdir -p _build/rpmbuild
	( cd rpmbuild; tar cf - . ) | ( cd _build/rpmbuild; tar xf - )
	cd _build/rpmbuild; mkdir -p BUILD BUILDROOT RPMS SOURCES SPECS SRPMS
	cp _build/poplog.tar.gz _build/rpmbuild/SOURCES/
	cd _build/rpmbuild; rpmbuild --define "_topdir `pwd`" -bb ./SPECS/poplog.spec
	mv _build/rpmbuild/RPMS/x86_64/poplog-$(FULL_VERSION)-1.x86_64.rpm _build/  # mv is safe - rpmbuild is idempotent

#-- AppImage *.AppImage packaging ----------------------------------------------

.PHONY: dotappimage
dotappimage: _build/Poplog-x86_64.AppImage

_build/Poplog-x86_64.AppImage: _build/poplog.tar.gz
	$(MAKE) buildappimage
	[ -f $@ ] # Sanity check that we built the target

# We need a target that the CircleCI script can use for a process that assumes
# _build/poplog.tar.gz exists and doesn't try to rebuild anything. 
.PHONY: buildappimage
buildappimage: _build/appimagetool
	[ -f _build/poplog.tar.gz ] # Enforce required tarball
	rm -rf _build/AppDir
	mkdir -p _build/AppDir
	( cd AppDir; tar cf - . ) | ( cd _build/AppDir; tar xf - )	
	mkdir -p _build/AppDir$(POPLOG_VERSION_DIR)
	tar zxf _build/poplog.tar.gz -C _build/AppDir$(POPLOG_VERSION_DIR)
	mkdir -p _build/AppDir/usr/lib
	# List the libraries needed (for debugging)
	ldd _build/AppDir$(POPLOG_VERSION_DIR)/pop/pop/basepop11
	# Now create the local copies of the libraries
	for i in `ldd _build/AppDir$(POPLOG_VERSION_DIR)/pop/pop/basepop11 | grep -v 'not found' | grep ' => ' | cut -f 3 -d ' '`; do \
		cp -p `realpath $$i` _build/AppDir/usr/lib/`basename $$i`; \
	done
	# But we want to exclude libc and libdl.
	cd _build/AppDir/usr/lib/; rm -f libc* libdl.*
	# Now to create systematically re-named symlinks.
	cd _build/AppDir/usr/lib; for i in *.so.*; do ln -s $$i `echo "$$i" | sed 's/\.so\.[^.]*$$/.so/'`; done
	chmod a-w _build/AppDir/usr/lib/*
	mkdir -p _build/AppDir/usr/bin
	cd _build/AppDir/usr/bin; ln -s ../..$(POPLOG_VERSION_DIR)/pop/pop/poplog .
	cd _build && ARCH=x86_64 ./appimagetool AppDir

_build/appimagetool:
	curl -LSs https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage > _build/appimagetool
	chmod a+x _build/appimagetool
	[ -x $@ ] # Sanity check

#-- Snap (Ubuntu) *.snap packaging ---------------------------------------------
# See https://circleci.com/blog/circleci-and-snapcraft/

.PHONY: dotsnap
dotsnap: _build/dotsnap/poplog_16.0.1_amd64.snap

_build/dotsnap/poplog_16.0.1_amd64.snap: _build/poplog.tar.gz 
	$(MAKE) buildsnap
	[ -f $@ ] # Sanity check that we built the target

.PHONY: buildsnap
buildsnap:
	$(MAKE) buildsnapcraftready
	cd _build/dotsnap; snapcraft

PREBUILT_DIR:=/prebuilt

.PHONY: buildsnapcraftready
buildsnapcraftready:
	[ -f _build/poplog.tar.gz ] # Enforce required tarball
	mkdir -p _build/dotsnap$(PREBUILT_DIR)$(POPLOG_VERSION_DIR)
	mkdir -p _build/dotsnap$(PREBUILT_DIR)/usr/bin
	cat _build/poplog.tar.gz | ( cd _build/dotsnap$(PREBUILT_DIR)$(POPLOG_VERSION_DIR); tar zxf - )
	cd _build/dotsnap$(PREBUILT_DIR)/usr/bin; ln -s ../..$(POPLOG_VERSION_DIR)/pop/pop/poplog .
	cp snapcraft.yaml _build/dotsnap	


################################################################################
# Perform a GitHub release via CircleCI. You must be authorized to push tags to 
# the upstream repository on GitHub to perform this action.
################################################################################

.PHONY: github-release
github-release: 
	GETPOPLOG_VERSION=v`cat VERSION` ; \
	git tag $$GETPOPLOG_VERSION -a -m "GetPoplog $$GETPOPLOG_VERSION" ; \
	git push origin $$GETPOPLOG_VERSION
