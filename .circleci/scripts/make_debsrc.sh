#!/usr/bin/env bash
set -euxo pipefail
SEED_DIR="${1:-$PWD}"

apt update && apt install -y make
cd "$SEED_DIR"
sudo make jumpstart-debian
make debsrc
