# Seed

This is repository contains the source code to build a functioning Poplog system.
The build scripts will download all needed third party dependencies, including
the needed contributory packages from the
[FreePoplog](https://www.cs.bham.ac.uk/research/projects/poplog/freepoplog.html)
site.

At the moment we only support installing Poplog onto Linux x86_64 systems i.e.
64-bit Linux on Intel. We expect to extend this to include 32-bit and other Unix
systems that Poplog has run on.

[![CircleCI](https://circleci.com/gh/GetPoplog/Seed/tree/main.svg?style=svg)](https://circleci.com/gh/GetPoplog/Seed/tree/main)

## How to Install Poplog using this resource

### Single-line install using curl (Debian-based distributions only)

The simplest way to install Poplog on a debian-based distribution is to run the
below command at the command-line. It will need you to have curl, sudo and apt
already installed.

Linux commands sudo and apt are typically available by default however curl may need to be installed. To install curl:

```
sudo apt install curl
```

Now you can run the single-line Install Poplog command.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh | sh
```
The first thing it will do is ask for permission to install packages that it depends on.

If you want to check the script out before running it you might prefer fetching
it to a file and then running it.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh -o GetPoplog.sh
# Now check GetPoplog.sh .... and run it.
sh GetPoplog.sh
```

When the script finishes successfully, it will install Poplog into `/usr/local/poplog`.

Although this 1-line script is easy to use, it does not give you much chance to see
what is going on or make any changes. If you know a bit about Linux commands and
want more control over what it does (e.g. change where it installs the software)
then try the next "make" based installation method.

### More flexible install using make

If you have a desktop system with `apt`, `sudo`, `make` and `git` installed then
a flexible approach is to clone this repo to a new local folder as follows:

```
git clone https://github.com/GetPoplog/Seed.git
cd Seed
```

This will create a folder called `Seed` in your current directory, which can
be renamed or moved to any location you like. This folder contains a Makefile
and some helper-shell scripts that you can use to install Poplog in a
controlled fashion.

The first thing you will need to do is install the packages that Poplog depends
on. You only need to do this once. There are shortcuts for doing this on Debian,
Ubuntu, Fedora and OpenSUSE. You can list these 'jumpstarts' with
`make help-jumpstart`. They are all named in an obvious way. You need to pick
the one that is appropriate for your system. Here's how you would do it for
an Ubuntu system.

```sh
make jumpstart-ubuntu     # fetch all dependencies for Ubuntu
```

After this you build and install in the usual way. The following commands
will build a new Poplog system in the temporary `_build` folder and then
install it into the default location, which is `/usr/local/poplog`.

```sh
make build         # this takes a while
sudo make install  # installs into /usr/local/poplog
```

If you want to override the installation location, you can override the
POPLOG_HOME_DIR variable during the install phase like this:

```sh
sudo make install POPLOG_HOME_DIR=/opt/poplog
```

When you have finished installing Poplog, you can tidy up afterwards with the
following:
```sh
make clean
```

## Getting Started with the new poplog executable

This distribution of Poplog includes a new `poplog` executable. This provides a
simple way of running any of Poplog's commands. For example, without any arguments
it starts up a Pop-11 read-eval-print loop.

```sh
$ poplog

Sussex Poplog (Version 16.0001 Mon May 17 13:04:57 EDT 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

To find out all the features that this 'commander' makes available please type
`poplog --help`, as shown below:
```sh
$ poplog --help
Usage: poplog [command-word] [options] [file(s)]

The poplog "commander" runs various Poplog commands (pop11, prolog, etc) with
the special environment variables and $PATH they require. The 'command-word'
determines what command is actually run.

INTERPRETER COMMANDS

poplog (pop11|prolog|clisp|pml) [options]
poplog (pop11|prolog|clisp|pml) [options] [file]

... output truncated ...
```


## How to Set-up your Login Account to use Poplog

Before the new poplog executable, the standard way to use Poplog was to 'source'
a set-up script into your login shell. If you prefer that more long-standing
way to use Poplog, follow these instructions.

Poplog's features requires your $PATH to be extended so that the commands are
available and also available to each other. And they also requires many environment
variables to be added.

The setup is slightly different depending on what shell you are using, so we
provide setup procedures for bash, zsh, csh and tcsh users. And if you don't know
what shell you are using try the command `echo $SHELL`, which works under several
different shells - or you can take a look in `/etc/passwd` and find your login
there.

### Set-up for /bin/bash Users

Depending on how your system administrator has set up users on the system,
start up commands go into one of `.bash_profile`, `.profile` or `.bash_login`.
Just check to see which one of these you have got in your home directory. The
commonest is `.bash_profile`, so that's what we use in this example.

Edit your `~/.bash_profile` file and insert the following at the end of
the file, which will include the setup from a separate file.

```sh
. ~/.poplog/setup.sh
```

It is a good idea to separate the setup-file from your `~/.bash_profile`. Poplog
is a rich and complex environment and putting your set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.sh` and insert these lines:
```sh
poplib=~/.poplog
export poplib
usepop=/usr/local/poplog/current_usepop
export usepop
# The poplog.sh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.sh > /dev/null
```

Try this out with the command `. ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/csh and /bin/tcsh Users

Edit your `~/.login` file and insert the following at the end of
the file, which will include the setup from a separate file.

```shell
source ~/.poplog/setup.csh
```

It is a good idea to separate the setup-file from your `~/.login`. Poplog
is a rich and complex environment and putting the set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.csh` and insert these lines:
```shell
setenv poplib=~/.poplog
setenv usepop=/usr/local/poplog/current_usepop
# The poplog.csh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.csh > /dev/null
```

Try this out with the command `source ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```shell
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/sh and /bin/dash Users

Follow the instructions for /bin/bash users but edit your `~/.profile`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

### Set-up for /bin/zsh

Follow the instructions for /bin/bash users but edit your `~/.zshenv`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

## Our Aims

We aim to automate of the production and test of reliable, easy-to-use, simple installation methods for Poplog that deliver a well-organised but flexible installation.
- By reliable we mean that it copes with a wide variety of distributions without intervention
- By easy-to-use we mean that it uses well-established packaging mechanisms on our target platforms
- By simple we mean that users can immediately use it after installation without changing login scripts
- By well-organised we mean that its installed commands and environment-variables are few and well-grouped together
- By flexible we mean that advanced users can easily configure the full array of Poplog commands and linkage by environment variables.

This work is only possible thanks to Aaron Sloman's dedication in maintaining
the FreePoplog archive over the years.
| Corepop | Distribution | Version | Pass | Exit code | Logs |
| ------- | ------------ | ------- | ---- | --------- | ---- |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: e17bbf1f66> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: fd08d87414> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 8c1f3ccc8d> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: f8c527acf6> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 09c77a7d2a> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: cfb57fdad8> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: a69a27e2e9> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: d87d738b00> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 21a4417b75> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: fef463b776> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: e1912eeb20> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 640d1363ee> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 0c3b9c880c> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: e8cba39b5e> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 022eb137a0> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 48988bcd79> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: abdb30113a> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: ac03c1241e> | 18.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 68417cdef6> | 16.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: a75919ecc4> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 2f52c9ae27> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 1ba64d73f2> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 217874ddde> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: e0aa79b9f6> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 423c5e7b82> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 1402c3e121> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 021d527c88> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: b8c4c57875> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: ed2e49f3a5> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 9c616939e4> | 7 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: f37c08b6c6> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: b2112872aa> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5db711346c> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 6f304ae52a> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: ee0ea3e320> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: ce2f678be0> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 9839d466ea> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: c88873a1b8> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5e34f13b81> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 713c042de0> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: c46ead69e9> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 55654b20df> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: a2670bf83f> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5aff78824e> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: b6c97c04b9> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: eb33b629b6> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 6b76724831> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 91e2ca2742> | 18.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 90ac32359c> | 16.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 06956fd0c0> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 45fc366ad6> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: bcb01b38cc> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: e74f75a120> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: dee5c8540c> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: c6b81c6cbf> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 9a4e824cce> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: eda2c77289> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 143132c84a> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 6be3e61951> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 5a0ac4ed81> | 7 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 2cbfbf3511> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: ba1271dfa5> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 798a4ab711> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: c1c548581d> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: bb4002d16f> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: c09c0ef0a4> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 047d261728> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 8f6c5324a8> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: ae33bfd390> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 33d2a39906> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: fd14c88325> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 1f62317741> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: a5095e7c0f> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: b6c3c661f4> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 90308b181d> | 7 | :x: | 0 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br></pre></details> |
# Seed

This is repository contains the source code to build a functioning Poplog system.
The build scripts will download all needed third party dependencies, including
the needed contributory packages from the
[FreePoplog](https://www.cs.bham.ac.uk/research/projects/poplog/freepoplog.html)
site.

At the moment we only support installing Poplog onto Linux x86_64 systems i.e.
64-bit Linux on Intel. We expect to extend this to include 32-bit and other Unix
systems that Poplog has run on.

[![CircleCI](https://circleci.com/gh/GetPoplog/Seed/tree/main.svg?style=svg)](https://circleci.com/gh/GetPoplog/Seed/tree/main)

## How to Install Poplog using this resource

### Single-line install using curl (Debian-based distributions only)

The simplest way to install Poplog on a debian-based distribution is to run the
below command at the command-line. It will need you to have curl, sudo and apt
already installed.

Linux commands sudo and apt are typically available by default however curl may need to be installed. To install curl:

```
sudo apt install curl
```

Now you can run the single-line Install Poplog command.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh | sh
```
The first thing it will do is ask for permission to install packages that it depends on.

If you want to check the script out before running it you might prefer fetching
it to a file and then running it.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh -o GetPoplog.sh
# Now check GetPoplog.sh .... and run it.
sh GetPoplog.sh
```

When the script finishes successfully, it will install Poplog into `/usr/local/poplog`.

Although this 1-line script is easy to use, it does not give you much chance to see
what is going on or make any changes. If you know a bit about Linux commands and
want more control over what it does (e.g. change where it installs the software)
then try the next "make" based installation method.

### More flexible install using make

If you have a desktop system with `apt`, `sudo`, `make` and `git` installed then
a flexible approach is to clone this repo to a new local folder as follows:

```
git clone https://github.com/GetPoplog/Seed.git
cd Seed
```

This will create a folder called `Seed` in your current directory, which can
be renamed or moved to any location you like. This folder contains a Makefile
and some helper-shell scripts that you can use to install Poplog in a
controlled fashion.

The first thing you will need to do is install the packages that Poplog depends
on. You only need to do this once. There are shortcuts for doing this on Debian,
Ubuntu, Fedora and OpenSUSE. You can list these 'jumpstarts' with
`make help-jumpstart`. They are all named in an obvious way. You need to pick
the one that is appropriate for your system. Here's how you would do it for
an Ubuntu system.

```sh
make jumpstart-ubuntu     # fetch all dependencies for Ubuntu
```

After this you build and install in the usual way. The following commands
will build a new Poplog system in the temporary `_build` folder and then
install it into the default location, which is `/usr/local/poplog`.

```sh
make build         # this takes a while
sudo make install  # installs into /usr/local/poplog
```

If you want to override the installation location, you can override the
POPLOG_HOME_DIR variable during the install phase like this:

```sh
sudo make install POPLOG_HOME_DIR=/opt/poplog
```

When you have finished installing Poplog, you can tidy up afterwards with the
following:
```sh
make clean
```

## Getting Started with the new poplog executable

This distribution of Poplog includes a new `poplog` executable. This provides a
simple way of running any of Poplog's commands. For example, without any arguments
it starts up a Pop-11 read-eval-print loop.

```sh
$ poplog

Sussex Poplog (Version 16.0001 Mon May 17 13:04:57 EDT 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

To find out all the features that this 'commander' makes available please type
`poplog --help`, as shown below:
```sh
$ poplog --help
Usage: poplog [command-word] [options] [file(s)]

The poplog "commander" runs various Poplog commands (pop11, prolog, etc) with
the special environment variables and $PATH they require. The 'command-word'
determines what command is actually run.

INTERPRETER COMMANDS

poplog (pop11|prolog|clisp|pml) [options]
poplog (pop11|prolog|clisp|pml) [options] [file]

... output truncated ...
```


## How to Set-up your Login Account to use Poplog

Before the new poplog executable, the standard way to use Poplog was to 'source'
a set-up script into your login shell. If you prefer that more long-standing
way to use Poplog, follow these instructions.

Poplog's features requires your $PATH to be extended so that the commands are
available and also available to each other. And they also requires many environment
variables to be added.

The setup is slightly different depending on what shell you are using, so we
provide setup procedures for bash, zsh, csh and tcsh users. And if you don't know
what shell you are using try the command `echo $SHELL`, which works under several
different shells - or you can take a look in `/etc/passwd` and find your login
there.

### Set-up for /bin/bash Users

Depending on how your system administrator has set up users on the system,
start up commands go into one of `.bash_profile`, `.profile` or `.bash_login`.
Just check to see which one of these you have got in your home directory. The
commonest is `.bash_profile`, so that's what we use in this example.

Edit your `~/.bash_profile` file and insert the following at the end of
the file, which will include the setup from a separate file.

```sh
. ~/.poplog/setup.sh
```

It is a good idea to separate the setup-file from your `~/.bash_profile`. Poplog
is a rich and complex environment and putting your set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.sh` and insert these lines:
```sh
poplib=~/.poplog
export poplib
usepop=/usr/local/poplog/current_usepop
export usepop
# The poplog.sh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.sh > /dev/null
```

Try this out with the command `. ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/csh and /bin/tcsh Users

Edit your `~/.login` file and insert the following at the end of
the file, which will include the setup from a separate file.

```shell
source ~/.poplog/setup.csh
```

It is a good idea to separate the setup-file from your `~/.login`. Poplog
is a rich and complex environment and putting the set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.csh` and insert these lines:
```shell
setenv poplib=~/.poplog
setenv usepop=/usr/local/poplog/current_usepop
# The poplog.csh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.csh > /dev/null
```

Try this out with the command `source ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```shell
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/sh and /bin/dash Users

Follow the instructions for /bin/bash users but edit your `~/.profile`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

### Set-up for /bin/zsh

Follow the instructions for /bin/bash users but edit your `~/.zshenv`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

## Our Aims

We aim to automate of the production and test of reliable, easy-to-use, simple installation methods for Poplog that deliver a well-organised but flexible installation.
- By reliable we mean that it copes with a wide variety of distributions without intervention
- By easy-to-use we mean that it uses well-established packaging mechanisms on our target platforms
- By simple we mean that users can immediately use it after installation without changing login scripts
- By well-organised we mean that its installed commands and environment-variables are few and well-grouped together
- By flexible we mean that advanced users can easily configure the full array of Poplog commands and linkage by environment variables.

This work is only possible thanks to Aaron Sloman's dedication in maintaining
the FreePoplog archive over the years.
| Corepop | Distribution | Version | Pass | Exit code | Logs |
| ------- | ------------ | ------- | ---- | --------- | ---- |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 05ba96926f> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: f8da8ef059> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: b334a7636d> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: f7efb7e982> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: b53f648daa> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: f7c896fc1f> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 7cd3884085> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: ef66f9f4b9> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 412d55ca44> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 9dfbb9e24d> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 4e3d25f6bd> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 8a22798dc6> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 8831e9ae30> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: a3b4954e3c> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 0591499643> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: dfc24a561d> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: e58c846dc0> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 8bb9c686cf> | 18.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 2b3e5b4b11> | 16.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: d77eb662d4> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 358145ef15> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: a1248ce31b> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: b79f1cd8d9> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 2b23fb0434> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 0b7aa61d20> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: b82d0bc435> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 86c1f3edb5> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 5ec2b8f654> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 168c108d9e> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 172fba0a29> | 7 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: e492e0b5d6> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 4bd8373b1b> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 874705be32> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 1bbcca122a> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 41cf6fedc3> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: fcbb62ae6c> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 2ea34305e8> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 4efad3f343> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5d3e7f1fdc> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 89843302b5> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 263220e680> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 922939cf9c> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5844b4317a> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: dae5fd1972> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 930c78f96d> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 84f7ac9eb4> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 6bebe88153> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 11f9e939a9> | 18.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 020e73119e> | 16.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 6d10cb8fb2> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 227667f50e> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 3210660188> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: ddffd1aba4> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: c13c8ffbb4> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: ab4e81bc60> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 3ed44cc5c7> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 1e36ca1b58> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: b322eef355> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 57c88bd29b> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 30d4a83f07> | 7 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 64f5da72ee> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 4df018d752> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 6589982e17> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 0b9f1754b0> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: d266805f59> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 2230f7884b> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 8eb2539373> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: c72c237a90> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 69e967b889> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 6cb2aaba3a> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: c890c6b427> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 7182ef1b85> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 8757270d85> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 101e9b87ea> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: cab05ad978> | 7 | :x: | 0 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br></pre></details> |
# Seed

This is repository contains the source code to build a functioning Poplog system.
The build scripts will download all needed third party dependencies, including
the needed contributory packages from the
[FreePoplog](https://www.cs.bham.ac.uk/research/projects/poplog/freepoplog.html)
site.

At the moment we only support installing Poplog onto Linux x86_64 systems i.e.
64-bit Linux on Intel. We expect to extend this to include 32-bit and other Unix
systems that Poplog has run on.

[![CircleCI](https://circleci.com/gh/GetPoplog/Seed/tree/main.svg?style=svg)](https://circleci.com/gh/GetPoplog/Seed/tree/main)

## How to Install Poplog using this resource

### Single-line install using curl (Debian-based distributions only)

The simplest way to install Poplog on a debian-based distribution is to run the
below command at the command-line. It will need you to have curl, sudo and apt
already installed.

Linux commands sudo and apt are typically available by default however curl may need to be installed. To install curl:

```
sudo apt install curl
```

Now you can run the single-line Install Poplog command.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh | sh
```
The first thing it will do is ask for permission to install packages that it depends on.

If you want to check the script out before running it you might prefer fetching
it to a file and then running it.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh -o GetPoplog.sh
# Now check GetPoplog.sh .... and run it.
sh GetPoplog.sh
```

When the script finishes successfully, it will install Poplog into `/usr/local/poplog`.

Although this 1-line script is easy to use, it does not give you much chance to see
what is going on or make any changes. If you know a bit about Linux commands and
want more control over what it does (e.g. change where it installs the software)
then try the next "make" based installation method.

### More flexible install using make

If you have a desktop system with `apt`, `sudo`, `make` and `git` installed then
a flexible approach is to clone this repo to a new local folder as follows:

```
git clone https://github.com/GetPoplog/Seed.git
cd Seed
```

This will create a folder called `Seed` in your current directory, which can
be renamed or moved to any location you like. This folder contains a Makefile
and some helper-shell scripts that you can use to install Poplog in a
controlled fashion.

The first thing you will need to do is install the packages that Poplog depends
on. You only need to do this once. There are shortcuts for doing this on Debian,
Ubuntu, Fedora and OpenSUSE. You can list these 'jumpstarts' with
`make help-jumpstart`. They are all named in an obvious way. You need to pick
the one that is appropriate for your system. Here's how you would do it for
an Ubuntu system.

```sh
make jumpstart-ubuntu     # fetch all dependencies for Ubuntu
```

After this you build and install in the usual way. The following commands
will build a new Poplog system in the temporary `_build` folder and then
install it into the default location, which is `/usr/local/poplog`.

```sh
make build         # this takes a while
sudo make install  # installs into /usr/local/poplog
```

If you want to override the installation location, you can override the
POPLOG_HOME_DIR variable during the install phase like this:

```sh
sudo make install POPLOG_HOME_DIR=/opt/poplog
```

When you have finished installing Poplog, you can tidy up afterwards with the
following:
```sh
make clean
```

## Getting Started with the new poplog executable

This distribution of Poplog includes a new `poplog` executable. This provides a
simple way of running any of Poplog's commands. For example, without any arguments
it starts up a Pop-11 read-eval-print loop.

```sh
$ poplog

Sussex Poplog (Version 16.0001 Mon May 17 13:04:57 EDT 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

To find out all the features that this 'commander' makes available please type
`poplog --help`, as shown below:
```sh
$ poplog --help
Usage: poplog [command-word] [options] [file(s)]

The poplog "commander" runs various Poplog commands (pop11, prolog, etc) with
the special environment variables and $PATH they require. The 'command-word'
determines what command is actually run.

INTERPRETER COMMANDS

poplog (pop11|prolog|clisp|pml) [options]
poplog (pop11|prolog|clisp|pml) [options] [file]

... output truncated ...
```


## How to Set-up your Login Account to use Poplog

Before the new poplog executable, the standard way to use Poplog was to 'source'
a set-up script into your login shell. If you prefer that more long-standing
way to use Poplog, follow these instructions.

Poplog's features requires your $PATH to be extended so that the commands are
available and also available to each other. And they also requires many environment
variables to be added.

The setup is slightly different depending on what shell you are using, so we
provide setup procedures for bash, zsh, csh and tcsh users. And if you don't know
what shell you are using try the command `echo $SHELL`, which works under several
different shells - or you can take a look in `/etc/passwd` and find your login
there.

### Set-up for /bin/bash Users

Depending on how your system administrator has set up users on the system,
start up commands go into one of `.bash_profile`, `.profile` or `.bash_login`.
Just check to see which one of these you have got in your home directory. The
commonest is `.bash_profile`, so that's what we use in this example.

Edit your `~/.bash_profile` file and insert the following at the end of
the file, which will include the setup from a separate file.

```sh
. ~/.poplog/setup.sh
```

It is a good idea to separate the setup-file from your `~/.bash_profile`. Poplog
is a rich and complex environment and putting your set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.sh` and insert these lines:
```sh
poplib=~/.poplog
export poplib
usepop=/usr/local/poplog/current_usepop
export usepop
# The poplog.sh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.sh > /dev/null
```

Try this out with the command `. ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/csh and /bin/tcsh Users

Edit your `~/.login` file and insert the following at the end of
the file, which will include the setup from a separate file.

```shell
source ~/.poplog/setup.csh
```

It is a good idea to separate the setup-file from your `~/.login`. Poplog
is a rich and complex environment and putting the set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.csh` and insert these lines:
```shell
setenv poplib=~/.poplog
setenv usepop=/usr/local/poplog/current_usepop
# The poplog.csh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.csh > /dev/null
```

Try this out with the command `source ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```shell
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/sh and /bin/dash Users

Follow the instructions for /bin/bash users but edit your `~/.profile`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

### Set-up for /bin/zsh

Follow the instructions for /bin/bash users but edit your `~/.zshenv`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

## Our Aims

We aim to automate of the production and test of reliable, easy-to-use, simple installation methods for Poplog that deliver a well-organised but flexible installation.
- By reliable we mean that it copes with a wide variety of distributions without intervention
- By easy-to-use we mean that it uses well-established packaging mechanisms on our target platforms
- By simple we mean that users can immediately use it after installation without changing login scripts
- By well-organised we mean that its installed commands and environment-variables are few and well-grouped together
- By flexible we mean that advanced users can easily configure the full array of Poplog commands and linkage by environment variables.

This work is only possible thanks to Aaron Sloman's dedication in maintaining
the FreePoplog archive over the years.
| Corepop | Distribution | Version | Pass | Exit code | Logs |
| ------- | ------------ | ------- | ---- | --------- | ---- |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: e17bbf1f66> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: fd08d87414> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 8c1f3ccc8d> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: f8c527acf6> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 09c77a7d2a> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: cfb57fdad8> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: a69a27e2e9> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: d87d738b00> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 21a4417b75> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: fef463b776> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: e1912eeb20> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 640d1363ee> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 0c3b9c880c> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: e8cba39b5e> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/010-05_11_12-2021_07_07.corepop | <Container: 022eb137a0> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 48988bcd79> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: abdb30113a> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: ac03c1241e> | 18.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 68417cdef6> | 16.04 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: a75919ecc4> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 2f52c9ae27> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 1ba64d73f2> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 217874ddde> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: e0aa79b9f6> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 423c5e7b82> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 1402c3e121> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 021d527c88> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: b8c4c57875> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: ed2e49f3a5> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/020-05_08_00-2021_06_24.corepop | <Container: 9c616939e4> | 7 | :x: | 1 | <details><summary>details</summary><pre>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br>/corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop: /lib64/libm.so.6: version `GLIBC_2.29' not found (required by /corepops/linux/x86_64/020-05_08_00-2021_06_24.corepop)<br></pre></details> |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: f37c08b6c6> | 21.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: b2112872aa> | 20.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5db711346c> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 6f304ae52a> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: ee0ea3e320> | latest | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: ce2f678be0> | unstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 9839d466ea> | testing-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: c88873a1b8> | stable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5e34f13b81> | oldstable-slim | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 713c042de0> | oldoldstable | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: c46ead69e9> | 34 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 55654b20df> | 33 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: a2670bf83f> | 32 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: 5aff78824e> | 8 | :heavy_check_mark: | 0 |  |
| linux/x86_64/030-05_04_00-2020_08_22.corepop | <Container: b6c97c04b9> | 7 | :heavy_check_mark: | 0 |  |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: eb33b629b6> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 6b76724831> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 91e2ca2742> | 18.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 90ac32359c> | 16.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 06956fd0c0> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 45fc366ad6> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: bcb01b38cc> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: e74f75a120> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: dee5c8540c> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: c6b81c6cbf> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 9a4e824cce> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: eda2c77289> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 143132c84a> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 6be3e61951> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/040-05_08_00-2021_07_30.corepop | <Container: 5a0ac4ed81> | 7 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/040-05_08_00-2021_07_30.corepop: error while loading shared libraries: libXt.so.6: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 2cbfbf3511> | 21.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: ba1271dfa5> | 20.04 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 798a4ab711> | 18.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: c1c548581d> | 16.04 | :heavy_check_mark: | 0 |  |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: bb4002d16f> | latest | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: c09c0ef0a4> | unstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 047d261728> | testing-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 8f6c5324a8> | stable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: ae33bfd390> | oldstable-slim | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 33d2a39906> | oldoldstable | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: fd14c88325> | 34 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 1f62317741> | 33 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: a5095e7c0f> | 32 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: b6c3c661f4> | 8 | :x: | 127 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory<br></pre></details> |
| linux/x86_64/050-04_04_00-2020_00_00.corepop | <Container: 90308b181d> | 7 | :x: | 0 | <details><summary>details</summary><pre>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br>/corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop: /lib64/libtinfo.so.5: no version information available (required by /corepops/linux/x86_64/050-04_04_00-2020_00_00.corepop)<br></pre></details> |
# Seed

This is repository contains the source code to build a functioning Poplog system.
The build scripts will download all needed third party dependencies, including
the needed contributory packages from the
[FreePoplog](https://www.cs.bham.ac.uk/research/projects/poplog/freepoplog.html)
site.

At the moment we only support installing Poplog onto Linux x86_64 systems i.e.
64-bit Linux on Intel. We expect to extend this to include 32-bit and other Unix
systems that Poplog has run on.

[![CircleCI](https://circleci.com/gh/GetPoplog/Seed/tree/main.svg?style=svg)](https://circleci.com/gh/GetPoplog/Seed/tree/main)

## How to Install Poplog using this resource

### Single-line install using curl (Debian-based distributions only)

The simplest way to install Poplog on a debian-based distribution is to run the
below command at the command-line. It will need you to have curl, sudo and apt
already installed.

Linux commands sudo and apt are typically available by default however curl may need to be installed. To install curl:

```
sudo apt install curl
```

Now you can run the single-line Install Poplog command.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh | sh
```
The first thing it will do is ask for permission to install packages that it depends on.

If you want to check the script out before running it you might prefer fetching
it to a file and then running it.

```sh
curl -LsS https://raw.githubusercontent.com/GetPoplog/Seed/main/GetPoplog.sh -o GetPoplog.sh
# Now check GetPoplog.sh .... and run it.
sh GetPoplog.sh
```

When the script finishes successfully, it will install Poplog into `/usr/local/poplog`.

Although this 1-line script is easy to use, it does not give you much chance to see
what is going on or make any changes. If you know a bit about Linux commands and
want more control over what it does (e.g. change where it installs the software)
then try the next "make" based installation method.

### More flexible install using make

If you have a desktop system with `apt`, `sudo`, `make` and `git` installed then
a flexible approach is to clone this repo to a new local folder as follows:

```
git clone https://github.com/GetPoplog/Seed.git
cd Seed
```

This will create a folder called `Seed` in your current directory, which can
be renamed or moved to any location you like. This folder contains a Makefile
and some helper-shell scripts that you can use to install Poplog in a
controlled fashion.

The first thing you will need to do is install the packages that Poplog depends
on. You only need to do this once. There are shortcuts for doing this on Debian,
Ubuntu, Fedora and OpenSUSE. You can list these 'jumpstarts' with
`make help-jumpstart`. They are all named in an obvious way. You need to pick
the one that is appropriate for your system. Here's how you would do it for
an Ubuntu system.

```sh
make jumpstart-ubuntu     # fetch all dependencies for Ubuntu
```

After this you build and install in the usual way. The following commands
will build a new Poplog system in the temporary `_build` folder and then
install it into the default location, which is `/usr/local/poplog`.

```sh
make build         # this takes a while
sudo make install  # installs into /usr/local/poplog
```

If you want to override the installation location, you can override the
POPLOG_HOME_DIR variable during the install phase like this:

```sh
sudo make install POPLOG_HOME_DIR=/opt/poplog
```

When you have finished installing Poplog, you can tidy up afterwards with the
following:
```sh
make clean
```

## Getting Started with the new poplog executable

This distribution of Poplog includes a new `poplog` executable. This provides a
simple way of running any of Poplog's commands. For example, without any arguments
it starts up a Pop-11 read-eval-print loop.

```sh
$ poplog

Sussex Poplog (Version 16.0001 Mon May 17 13:04:57 EDT 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

To find out all the features that this 'commander' makes available please type
`poplog --help`, as shown below:
```sh
$ poplog --help
Usage: poplog [command-word] [options] [file(s)]

The poplog "commander" runs various Poplog commands (pop11, prolog, etc) with
the special environment variables and $PATH they require. The 'command-word'
determines what command is actually run.

INTERPRETER COMMANDS

poplog (pop11|prolog|clisp|pml) [options]
poplog (pop11|prolog|clisp|pml) [options] [file]

... output truncated ...
```


## How to Set-up your Login Account to use Poplog

Before the new poplog executable, the standard way to use Poplog was to 'source'
a set-up script into your login shell. If you prefer that more long-standing
way to use Poplog, follow these instructions.

Poplog's features requires your $PATH to be extended so that the commands are
available and also available to each other. And they also requires many environment
variables to be added.

The setup is slightly different depending on what shell you are using, so we
provide setup procedures for bash, zsh, csh and tcsh users. And if you don't know
what shell you are using try the command `echo $SHELL`, which works under several
different shells - or you can take a look in `/etc/passwd` and find your login
there.

### Set-up for /bin/bash Users

Depending on how your system administrator has set up users on the system,
start up commands go into one of `.bash_profile`, `.profile` or `.bash_login`.
Just check to see which one of these you have got in your home directory. The
commonest is `.bash_profile`, so that's what we use in this example.

Edit your `~/.bash_profile` file and insert the following at the end of
the file, which will include the setup from a separate file.

```sh
. ~/.poplog/setup.sh
```

It is a good idea to separate the setup-file from your `~/.bash_profile`. Poplog
is a rich and complex environment and putting your set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.sh` and insert these lines:
```sh
poplib=~/.poplog
export poplib
usepop=/usr/local/poplog/current_usepop
export usepop
# The poplog.sh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.sh > /dev/null
```

Try this out with the command `. ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/csh and /bin/tcsh Users

Edit your `~/.login` file and insert the following at the end of
the file, which will include the setup from a separate file.

```shell
source ~/.poplog/setup.csh
```

It is a good idea to separate the setup-file from your `~/.login`. Poplog
is a rich and complex environment and putting the set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. We recommend
putting this script in `~/.poplog` and making this your `$poplib`.

Now create `~/.poplog/setup.csh` and insert these lines:
```shell
setenv poplib=~/.poplog
setenv usepop=/usr/local/poplog/current_usepop
# The poplog.csh script prints a banner - redirect to /dev/null.
. $usepop/pop/com/poplog.csh > /dev/null
```

Try this out with the command `source ~/.poplog/setup.sh` and then
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```shell
$ pop11

Sussex Poplog (Version 16.0001 Sat Jan 30 19:13:48 CST 2021)
Copyright (c) 1982-1999 University of Sussex. All rights reserved.

Setpop
:
```

### Set-up for /bin/sh and /bin/dash Users

Follow the instructions for /bin/bash users but edit your `~/.profile`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

### Set-up for /bin/zsh

Follow the instructions for /bin/bash users but edit your `~/.zshenv`
file rather than `~/.bash_profile`. We have deliberately kept the
initial scripts compatible across these very closely related shells.

## Our Aims

We aim to automate of the production and test of reliable, easy-to-use, simple installation methods for Poplog that deliver a well-organised but flexible installation.
- By reliable we mean that it copes with a wide variety of distributions without intervention
- By easy-to-use we mean that it uses well-established packaging mechanisms on our target platforms
- By simple we mean that users can immediately use it after installation without changing login scripts
- By well-organised we mean that its installed commands and environment-variables are few and well-grouped together
- By flexible we mean that advanced users can easily configure the full array of Poplog commands and linkage by environment variables.

This work is only possible thanks to Aaron Sloman's dedication in maintaining
the FreePoplog archive over the years.
