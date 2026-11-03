#!/bin/sh
# zsh: an interactive zsh reads commands from stdin, so its hooks run.
set -eu
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

run() {
  printf '%s\n' "$@" | HOME="$tmp" zsh -f -i >/dev/null 2>&1 || true
}
plugin="source '$root/keybars-shell.plugin.zsh'"

run "KEYBARS_SHELL_AFTER=0" "$plugin" "cd /" "true"
check "a command that passes" "alert -q command.passed"
run "KEYBARS_SHELL_AFTER=0" "$plugin" "cd /" "false"
check "a command that fails" "alert -q command.failed"
run "KEYBARS_SHELL_AFTER=0" "$plugin" "cd '$repo'" "true"
check "in a repository" "alert -q -repo shop -branch feat/cart command.passed"
run "KEYBARS_SHELL_AFTER=0" "$plugin" "vim notes.txt" "sudo vim /etc/hosts"
quiet "an editor"
run "KEYBARS_SHELL_AFTER=5" "$plugin" "true"
quiet "a quick command"
run "KEYBARS_SHELL_AFTER=1" "$plugin" "cd /" "sleep 1.2"
check "a slow command" "alert -q command.passed"
run "KEYBARS_SHELL_AFTER=0" "precmd() { return 3; }" "$plugin" "cd /" "false"
check "another precmd hook" "alert -q command.failed"
finish
