# Make sure we’re using the latest Homebrew
update

# Upgrade any already-installed formulae
upgrade

# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add $(brew --prefix coreutils)/libexec/gnubin to \$PATH.
install coreutils

# Install wget with IRI support
install wget --enable-iri

# Install more recent versions of some OS X tools
install homebrew/dupes/grep
install homebrew/dupes/less

# Install completion (dotfiles completions need this)
install bash-completion

# Install latest version of bash shell
# Don't forget to change shell to $(brew --prefix bash)/bin/bash.
install bash

# Install everything else
install git
install htop
install node
install ssh-copy-id
install nmap
install resty
install tree
install mtr
install z
install vim
install tmux
install the_silver_searcher
install ack
install grep
install less
install pv

# Remove outdated versions from the cellar
cleanup
