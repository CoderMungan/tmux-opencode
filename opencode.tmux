#!/usr/bin/env bash

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

set_default_option() {
  local key="$1" value="$2" current
  current="$(tmux show-option -gqv "$key" 2>/dev/null || true)"
  if [ -z "$current" ]; then
    tmux set-option -gq "$key" "$value"
  fi
}

set_default_option @opencode-key "${OPENCODE_TMUX_KEY:-O}"
set_default_option @opencode-status-position "${OPENCODE_STATUS_POSITION:-right}"
set_default_option @opencode-popup-width "${OPENCODE_POPUP_WIDTH:-90%}"
set_default_option @opencode-popup-height "${OPENCODE_POPUP_HEIGHT:-80%}"
set_default_option @opencode-stale-minutes "${OPENCODE_STALE_MINUTES:-240}"
set_default_option @opencode-show-archived "${OPENCODE_SHOW_ARCHIVED:-false}"
set_default_option @opencode-max-sessions "${OPENCODE_MAX_SESSIONS:-50}"
set_default_option @opencode-db-path "${OPENCODE_DB_PATH:-$HOME/.local/share/opencode/opencode.db}"
set_default_option @opencode-resume-target "${OPENCODE_RESUME_TARGET:-window}"
set_default_option @opencode-status-colors "${OPENCODE_STATUS_COLORS:-true}"

key="$(tmux show-option -gqv @opencode-key)"
width="$(tmux show-option -gqv @opencode-popup-width)"
height="$(tmux show-option -gqv @opencode-popup-height)"

tmux bind-key "$key" display-popup -E -w "$width" -h "$height" "$PLUGIN_DIR/scripts/popup-run.sh"
