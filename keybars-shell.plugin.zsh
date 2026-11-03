# keybars-shell for zsh: a command that ran for a while sends
# command.passed or command.failed to keybars Pro when it finishes.

zmodload zsh/datetime

typeset -g _keybars_cmd=
typeset -g _keybars_start=

_keybars_preexec() {
  _keybars_cmd=$1
  _keybars_start=$EPOCHREALTIME
}

_keybars_precmd() {
  local code=$?
  [[ -n $_keybars_start ]] || return 0
  local took=$(( EPOCHREALTIME - _keybars_start ))
  _keybars_start=
  (( took >= ${KEYBARS_SHELL_AFTER:-30} )) || return 0
  local -a words=(${(z)_keybars_cmd})
  local first=${words[1]}
  [[ $first == sudo ]] && first=${words[2]}
  local ignore=${KEYBARS_SHELL_IGNORE-vi vim nvim nano emacs less more man ssh mosh top htop btop tmux screen claude}
  (( ${${(z)ignore}[(Ie)${first:t}]} )) && return 0
  local event=command.passed
  (( code == 0 )) || event=command.failed
  local -a about=()
  local top branch
  if top=$(command git rev-parse --show-toplevel 2>/dev/null); then
    about+=(-repo ${top:t})
    branch=$(command git branch --show-current 2>/dev/null)
    [[ -n $branch ]] && about+=(-branch $branch)
  fi
  command ${KEYBARS_PRO:-keybars-pro} alert -q $about $event >/dev/null 2>&1 &!
  return 0
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _keybars_preexec
# first, so it reads the command's status before other hooks change it
precmd_functions=(_keybars_precmd ${precmd_functions:#_keybars_precmd})
