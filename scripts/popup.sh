#!/usr/bin/env bash

opencode_session_label() {
  local status="$1" title="$2" directory="$3"
  local dot color reset
  color=''
  reset=$'\033[0m'
  case "$status" in
    approve) color=$'\033[31m' ;;
    process) color=$'\033[33m' ;;
    *) color=$'\033[90m' ;;
  esac
  dot="${color}●${reset}"
  printf '%s %-8s  %-42s  %s' \
    "$dot" \
    "$status" \
    "${title:-Untitled session}" \
    "$(opencode_shorten_path "$directory")"
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
    while IFS= read -r row; do
      IFS=$'\037' read -r source session_id title directory path status updated age attached pane_id window_id tmux_session_id agent model archived parent created child_count summary root_id <<<"$(printf '%s' "$row" | tr '\t' '\037')"
      opencode_session_label "$status" "$title" "$directory"
      printf '\t%s\n' "$row"
    done <"$tmp" |
      fzf --ansi --no-sort --prompt='opencode > ' --delimiter=$'\t' --with-nth=1 --layout=reverse --height=100% |
      cut -f2-
    rm -f "$tmp"
    return 0
  fi

  printf '\nOpenCode sessions\n\n' >&2
  idx=0
  while IFS= read -r row; do
    IFS=$'\037' read -r source session_id title directory path status updated age attached pane_id window_id tmux_session_id agent model archived parent created child_count summary root_id <<<"$(printf '%s' "$row" | tr '\t' '\037')"
    idx=$((idx + 1))
    printf '%2d) %s\n' "$idx" "$(opencode_session_label "$status" "$title" "$directory")" >&2
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
