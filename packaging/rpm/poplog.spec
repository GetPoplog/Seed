# See https://rpm-packaging-guide.github.io/
# for help on writing spec files.

Name: poplog
Version: 0.2.0
Release: 1
Summary: Poplog development environment
License: MIT
Source0: poplog-%{version}.tar.gz
Buildroot: %{_tmppath}/%{name}/%{version}
Buildarch: x86_64

BuildRequires: gcc
BuildRequires: glibc-devel
BuildRequires: ncurses-devel
BuildRequires: libXext-devel
BuildRequires: libX11-devel
BuildRequires: libXt-devel
BuildRequires: openmotif-devel
%if 0%{?rhel} < 8
BuildRequires: ncurses-libs
%else
BuildRequires: ncurses-compat-libs
%endif
Requires: libXext
Requires: libX11
Requires: libXt
# libXt-devel is needed for some reason, without it libXt.so load errors occur.
Requires: libXt-devel  
Requires: openmotif
%if 0%{?rhel} < 8
Requires: ncurses-libs
%else
Requires: ncurses-compat-libs
%endif

%if 0%{?rhel} < 8
# RHEL 7/CentOS 7 don't support Suggests.
%else
Suggests: csh
Suggests: xterm
Suggests: espeak
%endif

%description
Poplog is a software development environment for the programming languages
POP-11, Common Lisp, Prolog, and Standard ML.

# Currently, poplog ships some .so files which cause the post RPM build
# check to fail as they don't have build IDs stamped within them. We
# can't do much about that, so we tell rpmbuild to ignore them.
%undefine _missing_build_ids_terminate_build

%prep
# Without setting the umask, there are issues unpacking the tarballs.
umask 0
%setup -q

%build
make

%install
mkdir -p %{buildroot}/opt/#poplog/%{name}-%{version}-%{release}
make install DESTDIR=%{buildroot} prefix=/opt bindir=%{_bindir}

%files
%defattr(-,root,root,-)
/opt/poplog
/usr/bin/poplog

%changelog
