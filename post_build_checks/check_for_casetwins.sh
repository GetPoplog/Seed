#!/bin/bash
set -euo pipefail

# We scan the Poplog tree looking for ordinary files whose paths differ
# only by case e.g. 
#   pop/packages/vedmail/auto/ved_respond.p
#   pop/packages/vedmail/auto/ved_Respond.p
# These files will cause difficulties if we ever move to a filing system
# that is case-preserving but case-insensitive (Windows, MacOS HFS).
# We count this as techdebt.

# We have a list of known problems and we want to be warned if we find
# that list is expanded.

# Make the script agnostic about whether it is run from top level or
# its own folder.
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

cmp \
  "${SCRIPT_DIR}/known_casetwins.txt" \
  <(cd "${SCRIPT_DIR}/../_build/poplog_base" && find . -type f | tr '[:upper:]' '[:lower:]' | sort | uniq --repeated)