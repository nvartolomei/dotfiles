#!/usr/bin/env bash
#
# Tests for bin/git-sw and the g() shell function.
#
# fzf is replaced with a shim that pretends the user picked the branch named
# in $FAKE_PICK and pressed $FAKE_KEY (empty = enter). Interactive paths that
# read from /dev/tty run under a pty via `script`; they are skipped when the
# command is unavailable.

set -u

here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# resolved (pwd -P) because git and tmux report physical paths, while
# macOS mktemp hands out a path through the /var -> /private/var symlink
tmp=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$tmp"' EXIT

export PATH="$tmp/fakebin:$here/bin:$PATH"
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=$tmp/gitconfig
git config --file "$tmp/gitconfig" user.name test
git config --file "$tmp/gitconfig" user.email test@example.com
git config --file "$tmp/gitconfig" init.defaultBranch main

mkdir -p "$tmp/fakebin"
cat >"$tmp/fakebin/fzf" <<'EOF'
#!/usr/bin/env bash
line=$(awk -F'\t' -v pick="$FAKE_PICK" '$1 == pick {print; exit}')
[ -n "$line" ] || exit 130
printf '%s\n%s\n' "${FAKE_KEY-}" "$line"
EOF
chmod +x "$tmp/fakebin/fzf"

# stdin is delayed because script forwards it into the pty immediately,
# racing ahead of the command's read from /dev/tty
have_pty=1
if script -qec true /dev/null >/dev/null 2>&1; then
	run_pty() { { sleep 0.5; cat; } | script -qec "$1" /dev/null | tr -d '\r'; }
elif command -v script >/dev/null 2>&1; then
	run_pty() { { sleep 0.5; cat; } | script -q /dev/null bash -c "$1" | tr -d '\r'; }
else
	have_pty=0
fi

pass=0 fail=0 skip=0
assert_eq() {
	if [ "$2" = "$3" ]; then
		pass=$((pass + 1)) && echo "ok - $1"
	else
		fail=$((fail + 1)) && echo "not ok - $1: want '$2', got '$3'"
	fi
}
assert_contains() {
	if grep -qF "$2" <<<"$3"; then
		pass=$((pass + 1)) && echo "ok - $1"
	else
		fail=$((fail + 1)) && echo "not ok - $1: '$2' not found in output:" && sed 's/^/    /' <<<"$3"
	fi
}

repo=$tmp/demo
git init -q "$repo"
git -C "$repo" commit -q --allow-empty -m root
git -C "$repo" branch free1
git -C "$repo" branch wt-free
git -C "$repo" branch busy
git -C "$repo" worktree add "$tmp/demo-busy" busy >/dev/null 2>&1
git -C "$repo" branch gone
git -C "$repo" worktree add "$tmp/demo-gone" gone >/dev/null 2>&1
rm -rf "$tmp/demo-gone"
git init -q --bare "$tmp/origin.git"
git -C "$repo" remote add origin "$tmp/origin.git"
git -C "$repo" branch tracked
git -C "$repo" push -q -u origin tracked 2>/dev/null

# enter on a free branch checks it out in place
(cd "$repo" && FAKE_PICK=free1 FAKE_KEY= git-sw >/dev/null 2>&1)
assert_eq "enter checks out a free branch" \
	free1 "$(git -C "$repo" branch --show-current)"

# enter on a branch living in another worktree prints that path on stdout
dest=$(cd "$repo" && FAKE_PICK=busy FAKE_KEY= git-sw 2>/dev/null)
assert_eq "enter on a worktree branch prints its path" "$tmp/demo-busy" "$dest"
assert_eq "jump does not switch the current branch" \
	free1 "$(git -C "$repo" branch --show-current)"

# checkout messages ("Your branch is up to date...") must not leak into the
# path channel, or g() would try to cd into them
dest=$(cd "$repo" && FAKE_PICK=tracked FAKE_KEY= git-sw 2>/dev/null)
assert_eq "tracked checkout keeps stdout empty" "" "$dest"
assert_eq "tracked checkout switches the branch" \
	tracked "$(git -C "$repo" branch --show-current)"

# enter on the current branch is a no-op
out=$(cd "$repo" && FAKE_PICK=tracked FAKE_KEY= git-sw 2>&1)
assert_contains "enter on the current branch says already on" "already on" "$out"

# cancelling the picker propagates fzf's exit code and prints nothing
dest=$(cd "$repo" && FAKE_PICK=no-such-branch FAKE_KEY= git-sw 2>/dev/null)
rc=$?
assert_eq "cancel exits 130" 130 "$rc"
assert_eq "cancel prints nothing" "" "$dest"

# with arguments it is plain checkout, dispatched by git itself as `git sw`
# under the real .gitconfig (catches an alias shadowing the script again)
(cd "$repo" && GIT_CONFIG_GLOBAL=$here/.gitconfig git sw main >/dev/null 2>&1)
assert_eq "git sw <branch> passes through to checkout" \
	main "$(git -C "$repo" branch --show-current)"

# g() captures the printed path and cds into the worktree
out=$(cd "$repo" && source "$here/.functions" &&
	FAKE_PICK=busy FAKE_KEY= g sw 2>/dev/null && pwd)
assert_eq "g sw cds into the worktree" "$tmp/demo-busy" "$out"

out=$(cd "$repo" && source "$here/.functions" && g rev-parse --show-toplevel)
assert_eq "g passes other subcommands through to git" "$repo" "$out"

if [ "$have_pty" -eq 0 ]; then
	skip=1
	echo "skip - pty tests: no usable 'script' command"
else
	# standalone on a terminal it cannot cd, so it prints the commands
	out=$(cd "$repo" && printf '' | run_pty 'FAKE_PICK=busy FAKE_KEY= git-sw')
	assert_contains "standalone jump prints the cd command" "cd $tmp/demo-busy" "$out"
	assert_contains "standalone jump offers checkout -b" \
		"git checkout -b <new-name> busy" "$out"

	# ctrl-b asks for a name and starts a branch off the selection
	(cd "$repo" &&
		printf 'newbie\n' | run_pty 'FAKE_PICK=busy FAKE_KEY=ctrl-b git-sw' >/dev/null)
	assert_eq "ctrl-b starts a new branch off the selection" \
		newbie "$(git -C "$repo" branch --show-current)"

	# ctrl-t on a free branch asks only for a path (empty accepts suggestion)
	(cd "$repo" &&
		printf '\n' | run_pty 'FAKE_PICK=wt-free FAKE_KEY=ctrl-t git-sw' >/dev/null)
	assert_eq "ctrl-t checks a free branch out in a new worktree" \
		wt-free "$(git -C "$tmp/demo-wt-free" branch --show-current 2>/dev/null)"

	# ctrl-t on a busy branch asks for a new branch name first
	(cd "$repo" &&
		printf 'offbusy\n\n' | run_pty 'FAKE_PICK=busy FAKE_KEY=ctrl-t git-sw' >/dev/null)
	assert_eq "ctrl-t on a busy branch starts a new branch in the worktree" \
		offbusy "$(git -C "$tmp/demo-offbusy" branch --show-current 2>/dev/null)"

	# a worktree deleted on disk but still registered offers to recreate;
	# declining leaves it alone and prints the remedies
	out=$(cd "$repo" && printf 'n\n' | run_pty 'FAKE_PICK=gone FAKE_KEY= git-sw')
	assert_contains "declined recreate suggests worktree prune" \
		"git worktree prune" "$out"
	assert_eq "declined recreate does not create the directory" \
		"missing" "$([ -d "$tmp/demo-gone" ] && echo present || echo missing)"

	out=$(cd "$repo" && printf 'y\n' | run_pty 'FAKE_PICK=gone FAKE_KEY= git-sw')
	assert_contains "accepted recreate prints the cd command" \
		"cd $tmp/demo-gone" "$out"
	assert_eq "accepted recreate restores the worktree" \
		gone "$(git -C "$tmp/demo-gone" branch --show-current 2>/dev/null)"
fi

echo "$pass passed, $fail failed, $skip skipped"
[ "$fail" -eq 0 ]
