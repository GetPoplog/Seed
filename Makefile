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
#

POPLOG_HOME:=$(shell pwd)
BASE_REPO:=/home/steve/Base
DOCS_REPO:=/home/steve/Docs
COREPOPS_REPO:=/home/steve/Corepops

.PHONEY: help
help:
	# This is a makefile that can be used to acquire Poplog, build and install it locally.
	# It should be in the folder in which Poplog will be maintained e.g. /usr/local/poplog.
	# This folder will become $POPLOG_HOME. Within it there may be multiple versions of 
	# Poplog living side-by-side. The current version will be symlinked. You must have 
	# write-access to this folder.
	#
	# Valid targets are:
	#   jumpstart - installs the dependencies for a full Poplog SDK experience.
	#   clean - removes all the build artefacts

.PHONEY: clean
clean:
	rm -rf ./_build

# Installs the dependencies needed during the build phase.
_build/JumpStart.proxy:
	sudo apt-get update \
        && sudo apt-get install -y make wget git \
           gcc build-essential libc6 libncurses5 libncurses5-dev \
           libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev
	touch JumpStart.proxy

# This target ensures that we rebuild popc, poplink, poplibr on top of the fresh corepop.
# It is effectively Waldek's build_pop2 script.
_build/Stage2.proxy: _build/Stage1.proxy _build/Newpop.proxy
	# Oddly we do not patch pglink as well. Mistake?
	#ln -f _build/poplog_base/pop/pop/corepop _build/poplog_base/pop/pop/pglink
	sh makeSystemTools.sh
	sh makeStage2.sh
	#(cd _build/poplog_base; /bin/sh build_pop2 ) 2>&1 >> _build/log.txt
	touch _build/Stage2.proxy
	
# This target ensures that we have a working popc, poplink, poplibr and a fresh corepop 
# in newpop11. It is the equivalent of Waldek's build_pop0 script.
_build/Stage1.proxy: _build/Corepops.proxy
	sh makeSystemTools.sh
	sh relinkCorepop.sh
	cp _build/poplog_base/pop/pop/newpop11 _build/poplog_base/pop/pop/corepop
	touch _build/Stage1.proxy

_build/Newpop.proxy: _build/poplog_base/pop/pop/newpop.psv
	touch _build/Newpop.proxy

# N.B. This target needs the freshly built corepop from relinkCorepop.sh, hence the dependency 
# on Stage1.
_build/poplog_base/pop/pop/newpop.psv: _build/Stage1.proxy
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popenv.sh \
        && (cd $$popsys; ./corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)

# This target ensures that we have an unpacked base system with a valid corepop file.
_build/Corepops.proxy: _build/Base.proxy
	mkdir -p _build/Corepops
	git archive --remote=$(COREPOPS_REPO) master | ( cd _build/Corepops; tar xf - )
	cp _build/poplog_base/pop/pop/corepop _build/Corepops/supplied.corepop
	$(MAKE) -C _build/Corepops corepop
	cp _build/Corepops/corepop _build/poplog_base/pop/pop/corepop
	ln -f _build/poplog_base/pop/pop/corepop _build/poplog_base/pop/pop/pglink
	touch _build/Corepops.proxy

# Installs packages that some supplied tutorial packages depend on (not crucial).
.PHONEY: installRuntimeDependencies
installPackages:
	sudo apt-get install espeak 

# Extras for a more complete experience (entirely optional).
.PHONEY: installCompleteUX
installCompleteUX:
	sudo apt-get install tcsh xterm

.PHONEY: fetchPoplogBaseFiles
fetchPoplogBaseFiles: _build/Base.proxy
	true

_build/Base.proxy: _build/JumpStart.proxy
	mkdir -p _build/Base
	git archive --remote=$(BASE_REPO) master | ( cd _build/Base; tar xf - )
	$(MAKE) -C _build/Base
	mkdir -p _build/poplog_base
	( cd _build/Base; tar cf - pop ) | ( cd _build/poplog_base; tar xf - )
	# Create the proxy file to signal that we are done.
	touch _build/Base.proxy


.PHONEY: fetchExtraFiles
fetchExtraFiles: _build/docs.tar.bz2 _build/packages-V16.tar.bz2 \
            _build/poplog_base/pop/com/poplogout.sh _build/poplog_base/pop/com/poplogout.csh
	(cd _build/poplog_base/pop; tar jxf ../../docs.tar.bz2)
	(cd _build/poplog_base/pop; tar jxf ../../packages-V16.tar.bz2)

_build/poplog_base/pop/com/poplogout.%: _build/poplogout.%
	(cd _build; cp poplogout.*sh poplog_base/pop/com/)

_build/poplogout.%:
	mkdir -p _build
	wget -P _build https://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/$(notdir $@)

#_build/latest_poplog_base.tar.bz2:
#	mkdir -p _build
#	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/latest_poplog_base.tar.bz2

_build/docs.tar.bz2: 
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/docs.tar.bz2

_build/packages-V16.tar.bz2:
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/packages-V16.tar.bz2


.PHONEY: makeindexes
makeindexes:
	mkdir -p _build
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/popenv.sh \
	&& $$usepop/pop/com/makeindexes > _build/makeindexes.log

