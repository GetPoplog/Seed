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

# CONVENTION: If we want to allow the user of the Makefile to set via the CLI
# then we use ?= to bind it. If it's an internal variables then we use :=
CC?=gcc
CFLAGS?=-g -Wall -std=c11 -D_POSIX_C_SOURCE=200809L

# The prefix variable is used to set up POPLOG_HOME_DIR and bindir (and
# nowhere else, please). It is provided in order to fit in with the conventions
# of Makefiles.
DESTDIR?=
prefix?=/usr/local
# This is the folder where the link to the poplog-shell executable will be installed.
bindir:=$(prefix)/bin

TMP_DIR?=/tmp

# This is the folder in which the new Poplog build will be installed. To install Poplog
# somewhere different, such as /opt/poplog either edit this line or try:
#     make install POPLOG_HOME_DIR=/opt/poplog
# Resulting values would be:
#   POPLOG_HOME_DIR            /opt/poplog                   $usepop/..
#   POPLOG_VERSION_DIR         /opt/poplog/V16               $usepop
#   POPLOG_VERSION_SYMLINK     /opt/poplog/current_usepop -> /opt/poplog/V16
#   POPLOCAL_HOME_DIR          /opt/poplog                   $poplocal = $usepop/..
GETPOPLOG_VERSION:=$(shell cat VERSION)
POPLOG_HOME_DIR:=$(prefix)/poplog
MAJOR_VERSION:=16
VERSION_DIR:=V$(MAJOR_VERSION)
POPLOG_VERSION_DIR:=$(POPLOG_HOME_DIR)/$(VERSION_DIR)
SYMLINK:=current_usepop
POPLOG_VERSION_SYMLINK:=$(POPLOG_HOME_DIR)/$(SYMLINK)
export GETPOPLOG_VERSION

POPLOCAL_HOME_DIR:=$(POPLOG_VERSION_DIR)/../../poplocal

SRC_TARBALL_FILENAME:=poplog-$(GETPOPLOG_VERSION)
SRC_TARBALL:=_build/artifacts/$(SRC_TARBALL_FILENAME).tar.gz
BINARY_TARBALL_FILENAME:=poplog-binary-$(GETPOPLOG_VERSION)
BINARY_TARBALL:=_build/artifacts/$(BINARY_TARBALL_FILENAME).tar.gz

.PHONY: all
all:
	$(MAKE) build
	# Target "all" completed

.PHONY: help
help:
	# This is a makefile that can be used to acquire Poplog, build and install it locally.
	# Poplog will be installed in $(POPLOG_HOME_DIR) which is typically /usr/local/poplog.
	#
	# Within $(POPLOG_HOME_DIR) there may be multiple versions of Poplog living
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
	#   test - runs self-checks on an installed Poplog system
	#   really-uninstall-poplog [^] - removes Poplog and does not create a backup.
	#   relink-and-build - a more complex build process that can relink the
	#       corepop executable and is useful for O/S upgrades.
	#   jumpstart-* [^] - and more, try `make help-jumpstart`.
	#   clean - removes all the build artifacts but not the _download cache.
	#   deepclean - removes build artifacts and the _download cache.
	#   help - this explanation, for more info read the Makefile comments.


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
	[ -f _build/Done.proxy ] # We have successfully built the new distro? Else fail!
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
	( cd _build/poplog_base; tar cf - . ) | ( cd $(DESTDIR)$(POPLOG_VERSION_DIR); tar xf - )
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
add-uninstall-instructions: _build/poplog_base/UNINSTALL_INSTRUCTIONS.md

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

################################################################################
# Helper targets
################################################################################
.PHONY: clean
clean:
	rm -rf ./_build
	rm -f ./systests/report.xml
	# Target "clean" completed

.PHONY: deepclean
deepclean: clean
	rm -rf ./_download

.PHONY: test
test:
	cd systests; \
	if [ -e venv ]; then \
	    . venv/bin/activate; \
	fi; \
	pytest --junit-xml=report.xml

include mk_recipes/jumpstart.mk
################################################################################
# Download targets
################################################################################
.PHONY: download
download: _download/packages-V$(MAJOR_VERSION).tar.bz2 _download/poplogout.sh _download/poplogout.csh

_download/packages-V$(MAJOR_VERSION).tar.bz2:
	mkdir -p "$(@D)"
	curl -LsS "http://www.cs.bham.ac.uk/research/projects/poplog/V$(MAJOR_VERSION)/DL/packages-V$(MAJOR_VERSION).tar.bz2" > "$@"

_download/poplogout.%:
	mkdir -p "$(@D)"
	curl -LsS "https://www.cs.bham.ac.uk/research/projects/poplog/V$(MAJOR_VERSION)/DL/$(notdir $@)" > "$@"

_download/appimagetool:
	mkdir -p "$(@D)"
	curl -LSs "https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage" > "$@"
	chmod a+x "$@"
	[ -x $@ ] # Sanity check

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

################################################################################
# Build targets
################################################################################
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
#         This file represents  the discovery of a viable corepop executable. This should
#         be sufficient to reconstruct working system tools.
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

POPLOG_COMMANDER:=_build/poplog_base/pop/bin/poplog

.PHONY: build
build: _build/Done.proxy
	# Target "build" completed

_build/Done.proxy: _build/MakeIndexes.proxy $(POPLOG_COMMANDER) _build/NoInit.proxy _build/POPLOG_VERSION
	find _build/poplog_base -name '*-' -exec rm -f {} \; # Remove the backup files
	find _build/poplog_base -xtype l -exec rm -f {} \;   # Remove bad symlinks (we have some from poppackages)
	touch $@

_build/POPLOG_VERSION: _build/Base.proxy
	_build/poplog_base/pop/pop/corepop ":printf( pop_internal_version // 10000, '%p.%p\n' );" > $@

binarytarball: $(BINARY_TARBALL)
# Pop-tree: can be untarred and used directly (as an alternative to
# installing via a poplog package e.g. deb/rpm etc)
$(BINARY_TARBALL): _build/Done.proxy
	mkdir -p "$(@D)"
	( cd _build/poplog_base/; tar cf - pop ) | gzip > $@
	[ -f $@ ] # Sanity check that we built the target

_build/NoInit.proxy: _build/Base.proxy
	# Add the noinit files for poplog --run.
	mkdir -p _build/poplog_base/pop/com/noinit
	cd _build/poplog_base/pop/com/noinit; \
	  touch init.p; \
	  ln -sf init.p vedinit.p; \
	  ln -sf init.p init.pl; \
	  ln -sf init.p init.lsp; \
	  ln -sf init.p init.ml
	chmod a-w _build/poplog_base/pop/com/noinit/*.*
	touch $@

_build/commander/poplog.c: makePoplogCommander.sh
	mkdir -p $(@D)
	bash makePoplogCommander.sh > $@
	
$(POPLOG_COMMANDER): CFLAGS+=-Wextra -Werror -Wpedantic
$(POPLOG_COMMANDER): _build/commander/poplog.c
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@

_build/MakeIndexes.proxy: _build/Stage2.proxy _build/Packages.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popinit.sh \
        && $$usepop/pop/com/makeindexes > _build/makeindexes.log
	touch $@

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
_build/ExtraScripts.proxy: _build/poplog_base/pop/com/poplogout.sh _build/poplog_base/pop/com/poplogout.csh
	touch $@

_build/poplog_base/pop/com/poplogout.%: _download/poplogout.%
	mkdir -p "$(@D)"
	cp "$<" "$@"

_build/Packages.proxy: _download/packages-V$(MAJOR_VERSION).tar.bz2 _build/Base.proxy
	(cd _build/poplog_base/pop; tar jxf "../../../$<")
	./patchPackages.sh
	cd _build/poplog_base/pop/packages/popvision/lib; mkdir -p bin/linux; for f in *.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	cd _build/poplog_base/pop/packages/neural/; mkdir -p bin/linux; for f in src/c/*.c; do gcc -o bin/linux/`basename $$f .c`.so -O3 -fpic -shared $$f; done
	touch $@

LIBPOP_SRC:=$(wildcard base/pop/extern/lib/*.c)
LIBPOP_HEADERS:=$(wildcard base/pop/extern/lib/*.h)
LIBPOP_OBJ:=$(LIBPOP_SRC:base/%.c=_build/poplog_base/%.o)
LIBPOP:=_build/poplog_base/pop/extern/libpop.a

$(LIBPOP_OBJ): _build/poplog_base/%.o: base/%.c $(LIBPOP_HEADERS)
	mkdir -p $(@D)
	$(CC) -c -O $(CFLAGS) -o $@ $<

$(LIBPOP): $(LIBPOP_OBJ)
	mkdir -p $(@D)
	$(AR) rc $@ $^

X11_CFLAGS:=$(shell pkg-config --cflags x11) -I/usr/include/X11
X11_LDFLAGS:=$(shell pkg-config --libs x11)

LIBXPW_SRC:=$(wildcard base/pop/x/Xpw/*.c)
LIBXPW_HEADERS:=$(wildcard base/pop/x/Xpw/*.h)
LIBXPW_OBJ:=$(LIBXPW_SRC:base/%.c=_build/poplog_base/%.o)
LIBXPW:=_build/poplog_base/pop/extern/lib/libXpw.so

$(LIBXPW_OBJ): CFLAGS=$(X11_CFLAGS) -Ibase/pop/x/Xpw/ -fpic -g
$(LIBXPW_OBJ): _build/poplog_base/%.o: base/%.c $(LIBXPW_HEADERS)
	mkdir -p $(@D)
	$(CC) -c $(CFLAGS) -o $@ $<

$(LIBXPW): LDFLAGS+=$(X11_LDFLAGS)
$(LIBXPW): $(LIBXPW_OBJ)
	mkdir -p $(@D)
	$(CC) -shared $(LDFLAGS) -o $@ $^

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
_build/Stage2.proxy: _build/Stage1.proxy _build/Newpop.proxy $(LIBPOP) $(LIBXPW)
	bash makeSystemTools.sh
	bash makeStage2.sh
	touch $@

_build/Newpop.proxy: _build/poplog_base/pop/pop/newpop.psv
	touch $@

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency
# on Stage1.
_build/poplog_base/pop/pop/newpop.psv: _build/Stage1.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popinit.sh \
        && (cd $$popsys; $$popsys/corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)

# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
_build/Stage1.proxy: _build/Corepops.proxy
	bash makeSystemTools.sh
	bash relinkCorepop.sh
	cp _build/poplog_base/pop/pop/newpop11 _build/poplog_base/pop/pop/corepop
	touch $@

# This target ensures that we have an unpacked base system with a valid corepop file.
_build/Corepops.proxy: _build/Base.proxy
	mkdir -p "$(@D)"
	cp -rpP corepops _build/corepops
	cp -p _build/poplog_base/pop/pop/corepop _build/corepops/supplied.corepop
	$(MAKE) -C _build/corepops corepop
	cp -p _build/corepops/corepop _build/poplog_base/pop/pop/corepop
	touch $@

_build/Base.proxy: base
	mkdir -p "$(@D)"
	cp -rpP base _build/
	$(MAKE) -C _build/base build
	mkdir -p _build/poplog_base
	( cd _build/base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	touch $@ # Create the proxy file to signal that we are done.

_build/poplog_base/UNINSTALL_INSTRUCTIONS.md:
	mkdir -p "$(@D)"
	bindir="$(bindir)" POPLOG_HOME_DIR="$(POPLOG_HOME_DIR)" sh writeUninstallInstructions.sh > _build/poplog_base/UNINSTALL_INSTRUCTIONS.md

################################################################################
# Transplant targets
################################################################################
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


################################################################################
# Changelogs
################################################################################
_build/changelogs/CHANGELOG.debian: CHANGELOG.yml
	python3 contributor_tools/make_changelog.py --format debian "$<" "$@"

_build/changelogs/CHANGELOG.md: CHANGELOG.yml
	python3 contributor_tools/make_changelog.py --latest "$<" "$@"

include mk_recipes/packaging.mk
################################################################################
# Perform a GitHub release via CircleCI. You must be authorized to push tags to
# the upstream repository on GitHub to perform this action.
################################################################################

.PHONY: github-release
github-release:
	git tag v$(GETPOPLOG_VERSION) -a -m "GetPoplog v$(GETPOPLOG_VERSION)" ; \
	git push origin v$(GETPOPLOG_VERSION)
