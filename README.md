#### Using Git and the bootstrap script

##### Installing

You can clone the repository wherever you want. The bootstrapper script will
pull in the latest version and copy the files to your home folder. Please note
that all existing files will be overwritten by `bootstrap` script.

```bash
git clone https://github.com/nvartolomei/dotfiles.git --recursive && cd dotfiles && source script/bootstrap
```

##### Updating

To update, `cd` into your local `dotfiles` repository and then:

```bash
git pull origin master && git submodule update --init
source script/bootstrap
```

Use *force* `-f` flag for `script/bootstrap` to disable prompt.

#### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing takes place.

Here’s an example `~/.path` I use:

```bash
# PATH additions
path_additions=(
    "/usr/local/cuda/bin"
    "$(brew --prefix coreutils)/libexec/gnubin"
    "$(brew --prefix ruby)/bin"

    "$PATH"
)

printf -v PATH '%s:' "${path_additions[@]}"
export PATH

unset path_additions
```

#### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files.
You can use this to add a few custom commands without the need to fork this
entire repository, or to add commands you don’t want to commit to a public
repository.

#### Sensible OS X defaults

When setting up a new Mac, you may want to set some sensible OS X defaults,
but don't forget to take a look at `script/osx` file before applying them and bang:

```bash
script/osx
```

#### Homebrew common packages for developers

```bash
script/brew
```

#### ♥ Colophon

Thanks to…

* [Mathias Bynens](http://mathiasbynens.be/) for [upstream](https://github.com/mathiasbynens/dotfiles)

and follow on tail recursively
