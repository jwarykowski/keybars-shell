# keybars-shell

zsh, bash and fish plugins for [keybars Pro](https://keybars.app/pro/): a
command that ran for 30 seconds or more lights a key when it finishes, green
if it passed, red if it failed. Start a build, look away, and the keyboard
tells you when it's done. No need to wrap commands in `keybars-pro run`.

When a long command finishes, the plugin sends `command.passed` or
`command.failed` to keybars Pro's alert rules, with the repository and branch
you're in, so a rule can light something different for one project.
Editors, pagers, `ssh`, `tmux` and other programs you sit in are left out.

## requirements

- keybars Pro running, with its command installed: App settings, Command
  line, **Install the command-line tool**
- zsh, bash 3.2 or later, or fish 3.5 or later; Linux or macOS

## install

zsh, with [oh-my-zsh](https://ohmyz.sh):

```sh
git clone https://github.com/jwarykowski/keybars-shell "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/keybars-shell"
# then add keybars-shell to plugins=(...) in ~/.zshrc
```

zsh, with antidote, zinit or another plugin manager: add
`jwarykowski/keybars-shell`. Without one, clone it and add to `~/.zshrc`:

```sh
source ~/keybars-shell/keybars-shell.plugin.zsh
```

bash: clone it and add to `~/.bashrc`. It uses
[bash-preexec](https://github.com/rcaloras/bash-preexec) when that's loaded
first, else its own hooks.

```sh
source ~/keybars-shell/keybars-shell.bash
```

fish, with [fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install jwarykowski/keybars-shell
```

## rules

The plugin only sends events; rules decide what lights. To add two that use
Esc, run `bin/keybars-shell-setup` from the clone, or:

```sh
keybars-pro rules add "Long command passed" command.passed -keys esc -colour green -effect fade -for 10s
keybars-pro rules add "Long command failed" command.failed -keys esc -colour red -effect hold -clear-on command.passed
```

The red stays until a long command passes. Change them in keybars Pro's
Alerts page like any other rule, or add a `-repo` to one for a single
project.

## configuration

Environment variables, set before the plugin loads (fish: `set -U`):

| variable | default | |
|---|---|---|
| `KEYBARS_SHELL_AFTER` | `30` | seconds a command must run before it counts |
| `KEYBARS_SHELL_IGNORE` | `vi vim nvim nano emacs less more man ssh mosh top htop btop tmux screen claude` | programs never reported, by name |
| `KEYBARS_PRO` | `keybars-pro` | the command, if it isn't on `$PATH` |

## development

`make check` runs shellcheck and the tests. The fish tests skip without
fish installed; CI runs them.

## licence

MIT
