#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

tmux_set_default() {
  local option="$1" default_value="$2"
  local current_value=""
  current_value="$(tmux show-option -gqv "$option" 2>/dev/null || true)"
  if [ -z "$current_value" ]; then
    tmux set-option -gq "$option" "$default_value"
  fi
}

tmux_set_default @opencode-key O
tmux_set_default @opencode-status-position right
tmux_set_default @opencode-popup-width 90%
tmux_set_default @opencode-popup-height 80%
tmux_set_default @opencode-stale-minutes 240
tmux_set_default @opencode-show-archived false
tmux_set_default @opencode-max-sessions 50
tmux_set_default @opencode-resume-target window
tmux_set_default @opencode-status-colors true

key="$(tmux show-option -gqv @opencode-key)"
width="$(tmux show-option -gqv @opencode-popup-width)"
height="$(tmux show-option -gqv @opencode-popup-height)"

tmux unbind-key "$key" 2>/dev/null || true
tmux bind-key "$key" display-popup -E -w "$width" -h "$height" "$PLUGIN_DIR/scripts/popup-run.sh"
