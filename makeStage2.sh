#!/bin/sh
set -e

export usepop=`pwd`/_build/poplog_base
. $usepop/pop/com/popenv.sh

# echo "mklibpop"
cd $popexternlib
    ./mklibpop

# mkXpw"
cd $popcom
    ./mkXpw -I/usr/include/X11

cd $usepop/pop/obj
    # saving library files in old
    mkdir -p old
    mv *.* old || true # *.* might match nothing so '|| true' is required.

# Recompiling base system
cd $usepop/pop/src
    popc -c -nosys $POP_arch/*.[ps] *.p || true
    poplibr -c ../obj/src.wlb *.w || true

cd $usepop/pop/ved/src/
    popc -c -nosys -wlib \( ../../src/ \) *.p || true
    poplibr -c ../../obj/vedsrc.wlb *.w || true

cd $usepop/pop/x/src/
    popc -c -nosys -wlib \( ../../src/ \) *.p
    poplibr -c ../../obj/xsrc.wlb *.w

# TODO: The rebuilding of newpop.psv should be a pre-req.
#cd $popsys
#    ./corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p

# Only one of the following lines should be commented-in. These all represent valid
# ways to construct the Poplog system.
# $usepop/pop/src/newpop -link -nox -norsv
# $usepop/pop/src/newpop -link -x=-xm -norsv
$usepop/pop/src/newpop -link -x=-xt -norsv

