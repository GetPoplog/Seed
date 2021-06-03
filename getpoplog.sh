#!/bin/sh

# Get minimum dependencies.
sudo apt update && sudo apt install -y make curl

# Retrieve our Makefile in a temporary directory
TMP_DIR=$(mktemp -d -t ci-XXXXXXXXXX)
mkdir -p $TMP_DIR
cd $TMPDIR
echo "Using temporary directory $TMPDIR as a build folder"
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/Makefile > Makefile

make jumpstart    # fetch dependencies (Debian based systems only)
make build
sudo make install 

echo "-----------------------------------------------------------"
echo "Poplog has been successfully installed in /usr/local/poplog"
echo "Clean up build directory"
make clean
