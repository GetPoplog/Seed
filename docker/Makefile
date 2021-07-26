# This is an optional Makefile that is used to generate a variant security
# profile for using Poplog under Docker. See the wiki page
# https://github.com/GetPoplog/Seed/wiki/Running-poplog-under-Docker to learn
# more about this topic.

# Pre-requisites for using this file
#	python3 wget

.PHONY: all
all: build

.PHONY: help
help:
	# Valid targets are:
	#   all, build - creates the security profile
	#	clean - removes all build artefacts but not the _download cache.
	#   deepclean - removes all build artefacts and also the _download cache.
	#   help - lists the valid targets of this particular Makefile

.PHONY: build
build: _build/poplog_seccomp.json

.PHONY: clean
clean:
	rm -rf _build

.PHONY: deepclean
deepclean: clean
	rm -rf _download

# Generate a Docker security profile
_build/poplog_seccomp.json: _download/default.json
	mkdir -p _build
	python3 seccomp.py _download/default.json > $@

_download/default.json:
	mkdir -p _download
	cd _download; wget https://raw.githubusercontent.com/moby/moby/master/profiles/seccomp/default.json

