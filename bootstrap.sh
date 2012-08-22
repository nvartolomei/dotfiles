#!/usr/bin/env bash
cd "$(dirname "$0")"
#git pull

function do_backup() {
    shopt -s dotglob

    ! [ -d "$HOME/.backup" ] && mkdir $HOME/.backup

    for file in *; do
        [ -f "$HOME/$file" ] && cp -r "$HOME/$file" "$HOME/.backup/$file"
    done

    echo "Your original dotfiles has backed up to ~/.backup/"
}

function do_sync() {
    rsync --exclude ".git/" --exclude ".DS_Store" \
          --exclude "bootstrap.sh" --exclude "README.md" -av . ~
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    do_sync
    do_backup
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        do_sync
        do_backup
    fi
fi
unset do_sync
unset do_backup

# Check what homebrew is saying
# source ~/.brew

# Reaload bash_profile
source ~/.bash_profile