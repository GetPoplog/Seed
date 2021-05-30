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
#     _build/JumpStart.proxy
#         This file signals that all the required packages have been apt-installed so that
#         the rest of the installation can proceed.
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
#     _build/Docs.proxy
#         This represents the addition of the Poplog documentation into the
#         build-tree.
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
#     _build/Done.proxy
#         This file represents the completion of the build-tree in the
#         _build/poplog_base folder. This can be moved to the appropriate 
#         place.
#

# This is the folder in which the new Poplog build will be installed. To install Poplog 
# somewhere different, such as /opt/poplog either edit this line or try:
#     make install POPLOG_HOME_DIR=/opt/poplog
POPLOG_HOME_DIR:=/usr/local/poplog
VERSION_DIR:=V16
POPLOG_VERSION_DIR:=$(POPLOG_HOME_DIR)/$(VERSION_DIR)
POPLOG_VERSION_SYMLINK:=$(POPLOG_HOME_DIR)/current_usepop

# This is the folder where the link to the poplog-shell executable will be installed.
# TODO: The poplog-shell has not been written yet, so this is a placeholder.
EXEC_DIR:=/usr/local/bin

MAIN_BRANCH:=main
SEED_TARBALL_URL:=https://github.com/GetPoplog/Seed/archive/$(MAIN_BRANCH).tar.gz
BASE_TARBALL_URL:=https://github.com/GetPoplog/Base/archive/$(MAIN_BRANCH).tar.gz
DOCS_TARBALL_URL:=https://github.com/GetPoplog/Docs/archive/$(MAIN_BRANCH).tar.gz
COREPOPS_TARBALL_URL:=https://github.com/GetPoplog/Corepops/archive/$(MAIN_BRANCH).tar.gz

# We need some support scripts. These might be checked out of git or downloaded
# by curl. If the latter then we must clean them up on "make clean", which
# is signalled by the file _build/CleanSupportScripts.flag.
SUPPORT_SCRIPTS=makeStage2.sh makeSystemTools.sh mk_cross relinkCorepop.sh
CLEAN_SUPPORT_SCRIPTS_FLAG=_build/CleanSupportScripts.flag

.PHONY: all
all: jumpstart
	$(MAKE) build
	# Target "all" completed

.PHONY: help
help:
	# This is a makefile that can be used to acquire Poplog, build and install it locally.
	# Poplog will be installed in $(POPLOG_HOME_DIR) which is typically /usr/local/poplog.
	# A supported use-case is keeping this Makefile in $(POPLOG_HOME_DIR), checked out 
	# from the git repo at https://github.com/GetPoplog/Seed.git and pulling updates to the
	# script with git pull :). 
	#
	# Within $(POPLOG_HOME_DIR) there may be multiple versions of Poplog living 
	# side-by-side. The current version will be symlinked via a link called
	# current_usepop. You must have write-access to this folder during the 
	# "make install" step. (And during all the steps if you keep the Makefile
	# in the home-dir.)
	#
	# Valid targets are:
	#   all - installs dependencies and produces a build-tree
	#   build - creates a complete build-tree in _build/poplog_base
	#   install - installs Poplog into $(POPLOG_HOME) folder as V16
	#   uninstall - removes Poplog entirely, leaving a backup in /tmp/POPLOG_HOME_DIR.tgz
	#   really-uninstall-poplog - removes Poplog and does not create a backup.
	#   jumpstart - installs the packages this installation depends on.
	#   clean - removes all the build artifacts.
	#   help - this explanation, for more info read the Makefile comments.

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
	rm -f $(POPLOG_VERSION_SYMLINK)
	( cd _build/poplog_base; tar cf - . ) | ( cd $(POPLOG_VERSION_DIR); tar xf - )
	ln -s $(POPLOG_VERSION_DIR) $(POPLOG_VERSION_SYMLINK)
	# Target "install" completed

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
	[ -f $(POPLOG_VERSION_DIR)/pop/pop/com/popenv.sh ] # Can we find a characteristic file?
	# OK, let's take out the home-directory.
	rm -rf $(POPLOG_HOME_DIR)
	# TODO: We will need to remove the symlink to the poplog-shell here.

.PHONY: clean
clean:
	# The flag file should live in _build, so we must do this first.
	if [ -e $(CLEAN_SUPPORT_SCRIPTS_FLAG) ]; then rm -f $(SUPPORT_SCRIPTS); fi
	# Now we clean up the main bulk of the artifacts.
	rm -rf ./_build
	# Target "clean" completed

# Installs the dependencies
#   Needed to fetch resources: 
#       make curl git
#   Needed for building Poplog:  
#       build-essential libc6 libncurses5 libncurses5-dev 
#       libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev
#   Needed at run-time by some tutorials
#       espeak
#   Optional - not included as these are not part of the essential package but
#   are properly supported by Poplog.
#       tcsh xterm
#
_build/JumpStart.proxy:
	sudo apt-get update \
        && sudo apt-get install -y make curl git \
           gcc build-essential libc6 libncurses5 libncurses5-dev \
           libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev \
	   espeak
	mkdir -p _build/
	touch $@

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the Base repo. TODO: TO BE CONFIRMED - until then these
# will be omitted.
_build/ExtraScripts.proxy: _build/poplog_base/pop/com/poplogout.sh _build/poplog_base/pop/com/poplogout.csh
	touch $@

_build/Packages.proxy: _build/packages-V16.tar.bz2
	mkdir -p _build
	(cd _build/poplog_base/pop; tar jxf ../../packages-V16.tar.bz2)
	touch $@

_build/Docs.proxy: _build/Base.proxy
	curl -LsS $(DOCS_TARBALL_URL) | ( cd _build/poplog_base; tar zxf - --exclude LICENSE --strip-components=1 )
	touch $@

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
_build/Stage2.proxy: _build/Stage1.proxy _build/Newpop.proxy makeStage2.sh makeSystemTools.sh mk_cross
	sh makeSystemTools.sh
	sh makeStage2.sh
	touch $@
	
# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop 
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
_build/Stage1.proxy: _build/Corepops.proxy makeSystemTools.sh relinkCorepop.sh mk_cross
	sh makeSystemTools.sh
	sh relinkCorepop.sh
	cp _build/poplog_base/pop/pop/newpop11 _build/poplog_base/pop/pop/corepop
	touch $@

# If this Makefile is checked out as part of a git-repo these files will aleady exist. (In
# fact this script assumes they all exist or are all missing.) But if this Makefile is 
# distributed standalone then it needs to fetch from the repo as independent files.
$(SUPPORT_SCRIPTS):
	# If we fetch by git-archive, we need to mark them for cleaning. 
	touch $(CLEAN_SUPPORT_SCRIPTS_FLAG)
	# Fetch all at the same time for efficiency. Do not use $@ or you can get 4 fetches.
	mkdir -p _build/Seed
	curl -LsS $(SEED_TARBALL_URL) | ( cd _build/Seed; tar zxf - --strip-components=1 )
	(cd _build/Seed; cp $(SUPPORT_SCRIPTS) ../..)
	
_build/Newpop.proxy: _build/poplog_base/pop/pop/newpop.psv
	touch $@

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency 
# on Stage1.
_build/poplog_base/pop/pop/newpop.psv: _build/Stage1.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popenv.sh \
        && (cd $$popsys; $$popsys/corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)

# This target ensures that we have an unpacked base system with a valid corepop file.
_build/Corepops.proxy: _build/Base.proxy
	mkdir -p _build/Corepops
	curl -LsS $(COREPOPS_TARBALL_URL) | ( cd _build/Corepops; tar zxf - --strip-components=1 )
	cp _build/poplog_base/pop/pop/corepop _build/Corepops/supplied.corepop
	$(MAKE) -C _build/Corepops corepop
	cp _build/Corepops/corepop _build/poplog_base/pop/pop/corepop
	touch $@

_build/Base.proxy:
	mkdir -p _build/Base
	curl -LsS $(BASE_TARBALL_URL) | ( cd _build/Base; tar zxf - --strip-components=1)
	$(MAKE) -C _build/Base build
	mkdir -p _build/poplog_base
	( cd _build/Base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	touch $@ # Create the proxy file to signal that we are done.

_build/poplog_base/pop/com/poplogout.%: _build/poplogout.%
	(cd _build; cp poplogout.*sh poplog_base/pop/com/)

_build/poplogout.%:
	mkdir -p _build
	curl -LsS https://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/$(notdir $@) > $@

_build/packages-V16.tar.bz2:
	mkdir -p _build
	curl -LsS http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/packages-V16.tar.bz2 > $@

_build/MakeIndexes.proxy: _build/Stage2.proxy _build/Docs.proxy _build/Packages.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popenv.sh \
	&& env PATH="$$popsys:$$PATH" $$usepop/pop/com/makeindexes > _build/makeindexes.log
	touch $@

_build/Done.proxy: _build/MakeIndexes.proxy
	touch $@
