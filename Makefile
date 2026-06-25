.PHONY: validate smoke
validate:
	@bash -n opencode.tmux scripts/*.sh

smoke: validate
	@./scripts/opencode-list.sh >/dev/null
	@./scripts/opencode-status.sh >/dev/null
