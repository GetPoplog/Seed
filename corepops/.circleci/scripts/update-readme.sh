#!/bin/bash
set -euxo pipefail
README_PATH="${1:-README.md}"
TABLE_PATH="${2:-report.md}"
OUT_PATH="${3:-README-updated.md}"

BEGIN_TAG="<!--BEGIN COREPOP_TEST_RESULTS-->"
END_TAG="<!--END COREPOP_TEST_RESULTS-->"
TABLE="$(cat "$TABLE_PATH")"

# Error out if we don't have the correct tags in the README.
grep "$BEGIN_TAG" "${README_PATH}" || { echo "Missing $BEGIN_TAG in $README_PATH"; exit 1; }
grep "$END_TAG" "${README_PATH}" || { echo "Missing $END_TAG in $README_PATH"; exit 1; }

{
    # Copy everything before and including begin tag
    sed --null-data "s/\(.*${BEGIN_TAG}\n\).*/\1/" < "${README_PATH}"
    # Inject table
    echo "$TABLE"
    # Copy everything after and including end tag
    sed --null-data "s/.*\(${END_TAG}.*\)/\1/" <"${README_PATH}"
} >> "$OUT_PATH"
