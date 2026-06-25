#!/usr/bin/env bash

opencode_jump_to_pane() {
  local pane_id="$1"
  local window_id="$2"

  tmux select-window -t "$window_id" >/dev/null 2>&1 || true
  tmux select-pane -t "$pane_id" >/dev/null 2>&1 || true
  if [ -n "${TMUX_PANE:-}" ]; then
    tmux switch-client -t "$(tmux display-message -p '#S' 2>/dev/null)" >/dev/null 2>&1 || true
  fi
}

opencode_resume_in_tmux() {
  local session_id="$1" directory="$2" target command escaped_dir
  target="$(opencode_resume_target)"
  command="opencode --session $session_id"

  if [ -n "$directory" ]; then
    escaped_dir="$(opencode_escape_single_quotes "$directory")"
    command="cd '$escaped_dir' && $command"
  fi

  if [ "$target" = "pane" ]; then
    tmux split-window -v "$command"
  else
    if [ -n "$directory" ]; then
      tmux new-window -c "$directory" "$command"
    else
      tmux new-window "$command"
    fi
  fi
}

opencode_resume_selected() {
  local session_id="${1:-latest}" title="${2:-}" directory="${3:-}" status="${4:-}" pane_id="${5:-}" window_id="${6:-}"

  if ! opencode_has opencode; then
    opencode_log "opencode CLI not found in PATH"
    return 1
  fi

  if [ "$session_id" = "latest" ]; then
    session_id="$(opencode_latest_session_id)"
  fi

  if [ -z "$session_id" ]; then
    opencode_log "No opencode session found"
    return 1
  fi

  if [ "$status" = "attached" ] && [ -n "$pane_id" ] && opencode_has tmux; then
    opencode_jump_to_pane "$pane_id" "$window_id"
    return 0
  fi

  if opencode_in_tmux; then
    opencode_resume_in_tmux "$session_id" "$directory"
    opencode_refresh_status
    return 0
  fi

  if [ -n "$directory" ]; then
    cd "$directory" || return 1
  fi
  exec opencode --session "$session_id"
}
