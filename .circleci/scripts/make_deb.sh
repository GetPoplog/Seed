#!/usr/bin/env bash
set -euxo pipefail
SEED_DIR="${1:-$PWD}"; shift

apt update && apt install -y make
cd "$SEED_DIR"
make jumpstart-debian
make deb
