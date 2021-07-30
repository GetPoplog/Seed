#!/usr/bin/env bash
set -euxo pipefail
SEED_DIR="${1:-$PWD}"; shift

dnf install -y make
cd "$SEED_DIR"
make jumpstart-centos
make rpm
