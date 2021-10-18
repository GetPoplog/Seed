#!/usr/bin/env bash
set -euo pipefail
# This script is used to dump the environment variables from the `popenv.sh`
# script that need to be set when using poplog.
#
# Since we distribute multiple builds of poplog without X, with X (Xt and
# Motif), we need to capture the different environment variables. This script
# does that via the `echo_env` function.
#
# echo_env relies on a weak strategy to identify substitutions of $usepop. To
# further increase its robustness, it is run twice with a tiny variation and
# the results are then checked to ensure they are the same (thereby giving
# confidence that the usepop substitutions have likely been correctly
# detected).

[ $# -eq 3 ] || { echo "USAGE: $0 <usepop> <build> <environment_file>"; exit 1; }

usepop="$1"; shift
build="$1"; shift
environment_file="$1"; shift

environment_dir="$(dirname "$environment_file")"
if [[ -n "$environment_dir" ]]; then
    mkdir -p "$environment_dir"
fi


echo_env() {
    usepop="$1"; shift
    build="$1"; shift
    # shellcheck disable=SC2016
    cmd='(usepop="'"$usepop"'" && . $usepop/pop/com/popenv.sh && env -0)'
    env -i sh -c "$cmd" | \
    sed -z \
    -e 's!'"$usepop"'![//USEPOP//]!g' \
    -e 's!\[//USEPOP//]/pop/pop![//USEPOP//]/pop/pop-'"${build}"'!g' \
    -e 's!\[//USEPOP//]/pop/lib/psv/![//USEPOP//]/pop/lib/psv-'"${build}"'/!g'
}


echo_env "$usepop" "$build" > "$environment_file"
