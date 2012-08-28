#!/usr/bin/env bash
cd "$(dirname "$0")"

set -e

now=$(date +%s)

function do_backup() {
    shopt -s dotglob

    mkdir -p "$HOME/.backups/$now"

    for file in *; do
        [ -f "$HOME/$file" ] && cp -r "$HOME/$file" "$HOME/.backups/$now/$file"
    done
}

function do_sync() {
    rsync --exclude ".git/" --exclude ".DS_Store" \
          --exclude "bootstrap.sh" --exclude "README.md" -av . ~
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    do_sync
    do_backup
else
    echo "This may overwrite existing files in your home directory,"
    echo "a backup will be saved in \`~/.backups/$now\`."

    read -p "Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        do_sync
        do_backup
    fi
fi

unset do_sync
unset do_backup
unset now

# Check what homebrew is saying
# source ~/.brew

# Reaload bash_profile
source ~/.bash_profile