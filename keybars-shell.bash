# keybars-shell for bash: a command that ran for a while sends
# command.passed or command.failed to keybars Pro when it finishes.
# Runs on bash 3.2 (macOS) and later. With bash-preexec loaded, it uses its
# hooks; otherwise a DEBUG trap and PROMPT_COMMAND.

_keybars_cmd=
_keybars_start=
_keybars_status=0
_keybars_ready=

_keybars_ignored() {
  local name=${1##*/} w
  for w in ${KEYBARS_SHELL_IGNORE-vi vim nvim nano emacs less more man ssh mosh top htop btop tmux screen claude}; do
    [[ $name == "$w" ]] && return 0
  done
  return 1
}

_keybars_begin() {
  _keybars_cmd=$1
  _keybars_start=$SECONDS
}

_keybars_end() {
  local code=$1
  [[ -n $_keybars_start ]] || return 0
  local took=$((SECONDS - _keybars_start))
  _keybars_start=
  ((took >= ${KEYBARS_SHELL_AFTER:-30})) || return 0
  local -a words
  read -r -a words <<<"$_keybars_cmd"
  local first=${words[0]}
  [[ $first == sudo ]] && first=${words[1]}
  _keybars_ignored "$first" && return 0
  local event=command.passed
  ((code == 0)) || event=command.failed
  local -a about=()
  local top branch
  if top=$(command git rev-parse --show-toplevel 2>/dev/null); then
    about+=(-repo "${top##*/}")
    branch=$(command git branch --show-current 2>/dev/null)
    [[ -n $branch ]] && about+=(-branch "$branch")
  fi
  (command "${KEYBARS_PRO:-keybars-pro}" alert -q ${about[@]+"${about[@]}"} "$event" >/dev/null 2>&1 &)
  return 0
}

if [[ -n ${bash_preexec_imported:-${__bp_imported:-}} ]]; then
  _keybars_bp_preexec() { _keybars_begin "$1"; }
  _keybars_bp_precmd() { _keybars_end "$?"; }
  preexec_functions+=(_keybars_bp_preexec)
  precmd_functions=(_keybars_bp_precmd "${precmd_functions[@]}")
else
  # PROMPT_COMMAND runs _keybars_save first, for the command's status, and
  # _keybars_prompt last, so the DEBUG trap only takes what you typed
  _keybars_save() {
    _keybars_status=$?
    _keybars_ready=
  }
  _keybars_prompt() {
    _keybars_end "$_keybars_status"
    _keybars_ready=1
  }
  _keybars_debug() {
    [[ -n $_keybars_ready ]] || return 0
    _keybars_ready=
    _keybars_begin "$BASH_COMMAND"
  }
  trap '_keybars_debug' DEBUG
  # bash runs every element of an array only from 5.1
  if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == "declare -a"* ]] &&
    ((BASH_VERSINFO[0] > 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 1))); then
    PROMPT_COMMAND=(_keybars_save "${PROMPT_COMMAND[@]}" _keybars_prompt)
  else
    # shellcheck disable=SC2178,SC2128 # a string here, the array case above
    PROMPT_COMMAND="_keybars_save${PROMPT_COMMAND:+; $PROMPT_COMMAND}; _keybars_prompt"
  fi
fi
