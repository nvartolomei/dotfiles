#!/usr/bin/env bash
cd "$(dirname "$0")"
#git pull
function do_sync() {
    rsync --exclude ".git/" --exclude ".DS_Store" \
          --exclude "bootstrap.sh" --exclude "README.md" -av . ~
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
    do_sync
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        do_sync
    fi
fi
unset do_sync

# Check what homebrew is saying
# source ~/.brew

# Reaload bash_profile
source ~/.bash_profile