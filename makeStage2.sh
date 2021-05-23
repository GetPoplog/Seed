#!/bin/sh

# echo "mklibpop"
cd $popexternlib
    ./mklibpop

# mkXpw"
cd $popcom
    ./mkXpw -I/usr/include/X11

cd $usepop/pop/obj
    # saving library files in old
    mkdir old
    mv *.* old

# Recompiling base system
cd $usepop/pop/src
    popc -c -nosys $POP_arch/*.[ps] *.p
    poplibr -c ../obj/src.wlb *.w

cd $usepop/pop/ved/src/
    popc -c -nosys -wlib \( ../../src/ \) *.p
    poplibr -c ../../obj/vedsrc.wlb *.w

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

