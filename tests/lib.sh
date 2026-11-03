# shellcheck shell=sh
# Shared by the tests: a fake keybars-pro that logs its arguments, and checks.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# shellcheck disable=SC2034 # the tests that source this use it
root=$(cd "$(dirname "$0")/.." && pwd)
log="$tmp/keybars.log"
export KEYBARS_PRO="$tmp/keybars-pro"
cat >"$KEYBARS_PRO" <<EOF
#!/bin/sh
echo "\$*" >>"$log"
EOF
chmod +x "$KEYBARS_PRO"

# a git repository on a branch, for -repo and -branch
repo="$tmp/shop"
git init -q -b feat/cart "$repo"

fails=0
check() {
  name=$1
  want=$2
  # the plugins send in the background
  i=0
  while [ "$i" -lt 50 ] && ! grep -qxF -- "$want" "$log" 2>/dev/null; do
    sleep 0.1
    i=$((i + 1))
  done
  if grep -qxF -- "$want" "$log" 2>/dev/null; then
    echo "ok: $name"
  else
    echo "FAIL: $name: want \"$want\", got:" >&2
    cat "$log" >&2 2>/dev/null || true
    fails=$((fails + 1))
  fi
  : >"$log"
}

quiet() {
  name=$1
  sleep 0.5
  if [ -s "$log" ]; then
    echo "FAIL: $name: want nothing, got:" >&2
    cat "$log" >&2
    fails=$((fails + 1))
  else
    echo "ok: $name"
  fi
  : >"$log"
}

finish() {
  [ "$fails" -eq 0 ] || {
    echo "$fails failed" >&2
    exit 1
  }
}

# stand-ins for an editor and sudo, which only run what they're given
mkdir "$tmp/bin"
printf '#!/bin/sh\nexit 0\n' >"$tmp/bin/vim"
printf '#!/bin/sh\nexec "$@"\n' >"$tmp/bin/sudo"
chmod +x "$tmp/bin/vim" "$tmp/bin/sudo"
PATH="$tmp/bin:$PATH"
export PATH
