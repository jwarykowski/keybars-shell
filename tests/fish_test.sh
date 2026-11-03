#!/bin/sh
# fish: fires fish_postexec as an interactive fish would after a command.
set -eu
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

command -v fish >/dev/null || {
  echo "skip: no fish"
  exit 0
}

# after <seconds> <dir> <command line> <fish that sets $status>
after() {
  fish --no-config -c "
    source '$root/conf.d/keybars.fish'
    cd '$2'
    set CMD_DURATION $(($1 * 1000))
    $4
    emit fish_postexec '$3'
    wait" || true
}

KEYBARS_SHELL_AFTER=30
export KEYBARS_SHELL_AFTER
after 31 / "make test" true
check "a command that passes" "alert -q command.passed"
after 31 / "make test" false
check "a command that fails" "alert -q command.failed"
after 31 "$repo" "make test" true
check "in a repository" "alert -q -repo shop -branch feat/cart command.passed"
after 31 / "vim notes.txt" true
after 31 / "sudo vim /etc/hosts" true
after 31 / "/usr/bin/vim x" true
quiet "an editor"
after 5 / "make test" true
quiet "a quick command"
finish
