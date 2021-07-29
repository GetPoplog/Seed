Name: poplog
Version: 0.2
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
BuildRequires: ncurses-compat-libs
Requires: libXext
Requires: libX11
Requires: libXt
Requires: openmotif
Requires: ncurses-compat-libs
Suggests: xterm
Suggests: espeak

%description
Poplog is a software development environment for the programming languages
POP-11, Common Lisp, Prolog, and Standard ML.

%global _missing_build_ids_terminate_build 0

%prep
# Create the RPM from the tar file
# -c -n %{name}-%{version}-%{release}
umask 0
%setup -q

%build
make

%install
mkdir -p %{buildroot}/opt/#poplog/%{name}-%{version}-%{release}
make install DESTDIR=%{buildroot} prefix=/opt bindir=%{_bindir}
# Create the new test-package directory

# Copy the contents of the RPM into our new directory
# cp -Rp $RPM_BUILD_DIR/%{name}-%{version}-%{release}/* $RPM_BUILD_ROOT/opt/poplog/%{name}-%{version}-%{release}
#tar cf - -C $RPM_BUILD_DIR/%{name}-%{version}-%{release} . | tar xf - -C $RPM_BUILD_ROOT/opt/poplog/%{name}-%{version}-%{release}

#%post
#ln -sf /opt/poplog/%{name}-%{version}-%{release}/pop/pop/poplog $RPM_BUILD_ROOT/%{_bindir}/poplog

#%postun
# The case statement ensures that the file is only removed on uninstall, and not upgrade, downgrade, or reinstall.
# RPM %postun for the old package runs after %post for the new package (even if that's the same version).
#case "$1" in
#  0) # last one out put out the lights
#    rm -f %{_bindir}/poplog
#  ;;
#esac

#%clean
#rm -rf $RPM_BUILD_ROOT
#rm -rf $RPM_BUILD_DIR

%files
# Set the permissions/ownership of all files in your new directory as needed
%defattr(-,root,root,-)
/opt/poplog

