#!/bin/bash
set -ex

BUILD_HOME="$(pwd)/_build"
usepop="$(pwd)/_build/poplog_base"
POP_arch=x86_64
export usepop
# shellcheck disable=SC1091
. "$usepop/pop/com/popinit.sh"
: "${popexternlib:?}"
: "${popcom:?}"

# echo "mklibpop"
cd "$popexternlib"
    ./mklibpop

# mkXpw"
cd "$popcom"
    ./mkXpw -I/usr/include/X11

cd "$usepop/pop/obj"
    # saving library files in old
    mkdir -p old
    mv ./*.* old || true # *.* might match nothing so '|| true' is required.

# Recompiling base system
cd "$usepop/pop/src"
    popc -c -nosys "$POP_arch"/*.[ps] ./*.p || true
    poplibr -c ../obj/src.wlb ./*.w || true

cd "$usepop/pop/ved/src/"
    popc -c -nosys -wlib \( ../../src/ \) ./*.p || true
    poplibr -c ../../obj/vedsrc.wlb ./*.w || true

cd "$usepop/pop/x/src/"
    popc -c -nosys -wlib \( ../../src/ \) ./*.p
    poplibr -c ../../obj/xsrc.wlb ./*.w

# TODO: The rebuilding of newpop.psv should be a pre-req.
#cd $popsys
#    ./corepop %nort ../lib/lib/mkimage.p -entrymain ./newpop.psv ../lib/lib/newpop.p

# Only one of the following lines should be commented-in. These all represent valid
# ways to construct the Poplog system.
# $usepop/pop/src/newpop -link -nox -norsv
# $usepop/pop/src/newpop -link -x=-xm -norsv
# $usepop/pop/src/newpop -link -x=-xt -norsv

mkdir -p "${BUILD_HOME}/environments"

# We need to capture the Poplog environment for each build variant. This is
# required for the poplog command tool, which needs to bind the appropriate 
# environment variables. Each build variant has slightly different variables
# and values. So we capture these and later on will synthesise them into 
# C-code functions. This is the best point at which to capture the variables.

# We run the popenv.sh script inside a clean environment to capture the 
# set of environment variables needed. We then need to replace any matches
# of the string "_build/poplog_base" ($usepop) with our unique value USEPOP.
# This will allow us to dynamically substitute with the selfHome'd value
# at run-time. 

# We don't want the exact paths - we need to abstract over $usepop. And we
# also need to modify $usepop/pop/pop and $usepop/pop/lib/psv to include the
# $build. 

# N.B. We work in null-separated lines here, giving us a much better chance
# in converting newlines and other control characters to valid C-strings later 
# on.

echo_env() {
    build="$2"
    # shellcheck disable=SC2016
    cmd='(usepop="'"$1"'" && . $usepop/pop/com/popenv.sh && env -0)'
    env -i sh -c "$cmd" | \
    sed -z \
    -e 's!'"$1"'![//USEPOP//]!g' \
    -e 's!\[//USEPOP//]/pop/pop![//USEPOP//]/pop/pop-'"${build}"'!g' \
    -e 's!\[//USEPOP//]/pop/lib/psv/![//USEPOP//]/pop/lib/psv-'"${build}"'/!g'
}

link_and_create_env() {
    build="$1"

    # Newpop - see https://raw.githubusercontent.com/GetPoplog/Base/main/pop/help/newpop
    # Rebuilds $popsys: re-links basepop11, rebuild saved images and generate scripts.
    # -norsv inhibits the building of rsvpop11 (an obsolete license-free distributable runtime)
    # -nox specifies basepop11 should not be linked with X-windows.
    # -x=xt/xm specifies basepop11 should not be linked with Xt or Motif.
    declare -A build_options=( [xm]=-x=-xm [xt]=-x=-xt [nox]=-nox )

    "$usepop/pop/src/newpop" -link "${build_options[$build]}" -norsv

    # echo_env has weak strategy because it relies on being able to identify 
    # substitutions of $usepop. So we do it twice with a tiny variation and check
    # the results are the same in order to improve robustness.
    echo_env "$usepop" "${build}" > "${BUILD_HOME}/environments/${build}-base0"
    echo_env "$usepop/pop/.." "${build}" > "${BUILD_HOME}/environments/${build}-base0-cmp"
}

# Utility to copy contents from one existing folder to another existing folder.
tar_fromdir_todir() {
    ( cd "$1"; tar cf - . ) | ( cd "$2"; tar xf - )
}

### nox ########################################################################

link_and_create_env 'nox'

mkdir -p "$usepop"/pop/pop-nox
mkdir -p "$usepop"/pop/lib/psv-nox
tar_fromdir_todir "$usepop"/pop/pop{,-nox}
tar_fromdir_todir "$usepop"/pop/lib/psv{,-nox}

### motif ######################################################################

link_and_create_env 'xm'

mkdir -p "$usepop"/pop/pop-xm
mkdir -p "$usepop"/pop/lib/psv-xm
tar_fromdir_todir "$usepop"/pop/pop{,-xm}
tar_fromdir_todir "$usepop"/pop/lib/psv{,-xm}


### Xt #########################################################################

link_and_create_env 'xt'

# Rename rather than copy.
mv "$usepop/pop"/pop{,-xt}
mv "$usepop"/pop/lib/psv{,-xt}


################################################################################

# Choose our default build variant. 
ln -sf pop-xm "$usepop/pop/pop"
ln -sf psv-xm "$usepop/pop/lib/psv"

### End of file ################################################################
