#!/bin/sh
# keybars-shell-setup adds the two rules once.
set -eu
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

# rules list prints the rules added so far
cat >"$KEYBARS_PRO" <<FAKE
#!/bin/sh
echo "\$*" >>"$log"
if [ "\$1 \$2" = "rules list" ]; then cat "$tmp/rules" 2>/dev/null || true; fi
if [ "\$1 \$2" = "rules add" ]; then echo "\$3" >>"$tmp/rules"; fi
FAKE

"$root/bin/keybars-shell-setup" >/dev/null
check "adds the passed rule" "rules add Long command passed command.passed -keys esc -colour green -effect fade -for 10s"
"$root/bin/keybars-shell-setup" >/dev/null
if grep -q "rules add" "$log"; then
  echo "FAIL: added the rules again" >&2
  fails=$((fails + 1))
else
  echo "ok: adds them once"
fi
if [ "$(grep -c . "$tmp/rules")" -eq 2 ]; then
  echo "ok: two rules"
else
  echo "FAIL: rules: $(cat "$tmp/rules")" >&2
  fails=$((fails + 1))
fi

KEYBARS_PRO="$tmp/missing" "$root/bin/keybars-shell-setup" 2>"$tmp/err" && fails=$((fails + 1))
if grep -q "Install the command-line tool" "$tmp/err"; then
  echo "ok: says how to install the command"
else
  echo "FAIL: no install hint" >&2
  fails=$((fails + 1))
fi
finish
