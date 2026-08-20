#!/usr/bin/env bash
#
# Tests for bin/git-swr.
#
# The clone is made with --single-branch plus a v2* glob refspec, mimicking
# a repo whose fetch refspec is filtered to a few branches.

set -u

here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$tmp"' EXIT

export PATH="$here/bin:$PATH"
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=$tmp/gitconfig
git config --file "$tmp/gitconfig" user.name test
git config --file "$tmp/gitconfig" user.email test@example.com
git config --file "$tmp/gitconfig" init.defaultBranch main

pass=0 fail=0
assert_eq() {
	if [ "$2" = "$3" ]; then
		pass=$((pass + 1)) && echo "ok - $1"
	else
		fail=$((fail + 1)) && echo "not ok - $1: want '$2', got '$3'"
	fi
}

work=$tmp/work
git init -q "$work"
git -C "$work" commit -q --allow-empty -m root
git -C "$work" branch topic/x
git -C "$work" branch topic/y
git -C "$work" branch v2.1
git init -q --bare "$tmp/origin.git"
git -C "$work" remote add origin "$tmp/origin.git"
git -C "$work" push -q origin main topic/x topic/y v2.1

clone=$tmp/clone
git clone -q --single-branch "$tmp/origin.git" "$clone"
git -C "$clone" config --add remote.origin.fetch '+refs/heads/v2*:refs/remotes/origin/v2*'

refspec_count() {
	git -C "$clone" config --get-all remote.origin.fetch |
		grep -cxF "+refs/heads/$1:refs/remotes/origin/$1"
}

# a branch outside the filter gets a refspec line, a fetch, and a
# tracking local branch
(cd "$clone" && git-swr topic/x >/dev/null 2>&1)
assert_eq "switches to the branch" \
	topic/x "$(git -C "$clone" branch --show-current)"
assert_eq "sets up tracking" \
	origin/topic/x "$(git -C "$clone" rev-parse --abbrev-ref 'topic/x@{u}')"
assert_eq "adds the refspec line" 1 "$(refspec_count topic/x)"

# once tracked, plain `git fetch` keeps the branch updated
git -C "$work" switch -q topic/x
git -C "$work" commit -q --allow-empty -m more
git -C "$work" push -q origin topic/x
git -C "$clone" fetch -q origin
assert_eq "plain fetch updates the tracked branch" \
	"$(git -C "$work" rev-parse topic/x)" \
	"$(git -C "$clone" rev-parse origin/topic/x)"

# re-running neither duplicates the refspec line nor fails
(cd "$clone" && git-swr topic/x >/dev/null 2>&1)
rc=$?
assert_eq "re-run succeeds" 0 "$rc"
assert_eq "re-run adds no duplicate refspec" 1 "$(refspec_count topic/x)"

# a branch covered by the v2* glob is fetched and switched to without
# touching the config
(cd "$clone" && git-swr v2.1 >/dev/null 2>&1)
assert_eq "glob-covered branch switches" \
	v2.1 "$(git -C "$clone" branch --show-current)"
assert_eq "glob-covered branch adds no refspec" 0 "$(refspec_count v2.1)"

# explicit remote argument
(cd "$clone" && git-swr origin topic/y >/dev/null 2>&1)
assert_eq "explicit remote switches" \
	topic/y "$(git -C "$clone" branch --show-current)"

# wrong number of arguments prints usage and fails
out=$(cd "$clone" && git-swr a b c 2>&1)
rc=$?
assert_eq "usage error exits non-zero" 1 "$rc"
assert_eq "usage error prints usage" \
	"usage: git swr [<remote>] <branch>" "$out"

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
