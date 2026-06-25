#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PLUGIN_DIR/scripts/common.sh"
source "$PLUGIN_DIR/scripts/sessions.sh"
source "$PLUGIN_DIR/scripts/popup.sh"

opencode_open_popup
