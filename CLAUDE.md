# keybars-shell

zsh, bash and fish plugins that send `command.passed` or `command.failed`
to keybars Pro when a long command finishes. README.md has the detail; this
file is what to keep in mind while working here.

## Commands

- `make check`: shellcheck, `zsh -n`, `fish --no-execute`, then the tests.
- The tests drive real interactive shells (zsh, bash) or fire
  `fish_postexec` (fish) against a fake `keybars-pro` that logs its
  arguments. Without fish installed, its tests skip.

## Keep in mind

- Each shell's file stands alone: fisher only installs `conf.d/`, so fish
  can't share code with the others. A change to what's sent (events, repo,
  branch, the ignore list) goes in all three.
- bash runs on 3.2 (macOS): no `declare -A`, no `${var,,}`, no `mapfile`.
  PROMPT_COMMAND arrays only run every element from 5.1.
- Sending happens in the background with `alert -q`, so a prompt never waits
  on keybars Pro and never fails when it isn't running.
- Scripts in `bin/` and `tests/` are POSIX sh and run on Linux and macOS.

## Related repos (in ~/development)

- `keybars-pro`: the app and the `keybars-pro` command. A change to its CLI
  (`alert`, `rules add`) can break this.
