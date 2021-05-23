#!/bin/sh

# Run the initialisation files to set up additional environment
# variables.
export usepop=`pwd`
. $usepop/pop/com/popenv.sh

export POP__as=/usr/bin/as
POP_arch=x86_64

# Rebuilding system images
cd pop/src
    ../../mk_cross -d -a=$POP_arch popc poplibr poplink

cd ../pop
    ln -s corepop popc
    ln -s corepop poplibr
    ln -s corepop poplink

