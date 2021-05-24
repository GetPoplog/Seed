# This is a makefile that can be used to acquire Poplog, build and install it locally.
# It should be added to the folder in which Poplog will be maintained e.g. /usr/local/poplog.
# Within that folder, there may be multiple versions of Poplog living side-by-side. 
# 
# e.g   /usr/local/poplog
#           Makefile            <- this file
#           current_usepop      <- symlink to the currently active Poplog version e.g. versions/V16
#           versions/V16        <- an example  Poplog system
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

POPLOG_HOME:=$(shell pwd)
SEED_REPO:=/home/steve/Seed
BASE_REPO:=/home/steve/Base
DOCS_REPO:=/home/steve/Docs
COREPOPS_REPO:=/home/steve/Corepops

.PHONY: all
all: build
	# Target "all" completed

.PHONY: help
help:
	# This is a makefile that can be used to acquire Poplog, build and install it locally.
	# It should be in the folder in which Poplog will be maintained e.g. /usr/local/poplog.
	# This folder will become $POPLOG_HOME. Within it there may be multiple versions of 
	# Poplog living side-by-side. The current version will be symlinked. You must have 
	# write-access to this folder.
	#
	# Valid targets are:
	#   all/build - creates a complete build-tree in _build/poplog_base
	#   install - installs Poplog into $(POPLOG_HOME) folder as V16
	#   uninstall - removes Poplog 
	#   jumpstart - installs the packages this installation depends on.
	#   clean - removes all the build artefacts.
	#   help - this explanation, for more info read the Makefile comments.

.PHONY: build
build: _build/Done.proxy
	# Target "build" completed

.PHONY: install
install:
	echo 'To be continued'

.PHONY: uninstall
uninstall:
	echo 'To be continued'

.PHONY: clean
clean:
	rm -rf ./_build
	# Target "clean" completed

# Installs the dependencies
#   Needed to fetch resources: make wget git
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
        && sudo apt-get install -y make wget git \
           gcc build-essential libc6 libncurses5 libncurses5-dev \
           libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev \
	   espeak
	touch $@

# It is not clear that these scripts should be included or not. If they are it makes
# more sense to include them in the Base repo. TO BE CONFIRMED - until then these
# will be omitted.
_build/ExtraScripts.proxy: _build/poplog_base/pop/com/poplogout.sh _build/poplog_base/pop/com/poplogout.csh
	touch $@

_build/Packages.proxy: _build/packages-V16.tar.bz2
	mkdir -p _build
	(cd _build/poplog_base/pop; tar jxf ../../packages-V16.tar.bz2)
	touch $@

_build/Docs.proxy: _build/Base.proxy
	git archive --remote=$(DOCS_REPO) master | ( cd _build/poplog_base; tar xf - )
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
makeStage2.sh makeSystemTools.sh mk_cross relinkCorepop.sh:
	# Fetch all at the same time for efficiency. Do not use $@ or you can get 4 fetches.
	git archive --remote=$(SEED_REPO) master makeStage2.sh makeSystemTools.sh mk_cross relinkCorepop.sh | tar xf -

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
	git archive --remote=$(COREPOPS_REPO) master | ( cd _build/Corepops; tar xf - )
	cp _build/poplog_base/pop/pop/corepop _build/Corepops/supplied.corepop
	$(MAKE) -C _build/Corepops corepop
	cp _build/Corepops/corepop _build/poplog_base/pop/pop/corepop
	touch $@

# TODO: add dependency ... _build/Base.proxy: _build/JumpStart.proxy
_build/Base.proxy:
	mkdir -p _build/Base
	git archive --remote=$(BASE_REPO) master | ( cd _build/Base; tar xf - )
	$(MAKE) -C _build/Base build
	mkdir -p _build/poplog_base
	( cd _build/Base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	touch $@ # Create the proxy file to signal that we are done.

_build/poplog_base/pop/com/poplogout.%: _build/poplogout.%
	(cd _build; cp poplogout.*sh poplog_base/pop/com/)

_build/poplogout.%:
	mkdir -p _build
	wget -P _build https://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/$(notdir $@)

_build/packages-V16.tar.bz2:
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/packages-V16.tar.bz2

_build/MakeIndexes.proxy: _build/Stage2.proxy _build/Docs.proxy _build/Packages.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popenv.sh \
	&& env PATH=$$popsys:$$PATH $$usepop/pop/com/makeindexes > _build/makeindexes.log
	touch $@

_build/Done.proxy: _build/MakeIndexes.proxy
	touch $@
