# Seed

This is a repository of scripts for installing Poplog onto your local machine. 
When it is run it will download the other files it needs from several other 
repositories in this organisation plus contributory packages from the [FreePoplog](https://www.cs.bham.ac.uk/research/projects/poplog/freepoplog.html) 
site.

At the moment we only support installing Poplog onto Linux x86_64 systems i.e.
64-bit Linux on Intel. We expect to extend this to include 32-bit and other Unix
systems that Poplog has run on. Because dependencies are installed using `apt` 
at the moment, we are currently limited to Debian-derived distros such as 
Ubuntu, Mint and Debian itself.

## How to Install Poplog using this resource

If you have a desktop system with `sudo`, `make` and `git` installed then the 
simplest approach is to clone this repo to a new local folder as follows:
```
git clone https://github.com/GetPoplog/Seed.git
cd Seed
make jumpstart     # fetch all dependencies
make build         # this takes a while
sudo make install  # installs into /usr/local/poplog
```

After this has been done, you will find a new Poplog system has been
installed into `/usr/local/poplog`.

## How to Set-up your Login Account to use Poplog

Once Poplog is installed, you will need to set up your login account to use
it. Poplog requires your $PATH to be extended so that the commands are available
and also available to each other. It also requires many environment variables
to be added. 

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
. ~/.config/poplog/setup.sh
```

It is a good idea to separate the setup-file from your `~/.bash_profile`. Poplog
is a rich and complex environment and putting the set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file. (And it also 
makes it easy to include into `.bashrc` files for environments where the 
`.bash_profile` is not included.)

Now create `~/.config/poplog/setup.sh` and insert these lines:
```sh
usepop=/usr/local/poplog/current_usepop
export usepop
. $usepop/pop/com/popenv.sh
PATH=$popsys\:$PATH\:$popcom
export PATH
```

Try this out with the command `. ~/.config/poplog/setup.sh` and then 
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

```csh
source ~/.config/poplog/setup.csh
```

It is a good idea to separate the setup-file from your `~/.login`. Poplog
is a rich and complex environment and putting the set-up in a separate file gives
it plenty of room to grow without clogging up your start-up file.

Now create `~/.config/poplog/setup.csh` and insert these lines:
```csh
setenv usepop=/usr/local/poplog/current_usepop
. $usepop/pop/com/popenv.csh
setenv PATH=$popsys\:$PATH\:$popcom
```

Try this out with the command `source ~/.config/poplog/setup.sh` and then 
`pop11`. The latter will drop you into the Pop-11 REPL. Which will look
something like this:
```
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


## Our Aims

We aim to automate of the production and test of reliable, easy-to-use, simple installation methods for Poplog that deliver a well-organised but flexible installation.
- By reliable we mean that it copes with a wide variety of distributions without intervention
- By easy-to-use we mean that it uses well-established packaging mechanisms on our target platforms
- By simple we mean that users can immediately use it after installation without changing login scripts
- By well-organised we mean that its installed commands and environment-variables are few and well-grouped together
- By flexible we mean that advanced users can easily configure the full array of Poplog commands and linkage by environment variables.

This work is only possible thanks to Aaron Sloman's dedication in maintaining
the FreePoplog archive over the years.
