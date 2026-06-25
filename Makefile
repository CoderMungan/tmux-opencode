.PHONY: validate smoke
validate:
	@bash -n scripts/*.sh
	@bash -n ./opencode.tmux
	@./opencode.tmux

smoke: validate
	@./scripts/opencode-list.sh >/dev/null
	@./scripts/opencode-status.sh >/dev/null
