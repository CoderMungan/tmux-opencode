#!/usr/bin/env bash

opencode_session_label() {
  local session_id="$1" title="$2" directory="$3" status="$4" age_minutes="$5" pane_id="$6"
  printf '%-10s  %-14s  %-30s  %-26s  %-8s  %s' \
    "$status" \
    "$session_id" \
    "${title:-Untitled session}" \
    "$(opencode_shorten_path "$directory")" \
    "$(opencode_format_age "$age_minutes")" \
    "${pane_id:-}"
}

opencode_select_session() {
  local tmp raw selected line idx count
  tmp="$(mktemp)"

  opencode_merge_sessions >"$tmp"
  count=$(awk 'END { print NR + 0 }' "$tmp")
  if [ "$count" -eq 0 ]; then
    rm -f "$tmp"
    opencode_log "No opencode sessions found"
    return 1
  fi

  if opencode_has fzf; then
    while IFS=$'\t' read -r source session_id title directory path status updated age attached pane_id window_id tmux_session_id agent model archived; do
      opencode_session_label "$session_id" "$title" "$directory" "$status" "$age" "$pane_id"
      printf '\t%s\n' "$source	$session_id	$title	$directory	$path	$status	$updated	$age	$attached	$pane_id	$window_id	$tmux_session_id	$agent	$model	$archived"
    done <"$tmp" |
      fzf --ansi --no-sort --prompt='opencode > ' --delimiter=$'\t' --with-nth=1 --layout=reverse --height=100% |
      cut -f2-
    rm -f "$tmp"
    return 0
  fi

  printf '\nOpenCode sessions\n\n' >&2
  idx=0
  while IFS=$'\t' read -r source session_id title directory path status updated age attached pane_id window_id tmux_session_id agent model archived; do
    idx=$((idx + 1))
    printf '%2d) %s\n' "$idx" "$(opencode_session_label "$session_id" "$title" "$directory" "$status" "$age" "$pane_id")" >&2
  done <"$tmp"
  printf '\nSelect session number (blank to cancel): ' >&2
  IFS= read -r selected
  if [ -z "$selected" ]; then
    rm -f "$tmp"
    return 1
  fi
  line=$(awk -v n="$selected" 'NR == n { print; exit }' "$tmp")
  rm -f "$tmp"
  [ -n "$line" ] || return 1
  printf '%s\n' "$line"
}

opencode_open_popup() {
  if ! opencode_has tmux; then
    opencode_log "tmux is required"
    return 1
  fi
  tmux display-popup -E -w "$(opencode_popup_width)" -h "$(opencode_popup_height)" "$PLUGIN_DIR/scripts/popup-run.sh"
}
