### nvartolomei ♥ ~/

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. The bootstrapper script will 
pull in the latest version and copy the files to your home folder. Please note
that all existing files will be overwritten by `bootstrap.sh` script.

```bash
git clone https://github.com/nvartolomei/dotfiles.git && cd dotfiles && ./bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
./bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
./bootstrap.sh -f
```

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/nvartolomei/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh}
```

To update later on, just run that command again.

Also I'm writting the script to synchronize *dotfiles* across servers.

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. 
You can use this to add a few custom commands without the need to fork this
entire repository, or to add commands you don’t want to commit to a public
repository.

### Sensible OS X defaults

When setting up a new Mac, you may want to set some sensible OS X defaults,
but don't forget to take a look at `.osx` file before applying them and bang:

```bash
./.osx
```

## Colophon

Thanks to…

* [Mathias Bynens](http://mathiasbynens.be/) for [upstream](https://github.com/mathiasbynens/dotfiles)
* [Gianni Chiappetta](http://gf3.ca/) for sharing his [amazing collection of dotfiles](https://github.com/gf3/dotfiles)
* [Matijs Brinkhuis](http://hotfusion.nl/) and his [homedir repository](https://github.com/matijs/homedir)
* [Jan Moesen](http://jan.moesen.nu/) and his [ancient `.bash_profile`](https://gist.github.com/1156154) + [shiny tilde repository](https://github.com/janmoesen/tilde)
* [Ben Alman](http://benalman.com/) and his [dotfiles repository](https://github.com/cowboy/dotfiles)
* [Nicolas Gallagher](http://nicolasgallagher.com/) and his [dotfiles repository](https://github.com/necolas/dotfiles)
* [Tom Ryder](http://blog.sanctum.geek.nz/) and his [dotfiles repository](https://github.com/tejr/dotfiles)
* [Chris Gerke](http://www.randomsquared.com/) and his [tutorial on creating an OS X SOE master image](http://chris-gerke.blogspot.com/2012/04/mac-osx-soe-master-image-day-7.html) + [_Insta_ repository](https://github.com/cgerke/Insta)
* @ptb and [his _OS X Lion Setup_ repository](https://github.com/ptb/Mac-OS-X-Lion-Setup)
* [Lauri ‘Lri’ Ranta](http://lri.me/) for sharing [loads of hidden preferences](http://lri.me/hiddenpreferences.txt)
* [Tim Esselens](http://devel.datif.be/)
* anyone who [contributed a patch](https://github.com/nvartolomei/dotfiles/graphs/contributors) or [made a helpful suggestion](https://github.com/mathiasbynens/dotfiles/issues)

and so on recursively ^_^
