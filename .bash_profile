# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Homebrew related
if command -v brew >/dev/null 2>&1; then
    [ -f "$(brew --prefix)/etc/bash_completion" ] && source "$(brew --prefix)/etc/bash_completion"

    # Load rupa's z if installed
    [ -f "$(brew --prefix)/etc/profile.d/z.sh" ] && source "$(brew --prefix)/etc/profile.d/z.sh"
fi

# Fuckof for XOFF message for CTRL-S (use this for vim write istead)
bind -r '\C-s'
stty -ixon
