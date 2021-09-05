.PHONY: help-jumpstart
help-jumpstart:
	# Jumpstarts are targets that install the dependencies for a particular
	# Linux distribution. Installing dependencies are not part of a normal
	# build process and they are provided as a convenience to admins.
	# These will need to be run with sudo e.g.
	#	sudo make jumpstart-debian
	#
	# Valid targets are:
	#   jumpstart-debian - installs the packages a Debian system needs
	#   jumpstart-ubuntu - installs the packages an Ubuntu system needs
	#   jumpstart-fedora - installs the packages a Fedora system needs.
	#   jumpstart-rocky - installs the packages a Rocky Linux system needs.
	#   jumpstart-centos - installs the packages a Rocky Linux system needs.
	#   jumpstart-opensuse-leap - installs the packages a openSUSE Leap system needs.
	#

# These results install the dependencies
#   needed to fetch resources:
#       make curl
#   needed for building Poplog:
#       build-essential libc6 libncurses5 libncurses5-dev
#       libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev
#   needed for building popvision
#       csh
#   needed at run-time by some tutorials
#       espeak
#   optional - not included as these are not part of the essential package but
#   are properly supported by Poplog.
#       tcsh xterm
#
.PHONY: jumpstart-debian
jumpstart-debian:
	apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
	make curl \
	gcc build-essential libc6 libncurses5 libncurses5-dev \
	libstdc++6 libxext6 libxext-dev libx11-6 libx11-dev libxt-dev libmotif-dev \
	libc6-i386 debmake debhelper \
	python3 python3-pip \
	csh \
	espeak

.PHONY: jumpstart-ubuntu
jumpstart-ubuntu:
	$(MAKE) jumpstart-debian

.PHONY: jumpstart-fedora
jumpstart-fedora:
	dnf install -y \
	curl make bzip2 \
	gcc glibc-devel ncurses-devel libXext-devel libX11-devel \
	libXt-devel openmotif-devel xterm espeak csh

.PHONY: jumpstart-centos
jumpstart-centos:
	dnf install -y \
	curl make bzip2 \
	gcc glibc-devel ncurses-devel libXext-devel libX11-devel \
	libXt-devel openmotif-devel xterm csh ncurses-compat-libs \
	rpm-build

.PHONY: jumpstart-rocky
jumpstart-rocky: jumpstart-centos

.PHONY: jumpstart-opensuse-leap
jumpstart-opensuse-leap:
	zypper --non-interactive install \
	curl make bzip2 \
	gcc libstdc++6 libncurses5 ncurses5-devel \
	libXext6 libX11-6 libX11-devel libXt-devel openmotif-devel \
	xterm espeak csh

