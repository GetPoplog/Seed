#!/bin/bash
set -euo pipefail
shopt -s globstar nullglob
GLOBIGNORE="_build*:_download*"

bad_libs=()
for f in  **/*.so; do
    { file "$f" | grep 32-bit >/dev/null; } && {
        echo "Found 32-bit lib: $f"
        bad_libs+=("$f")
    }
done

[ "${#bad_libs[@]}" = 0 ]
