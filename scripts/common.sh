#!/usr/bin/env bash

set -u

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

opencode_log() {
  printf '%s\n' "$*" >&2
}

opencode_has() {
  command -v "$1" >/dev/null 2>&1
}

opencode_in_tmux() {
  [ -n "${TMUX:-}" ] && opencode_has tmux
}

opencode_tmux_opt() {
  local key="$1" default="$2" value=""
  if opencode_has tmux; then
    value="$(tmux show-option -gqv "@${key}" 2>/dev/null || true)"
  fi
  if [ -n "$value" ]; then
    printf '%s' "$value"
  else
    printf '%s' "$default"
  fi
}

opencode_db_path() { opencode_tmux_opt opencode-db-path "${OPENCODE_DB_PATH:-$HOME/.local/share/opencode/opencode.db}"; }
opencode_stale_minutes() { opencode_tmux_opt opencode-stale-minutes 240; }
opencode_show_archived() { opencode_tmux_opt opencode-show-archived false; }
opencode_max_sessions() { opencode_tmux_opt opencode-max-sessions 50; }
opencode_resume_target() { opencode_tmux_opt opencode-resume-target window; }
opencode_popup_width() { opencode_tmux_opt opencode-popup-width 90%; }
opencode_popup_height() { opencode_tmux_opt opencode-popup-height 80%; }
opencode_status_colors() { opencode_tmux_opt opencode-status-colors true; }

opencode_is_true() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

opencode_is_integer() {
  case "${1:-}" in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

opencode_safe_integer() {
  local value="${1:-}" fallback="${2:-0}"
  if opencode_is_integer "$value"; then
    printf '%s' "$value"
  else
    printf '%s' "$fallback"
  fi
}

opencode_now_epoch() {
  date +%s
}

opencode_sqlite() {
  local db
  db="$(opencode_db_path)"
  if ! opencode_has sqlite3; then
    opencode_log "sqlite3 is required"
    return 1
  fi
  if [ ! -f "$db" ]; then
    opencode_log "opencode database not found: $db"
    return 1
  fi
  sqlite3 -noheader -separator $'\t' "$db" "$1"
}

opencode_format_age() {
  local minutes="${1:-}"
  if [ -z "$minutes" ] || [ "$minutes" = "-1" ]; then
    printf 'unknown'
  elif [ "$minutes" -lt 1 ]; then
    printf 'now'
  elif [ "$minutes" -lt 60 ]; then
    printf '%sm ago' "$minutes"
  elif [ "$minutes" -lt 1440 ]; then
    printf '%sh ago' "$((minutes / 60))"
  else
    printf '%sd ago' "$((minutes / 1440))"
  fi
}

opencode_shorten_path() {
  local path="${1:-}"
  if [ -z "$path" ]; then
    printf '-'
    return 0
  fi
  case "$path" in
    "$HOME"*) printf '~%s' "${path#$HOME}" ;;
    *) printf '%s' "$path" ;;
  esac
}

opencode_escape_single_quotes() {
  printf "%s" "$1" | sed "s/'/'\\''/g"
}

opencode_refresh_status() {
  if opencode_in_tmux; then
    tmux refresh-client -S >/dev/null 2>&1 || true
  fi
}
