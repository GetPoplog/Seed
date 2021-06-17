Name: poplog
Version: 16.1
Release: 1
Summary: Poplog development environment
License: MIT
Source0: poplog.tar.gz
Buildroot: %{_tmppath}/%{name}/%{version}
Buildarch: x86_64

Requires: gcc 
Requires: glibc-devel 
Requires: ncurses-devel 
Requires: libXext-devel 
Requires: libX11-devel
Requires: libXt-devel
Requires: openmotif-devel 
Requires: xterm
Requires: espeak

%description
Poplog is a software development environment for the programming languages
POP-11, Common Lisp, Prolog, and Standard ML.

%prep
# Create the RPM from the tar file
%setup -c -n %{name}-%{version}-%{release}-x86_64

%install
# Create the new test-package directory
mkdir -p $RPM_BUILD_ROOT/opt/poplog/%{name}-%{version}-%{release}-x86_64

# Copy the contents of the RPM into our new directory
cp -Rp $RPM_BUILD_DIR/%{name}-%{version}-%{release}-x86_64/* $RPM_BUILD_ROOT/opt/poplog/%{name}-%{version}-%{release}-x86_64

%post
ln -sf /opt/poplog/%{name}-%{version}-%{release}-x86_64/pop/pop/poplog $RPM_BUILD_ROOT/%{_bindir}/poplog

%postun
# The case statement ensures that the file is only removed on uninstall, and not upgrade, downgrade, or reinstall. 
# RPM %postun for the old package runs after %post for the new package (even if that's the same version).
case "$1" in
  0) # last one out put out the lights
    rm -f %{_bindir}/poplog
  ;;
esac

%clean
rm -rf $RPM_BUILD_ROOT
rm -rf $RPM_BUILD_DIR

%files
# Set the permissions/ownership of all files in your new directory as needed
%defattr(-,root,root,-)
/opt/poplog/%{name}-%{version}-%{release}-x86_64
