#!/bin/sh
set -e
SEED_DIR=`pwd`/_build/Seed

# Run the initialisation files to set up additional environment
# variables.
usepop=`pwd`/_build/poplog_base
export usepop
. $usepop/pop/com/popinit.sh

POP__as=/usr/bin/as
export POP__as
POP_arch=x86_64

# Rebuilding system images
cd $popsrc
    ${SEED_DIR}/mk_cross -d -a=${POP_arch} popc poplibr poplink

# We need the -f flag here in case we have already symlinked.
cd $popsys
    ln -sf corepop popc
    ln -sf corepop poplibr
    ln -sf corepop poplink

