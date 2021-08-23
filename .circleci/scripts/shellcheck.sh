#!/bin/bash
set -euo pipefail
find . \
    -path ./_build -prune \
    -o -path ./_download -prune \
    -o -iname '*.sh' \
    ! -path ./base/pop/com/popenv.sh \
    ! -path ./base/pop/com/poplog.sh \
    ! -path ./base/pop/com/motif2/popenv.sh \
    ! -path ./base/pop/com/popinit.sh \
    -exec shellcheck {} \+

