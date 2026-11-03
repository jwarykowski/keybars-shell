#!/bin/sh
# bash: an interactive bash reads commands from stdin, so PROMPT_COMMAND and
# the DEBUG trap run.
set -eu
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

run() {
  printf '%s\n' "$@" | HOME="$tmp" bash --norc --noprofile -i >/dev/null 2>&1 || true
}
plugin=". '$root/keybars-shell.bash'"

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
run "KEYBARS_SHELL_AFTER=0" "PROMPT_COMMAND='(exit 3)'" "$plugin" "cd /" "true"
check "another PROMPT_COMMAND" "alert -q command.passed"
run "KEYBARS_SHELL_AFTER=0" "PROMPT_COMMAND=('(exit 3)')" "$plugin" "cd /" "false"
check "PROMPT_COMMAND as an array" "alert -q command.failed"

# with bash-preexec, its hooks call ours
cd /
KEYBARS_SHELL_AFTER=0 bash --norc --noprofile -c "
  __bp_imported=1; preexec_functions=(); precmd_functions=()
  . '$root/keybars-shell.bash'
  for f in \"\${preexec_functions[@]}\"; do \$f 'make test'; done
  false
  for f in \"\${precmd_functions[@]}\"; do \$f; done
  wait"
check "bash-preexec" "alert -q command.failed"
finish
