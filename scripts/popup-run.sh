#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PLUGIN_DIR/scripts/common.sh"
source "$PLUGIN_DIR/scripts/sessions.sh"
source "$PLUGIN_DIR/scripts/popup.sh"
source "$PLUGIN_DIR/scripts/resume.sh"

selection="$(opencode_select_session || true)"
[ -n "$selection" ] || exit 0

IFS=$'\037' read -r source session_id title directory path status updated age attached pane_id window_id tmux_session_id agent model archived parent created child_count summary root_id <<<"$(printf '%s' "$selection" | tr '\t' '\037')"
opencode_resume_selected "$session_id" "$title" "$directory" "$status" "$attached" "$pane_id" "$window_id"
