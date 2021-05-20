# This is a makefile that can be used to acquire Poplog, build and install it locally.
# It should be added to the folder in which Poplog will be maintained e.g. /usr/local/poplog.
# Within that folder, there may be multiple versions of Poplog living side-by-side. 
# e.g   /usr/local/poplog
#           Makefie             <- this file
#           current_usepop      <- symlink to the currently active Poplog version e.g. versions/V16
#           versions/V16        <- an example  Poplog system
#

POPLOG_HOME:=$(shell pwd)

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
.PHONEY: jumpStart
jumpStart:
	sudo apt-get install wget gcc build-essential libc6 libncurses5 libncurses5-dev \
	libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev

# Installs packages that some supplied tutorial packages depend on (not crucial).
.PHONEY: installRuntimeDependencies
installPackages:
	sudo apt-get install espeak 

# Extras for a more complete experience (entirely optional).
.PHONEY: installExtras
installExtras:
	sudo apt-get install tcsh xterm

.PHONEY: fetchFiles
fetchFiles: _build/latest_poplog_base.tar.bz2 _build/docs.tar.bz2 _build/packages-V16.tar.bz2 \
            _build/poplogout.sh _build/poplogout.csh
	mkdir -p _build
	(cd _build; tar jxf latest_poplog_base.tar.bz2)
	(cd _build/poplog_base; tar jxf ../../docs.tar.bz2)
	(cd _build/poplog_base; tar jxf ../../packages-V16.tar.bz2)
	cp poplogout.*sh poplog_base/

_build/poplogout.%:
	mkdir -p _build
	wget -P _build https://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/$(notdir $@)

_build/latest_poplog_base.tar.bz2:
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/latest_poplog_base.tar.bz2

_build/docs.tar.bz2: 
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/docs.tar.bz2

_build/packages-V16.tar.bz2:
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/packages-V16.tar.bz2


