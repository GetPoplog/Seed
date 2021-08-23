#!/bin/bash
set -euo pipefail
shopt -s globstar nullglob

# We scan the Poplog tree looking for ordinary files whose paths differ
# only by case e.g. 
#   pop/packages/vedmail/auto/ved_respond.p
#   pop/packages/vedmail/auto/ved_Respond.p
# These files will cause difficulties if we ever move to a filing system
# that is case-preserving but case-insensitive (Windows, MacOS HFS).
# We count this as techdebt.

# We have a list of known problems and we want to be warned if we find
# that list is expanded.

cmp \
  .circleci/scripts/known_casetwins.txt \
  <(cd _build/poplog_base && find . -type f | tr '[:upper:]' '[:lower:]' | sort | uniq --repeated)