# Seed

This is a repository of scripts for installing Poplog onto your local machine. 
When it is run it will download the other files it needs from several other 
repositories in this organisation plus contributory packages from the 
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
POPLOG_HOME variable during the install phase like this:

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
