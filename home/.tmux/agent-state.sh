#!/bin/sh
# Track Claude Code / Codex state per tmux pane and badge the window tab with it.
#   agent-state.sh claude|codex     hook entry point, event payload on stdin
#   agent-state.sh seen <window>    tmux hook: you looked at the window, clear "done"/"error"

badge() {  # window badge = most urgent state among its panes
  states=$(tmux list-panes -t "$1" -F '#{@agent_state}')
  for s in waiting error done running; do
    case "$states" in *"$s"*) tmux set -w -t "$1" @agent_win "$s"; return ;; esac
  done
  tmux set -wu -t "$1" @agent_win
}

if [ "$1" = seen ]; then
  tmux list-panes -t "$2" -F '#{pane_id} #{@agent_state} #{pane_current_command}' |
    while read -r pane state cmd; do
      case "$state:$cmd" in
        done:* | error:* | running:zsh | running:bash | running:sh) tmux set -pu -t "$pane" @agent_state ;;
      esac
    done
  badge "$2"
  exit 0
fi

agent=$1
payload=$(cat)
[ -n "$TMUX_PANE" ] || exit 0
eval "$(printf %s "$payload" | jq -r '@sh "event=\(.hook_event_name // "") tool=\(.tool_name // "") ntype=\(.notification_type // "")"')"
current=$(tmux show -pqv -t "$TMUX_PANE" @agent_state)

case "$event" in
  UserPromptSubmit) state=running ;;
  PreToolUse | PostToolUse | PostToolUseFailure)
    if [ "$event" = PreToolUse ] && [ "$tool" = AskUserQuestion ]; then state=waiting
    elif [ "$current" = running ]; then exit 0
    else state=running; fi ;;
  PermissionRequest) state=waiting ;;
  Notification)
    case "$ntype" in permission_prompt | elicitation_dialog) state=waiting ;; *) exit 0 ;; esac ;;
  Stop) state=done ;;
  StopFailure) state=error ;;
  SessionStart | SessionEnd) state= ;;
  *) exit 0 ;;
esac

window=$(tmux display -p -t "$TMUX_PANE" '#{window_id}')
# "Looking" = a focused client is showing this window right now: no unread badge, no popup.
looking=false
tmux list-clients -F '#{window_id} #{client_flags}' | grep -q "^$window .*focused" && looking=true
[ "$state" = done ] && $looking && state=

if [ -n "$state" ]; then tmux set -p -t "$TMUX_PANE" @agent_state "$state"
else tmux set -pu -t "$TMUX_PANE" @agent_state; fi
badge "$window"
tmux refresh-client -S 2>/dev/null

if ! $looking && [ "$state" != "$current" ] && command -v notify-send >/dev/null; then
  where=$(tmux display -p -t "$TMUX_PANE" '#S:#I #W')
  case "$state" in
    waiting) msg=$(printf %s "$payload" | jq -r '.message // (if .tool_name then "Permesso richiesto: \(.tool_name)" else "Serve input" end)') ;;
    done) msg=$(printf %s "$payload" | jq -r '.last_assistant_message // "Finito"' | tr '\n' ' ' | cut -c1-200) ;;
    error) msg=$(printf %s "$payload" | jq -r '.error // .message // "Errore"') ;;
    *) exit 0 ;;
  esac
  notify-send -a "$agent" "$agent · $where" "$msg" 2>/dev/null &
fi
exit 0
