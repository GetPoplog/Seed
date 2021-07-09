#!/bin/sh
# This script is used as a way of doing a 1-line install using curl o.n.o.
# Limited to working on the main branch.
set -e

SEED_BRANCH=main
SEED_TARBALL_URL=https://github.com/GetPoplog/Seed/archive/${SEED_BRANCH}.tar.gz

# Get minimum dependencies.
sudo apt update && sudo apt install -y make curl

# Retrieve our Makefile in a temporary directory
TMP_DIR=`mktemp -d -t ci-XXXXXXXXXX`
mkdir -p $TMP_DIR
cd $TMP_DIR
echo "Using temporary directory $TMP_DIR as a build folder"
curl -LsS ${SEED_TARBALL_URL} | tar zxf - --strip-components=1

sudo make jumpstart-ubuntu    # fetch dependencies (Debian based systems only)
make build
sudo make install 

echo "-----------------------------------------------------------"
echo "Poplog has been successfully installed in /usr/local/poplog"
echo "Clean up build directory"
make clean
