.PHONY: lint test check

lint:
	shellcheck -x bin/* tests/*.sh
	shellcheck -s bash keybars-shell.bash
	zsh -n keybars-shell.plugin.zsh
	if command -v fish >/dev/null; then fish --no-execute conf.d/keybars.fish; fi

test:
	sh tests/zsh_test.sh
	sh tests/bash_test.sh
	sh tests/fish_test.sh
	sh tests/setup_test.sh

check: lint test
