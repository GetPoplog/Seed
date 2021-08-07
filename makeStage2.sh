#!/bin/sh
set -e

BUILD_HOME=`pwd`/_build
usepop=`pwd`/_build/poplog_base
export usepop
. $usepop/pop/com/popinit.sh

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
# $usepop/pop/src/newpop -link -x=-xt -norsv

mkdir -p ${BUILD_HOME}/environments

# We need to capture the Poplog environment for each build variant.
echo_env() {
    cmd='(usepop="'"$1"'" && . $usepop/pop/com/popenv.sh && env)'
    env -i sh -c "$cmd" | sort | \
    grep -v '^\(_\|SHLVL\|PWD\|poplib\|poplocal\(auto\|bin\)\?\)=' | \
    sed -e 's!'"$1"'![//USEPOP//]!g'
}

### Xt #########################################################################

$usepop/pop/src/newpop -link -x=-xt -norsv

echo_env "$usepop" > ${BUILD_HOME}/environments/xt
echo_env "$usepop/pop/.." > ${BUILD_HOME}/environments/xt-cmp
( cd ${BUILD_HOME}/environments && \
  sed -e 's!\[//USEPOP//]/pop/pop![//USEPOP//]/pop/pop-xt!g' < xt | \
  sed -e 's!\[//USEPOP//]/pop/lib/psv/![//USEPOP//]/pop/lib/psv-xt/!g' > xt-new )

mkdir -p $usepop/pop/pop-xt
mkdir -p $usepop/pop/lib/psv-xt
( cd $usepop/pop/pop; tar cf - . ) | ( cd $usepop/pop/pop-xt; tar xf - )
( cd $usepop/pop/lib/psv; tar cf - . ) | ( cd $usepop/pop/lib/psv-xt; tar xf - )


### motif ######################################################################

$usepop/pop/src/newpop -link -x=-xm -norsv

echo_env "$usepop" > ${BUILD_HOME}/environments/xm
echo_env "$usepop/pop/.." > ${BUILD_HOME}/environments/xm-cmp
( cd ${BUILD_HOME}/environments && \
  sed -e 's!\[//USEPOP//]/pop/pop![//USEPOP//]/pop/pop-xm!g' < xm | \
  sed -e 's!\[//USEPOP//]/pop/lib/psv/![//USEPOP//]/pop/lib/psv-xm/!g' > xm-new )

mkdir -p $usepop/pop/pop-xm
mkdir -p $usepop/pop/lib/psv-xm
( cd $usepop/pop/pop; tar cf - . ) | ( cd $usepop/pop/pop-xm; tar xf - )
( cd $usepop/pop/lib/psv; tar cf - . ) | ( cd $usepop/pop/lib/psv-xm; tar xf - )


### nox ########################################################################

$usepop/pop/src/newpop -link -nox -norsv

echo_env "$usepop" > ${BUILD_HOME}/environments/nox
echo_env "$usepop/pop/.." > ${BUILD_HOME}/environments/nox-cmp
( cd ${BUILD_HOME}/environments && \
  sed -e 's!\[//USEPOP//]/pop/pop![//USEPOP//]/pop/pop-nox!g' < nox | \
  sed -e 's!\[//USEPOP//]/pop/lib/psv/![//USEPOP//]/pop/lib/psv-nox/!g' > nox-new )

# Rename rather than copy.
mv $usepop/pop/pop $usepop/pop/pop-nox
mv $usepop/pop/lib/psv $usepop/pop/lib/psv-nox

################################################################################

# Choose our default build variant.
ln -sf pop-nox $usepop/pop/pop
ln -sf psv-nox $usepop/pop/lib/psv
