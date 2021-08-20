#!/bin/bash
set -euxo pipefail
README_PATH="${1:-README.md}"
TABLE_PATH="${2:-report.md}"
OUT_PATH="${3:-README-updated.md}"

BEGIN_TAG="<!--BEGIN COREPOP_TEST_RESULTS-->"
END_TAG="<!--END COREPOP_TEST_RESULTS-->"
TABLE="$(cat "$TABLE_PATH")"

# Copy everything before and including begin tag
sed --null-data "s/\(.*${BEGIN_TAG}\n\).*/\1/" < "${README_PATH}" >> "$OUT_PATH"
# Inject table
echo "$TABLE" >> "$OUT_PATH"
# Copy everything after and including end tag
sed --null-data "s/.*\(${END_TAG}.*\)/\1/" <"${README_PATH}" >> "$OUT_PATH"
