# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit;
#   it is sourced at the very end, see below.
for file in ~/.{path,bash_prompt,exports,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

for file in /opt/homebrew/share/bash-completion/bash_completion \
            /usr/local/share/bash-completion/bash_completion \
            /etc/bash_completion; do
    if [ -f "$file" ]; then
        source "$file"
        break
    fi
done
unset file

for file in /opt/homebrew/etc/profile.d/autojump.sh /usr/local/etc/profile.d/autojump.sh; do
    if [ -s "$file" ]; then
        source "$file"
        break
    fi
done
unset file

# Ctrl-S otherwise sends XOFF and freezes terminal output until Ctrl-Q.
stty -ixon

# Sourced last so it can override anything above: completion files register
# their own `complete` bindings as they load, and a binding ~/.extra installs
# beforehand is silently overwritten.
for file in ~/.extra; do
    [ -r "$file" ] && source "$file"
done
unset file
