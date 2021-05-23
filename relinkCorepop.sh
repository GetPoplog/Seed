
#!/bin/sh

# Run the initialisation files to set up additional environment
# variables.
export usepop=`pwd`
. $usepop/pop/com/popenv.sh

cd $popexternlib
    ./mklibpop

cd $usepop/pop/obj
    mkdir old
    ls -l
    mv *.* old

# Recompiling base system
cd $usepop/pop/src
    popc -c -nosys $POP_arch/*.[ps] *.p
    poplibr -c ../obj/src.wlb *.w

# link a complete system into a newpop11 image, using pglink
cd $popsys
    pglink -core

