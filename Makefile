.ONESHELL:
SHELL:=/bin/bash
# This is a makefile that can be used to acquire Poplog, build and install it locally.
# It will be installed into $(POPLOG_HOME_DIR), which is by default /usr/local/poplog.
# This folder supports multiple versions via the symlink current_usepop.
#
# e.g   /usr/local/poplog
#           Makefile            <- this file
#           current_usepop      <- symlink to the currently active Poplog version e.g. versions/V16
#           versions/V16        <- an example  Poplog system
#
# For help on how to use this Makefile please try "make help". The rest of this intro explains
# the strategy used for the fairly elaborate build process.
#

# CONVENTION: If we want to allow the user of the Makefile to set via the CLI
# then we use ?= to bind it. If it's an internal variables then we use :=
CC?=gcc
CFLAGS?=-g -Wall -std=c11 -D_POSIX_C_SOURCE=200809L

# The prefix variable is used to set up POPLOG_HOME_DIR and bindir (and
# nowhere else, please). It is provided in order to fit in with the conventions
# of Makefiles.
DESTDIR?=
prefix?=/usr/local
# This is the folder where the link to the poplog-shell executable will be installed.
bindir:=$(prefix)/bin

TMP_DIR?=/tmp

# This is the folder in which the new Poplog build will be installed. To install Poplog
# somewhere different, such as /opt/poplog either edit this line or try:
#     make install POPLOG_HOME_DIR=/opt/poplog
# Resulting values would be:
#   POPLOG_HOME_DIR            /opt/poplog                   $usepop/..
#   POPLOG_VERSION_DIR         /opt/poplog/V16               $usepop
#   POPLOG_VERSION_SYMLINK     /opt/poplog/current_usepop -> /opt/poplog/V16
#   POPLOCAL_HOME_DIR          /opt/poplog                   $poplocal = $usepop/..
GETPOPLOG_VERSION:=$(shell cat VERSION)
POPLOG_HOME_DIR:=$(prefix)/poplog
MAJOR_VERSION:=16
VERSION_DIR:=V$(MAJOR_VERSION)
POPLOG_VERSION_DIR:=$(POPLOG_HOME_DIR)/$(VERSION_DIR)
SYMLINK:=current_usepop
POPLOG_VERSION_SYMLINK:=$(POPLOG_HOME_DIR)/$(SYMLINK)
export GETPOPLOG_VERSION

POPLOCAL_HOME_DIR:=$(POPLOG_VERSION_DIR)/../../poplocal

SRC_TARBALL_FILENAME:=poplog-$(GETPOPLOG_VERSION)
SRC_TARBALL:=_build/artifacts/$(SRC_TARBALL_FILENAME).tar.gz
BINARY_TARBALL_FILENAME:=poplog-binary-$(GETPOPLOG_VERSION)
BINARY_TARBALL:=_build/artifacts/$(BINARY_TARBALL_FILENAME).tar.gz

.PHONY: all
all:
	$(MAKE) build
	# Target "all" completed

.PHONY: help
help:
	# This is a makefile that can be used to acquire Poplog, build and install it locally.
	# Poplog will be installed in $(POPLOG_HOME_DIR) which is typically /usr/local/poplog.
	#
	# Within $(POPLOG_HOME_DIR) there may be multiple versions of Poplog living
	# side-by-side. The current version will be symlinked via a link called
	# current_usepop. You must have write-access to this folder during the
	# "make install" step. (And during all the steps if you keep the Makefile
	# in the home-dir.)
	#
	# Note that targets marked with a [^] normally require root privileges and
	# should be run using sudo (or as root).
	#
	# Valid targets are:
	#   all [^] - installs dependencies and produces a build-tree.
	#   download - downloads all the archives required by the build process.
	#   build - creates a complete build-tree in _build/poplog_base.
	#   install [^] - installs Poplog into $(POPLOG_HOME) folder as V16.
	#   install-poplocal - installs a 'skeleton' folder for $$poplocal. Optional.
	#   uninstall [^] - removes Poplog entirely, leaving a backup in /tmp/POPLOG_HOME_DIR.tgz.
	#   test - runs self-checks on an installed Poplog system
	#   really-uninstall-poplog [^] - removes Poplog and does not create a backup.
	#   relink-and-build - a more complex build process that can relink the
	#       corepop executable and is useful for O/S upgrades.
	#   jumpstart-* [^] - and more, try `make help-jumpstart`.
	#   clean - removes all the build artifacts but not the _download cache.
	#   deepclean - removes build artifacts and the _download cache.
	#   help - this explanation, for more info read the Makefile comments.

include mk_recipes/lib.mk

include mk_recipes/helpers.mk
include mk_recipes/jumpstart.mk
include mk_recipes/download.mk
include mk_recipes/build-management.mk
include mk_recipes/tarballs.mk
include mk_recipes/packaging.mk
include mk_recipes/release.mk
include mk_recipes/install.mk
include mk_recipes/transplant.mk
