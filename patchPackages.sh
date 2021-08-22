#!/bin/bash
set -euo pipefail
shopt -s globstar

[[ -d "_build/poplog_base/pop" ]] || {
    echo "Must extract packages to build dir first";
    exit 1
}
cd _build/poplog_base/pop
for patch_file in ../../../patches/**/*.diff; do
    patch -p0 < "$patch_file"
done
