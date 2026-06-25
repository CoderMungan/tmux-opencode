#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PLUGIN_DIR/scripts/common.sh"
source "$PLUGIN_DIR/scripts/sessions.sh"
source "$PLUGIN_DIR/scripts/resume.sh"

if [ "${1:-latest}" = "latest" ]; then
  opencode_resume_selected latest
else
  session_id="$1"
  directory="${2:-}"
  status="${3:-}"
  pane_id="${4:-}"
  window_id="${5:-}"
  opencode_resume_selected "$session_id" "" "$directory" "$status" "$pane_id" "$window_id"
fi
