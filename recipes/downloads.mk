# Makfile Fragment
# Assumes the following variables exist:
# - MAJOR_VERSION

.PHONY: download
download: _download/packages-V$(MAJOR_VERSION).tar.bz2 _download/poplogout.sh _download/poplogout.csh

_download/packages-V$(MAJOR_VERSION).tar.bz2:
	mkdir -p "$(@D)"
	curl -LsS "http://www.cs.bham.ac.uk/research/projects/poplog/V$(MAJOR_VERSION)/DL/packages-V$(MAJOR_VERSION).tar.bz2" > "$@"

_download/poplogout.%:
	mkdir -p "$(@D)"
	curl -LsS "https://www.cs.bham.ac.uk/research/projects/poplog/V$(MAJOR_VERSION)/DL/$(notdir $@)" > "$@"

_download/appimagetool:
	mkdir -p "$(@D)"
	curl -LSs "https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage" > "$@"
	chmod a+x "$@"
	[ -x $@ ] # Sanity check
