#!/bin/sh
set -e

POP_arch=x86_64
POP__as=/usr/bin/as
export POP__as

# Run the initialisation files to set up additional environment
# variables.
usepop=`pwd`/_build/poplog_base
export usepop
. $usepop/pop/com/popinit.sh

cd $popexternlib
    ./mklibpop

cd $usepop/pop/obj
    mkdir -p old
    /bin/mv -f *.* old || true   # If *.* matches nothing then skip.

# Recompiling base system
cd $usepop/pop/src
    $popsys/popc -c -nosys $POP_arch/*.[ps] *.p || true
    $popsys/poplibr -c ../obj/src.wlb *.w || true
    echo Done

# link a complete system into a newpop11 image, using pglink
cd $popsys
echo Try pglink
    $popsys/pglink -core
