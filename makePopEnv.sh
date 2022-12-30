#!/bin/bash
set -euo pipefail
[ $# -eq 2 ] || { echo "USAGE: $0 <popenv.sh> <withXved>"; exit 1; }

popenv="$1"; shift
withXved="$1"; shift

if [[ ! "$withXved" = true ]] && [[ ! "$withXved" = false ]]; then
    echo "withXved must be either true or false but was '$withXved'"
    exit 1
fi

cat  > "$popenv" <<\****
pop_pop11="-$popsavelib/startup.psv"; export pop_pop11
pop_prolog="$pop_pop11 -$popsavelib/prolog.psv"; export pop_prolog
pop_clisp="$pop_pop11 -$popsavelib/clisp.psv"; export pop_clisp
pop_pml="$pop_pop11 +$popsavelib/pml.psv"; export pop_pml
pop_ved="$pop_pop11 :sysinitcomp();ved"; export pop_ved
****
if [[ "$withXved" = "true" ]]; then
cat >> "$popenv" <<\****
pop_xved="$pop_pop11 +$popsavelib/xved.psv"; export pop_xved
****
fi
