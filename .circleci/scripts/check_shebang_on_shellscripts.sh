#!/bin/bash
set -euo pipefail
shopt -s globstar
GLOBIGNORE="_build*:_download*"

has_shebang() {
    IFS= LC_ALL=C read -rN2 shebang < "$1" && [ "$shebang" = '#!' ]
}
missing_shebang=()
for f in **/*.sh **/*.csh; do
    has_shebang "$f" || missing_shebang+=("$f")
done
for f in "${missing_shebang[@]}"; do
    >&2 echo "Missing shebang: $f"
done
[ "${#missing_shebang[@]}" = 0 ]
