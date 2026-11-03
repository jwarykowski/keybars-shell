# keybars-shell for fish: a command that ran for a while sends
# command.passed or command.failed to keybars Pro when it finishes.

function _keybars_postexec --on-event fish_postexec
    set -l code $status
    set -q KEYBARS_SHELL_AFTER; or set -l KEYBARS_SHELL_AFTER 30
    test "$CMD_DURATION" -ge (math "$KEYBARS_SHELL_AFTER * 1000"); or return 0
    set -l words (string split -n ' ' -- $argv[1])
    set -l first $words[1]
    test "$first" = sudo; and set first $words[2]
    set -q KEYBARS_SHELL_IGNORE; or set -l KEYBARS_SHELL_IGNORE vi vim nvim nano emacs less more man ssh mosh top htop btop tmux screen claude
    contains -- (path basename -- "$first") (string split ' ' -- $KEYBARS_SHELL_IGNORE); and return 0
    set -l event command.passed
    test $code -eq 0; or set event command.failed
    set -l about
    if set -l top (command git rev-parse --show-toplevel 2>/dev/null)
        set about -repo (path basename -- $top)
        set -l branch (command git branch --show-current 2>/dev/null)
        test -n "$branch"; and set -a about -branch $branch
    end
    set -q KEYBARS_PRO; or set -l KEYBARS_PRO keybars-pro
    command $KEYBARS_PRO alert -q $about $event >/dev/null 2>&1 &
    disown 2>/dev/null
    return 0
end
