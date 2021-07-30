#!/usr/bin/env bash
set -euxo pipefail

SEED_DIR="${1:-$PWD}"

dnf install -y python3 python3-pip make
pip3 install pytest
cd "$SEED_DIR"
dnf install -y _build/artifacts/poplog-*.x86_64.rpm
make test
