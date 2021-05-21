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
	sudo apt-get update \
        && sudo apt-get install -y wget gcc build-essential libc6 libncurses5 libncurses5-dev \
           libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev

# This target ensures that we rebuild popc, poplink, poplibr on top of the newcorepop.
# It is effectively Waldek's build_pop2 script.
_build/basepop11: _build/newcorepop
	echo '--------------------------------------------------------------------------------' >> _build/log.txt
	echo 'Running build_pop2 ...' >> _build.log
	(cd _build/poplog_base; /bin/sh build_pop2 ) 2>&1 >> _build/log.txt
	ln _build/poplog_base/pop/pop/basepop11 _build/basepop11
	

# This target ensures that we have a working popc, poplink, poplibr. It is the equivalent of
# Waldek's build_pop0 script.
_build/newcorepop: _build/corepop
	echo '--------------------------------------------------------------------------------' >> _build/log.txt
	echo 'Running build_pop0 ...' >> _build.log
	(cd _build/poplog_base; /bin/sh build_pop0 ) 2>&1 >> _build/log.txt
	cp  _build/poplog_base/pop/pop/newpop11 _build/newcorepop

_build/poplog_base/pop/pop/newpop.psv: _build/corepop
	export usepop=$(abspath ./_build/poplog_base) \
        && . ./_build/poplog_base/pop/com/poplog.sh \
        && (cd $$popsys; ./corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p)


# This target ensures that we have an unpacked base system with a valid corepop file.
_build/corepop:
	$(MAKE) fetchPoplogBaseFiles
	# TODO: Fix up c_core.c - Temporary hack
	cp /usr/local/poplog/current_usepop/pop/extern/lib/c_core.c _build/poplog_base/pop/extern/lib/
	# TODO: ensure corepop is working - Temporary hack
	cp /usr/local/poplog/current_usepop/pop/pop/corepop _build/poplog_base/pop/pop/
	ln _build/poplog_base/pop/pop/corepop _build/corepop

# Installs packages that some supplied tutorial packages depend on (not crucial).
.PHONEY: installRuntimeDependencies
installPackages:
	sudo apt-get install espeak 

# Extras for a more complete experience (entirely optional).
.PHONEY: installCompleteUX
installCompleteUX:
	sudo apt-get install tcsh xterm

.PHONEY: fetchPoplogBaseFiles
fetchPoplogBaseFiles: _build/latest_poplog_base.tar.bz2
	mkdir -p _build
	(cd _build; tar jxf latest_poplog_base.tar.bz2)
	# TODO: Figure out how to include NO-PIE.
	sed -i 's/$$POP__cc -v -Wl,-export-dynamic/$$POP__cc -v -no-pie -Wl,-export-dynamic/' _build/poplog_base/pop/src/syscomp/x86_64/asmout.p

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

_build/latest_poplog_base.tar.bz2:
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/latest_poplog_base.tar.bz2

_build/docs.tar.bz2: 
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/docs.tar.bz2

_build/packages-V16.tar.bz2:
	mkdir -p _build
	wget -P _build http://www.cs.bham.ac.uk/research/projects/poplog/V16/DL/packages-V16.tar.bz2


