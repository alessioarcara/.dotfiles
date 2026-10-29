#!/bin/sh
# tmux status segment: Claude or Codex plan usage, from a cache file.
#   usage.sh claude   cache written by ~/.claude/statusline.sh on every Claude turn
#   usage.sh codex    cache refreshed here, in background, every 5 minutes
case "$1" in
  claude) icon="✻" color="#D97757" stale_after=600 ;;
  codex) icon="⬡" color="#10A37F" stale_after=900 ;;
  *) exit 2 ;;
esac
cache="$HOME/.cache/$1-usage.json"
age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
if [ "$1" = codex ] && [ "$age" -gt 300 ]; then
  flock -n "$HOME/.cache/codex-usage.lock" timeout 30 python3 "$HOME/.codex/fetch-usage.py" >/dev/null 2>&1 &
fi
[ -r "$cache" ] || exit 0
jq -r --arg icon "$icon" --arg color "$color" \
  --argjson stale "$([ "$age" -gt "$stale_after" ] && echo true || echo false)" '
  def color($p): if $stale then "brightblack" elif $p >= 80 then "red" elif $p >= 50 then "yellow" else "green" end;
  def bar($p): ([$p / 20 | ceil, 5] | min) as $n | ("■" * $n // "") + ("□" * (5 - $n) // "");
  def left: if . >= 86400 then "\(. / 86400 | floor)d\(. % 86400 / 3600 | floor)h" else "\(. / 3600 | floor)h\(. % 3600 / 60 | floor)m" end;
  def fmt($name): if . == null then empty
    elif (.resets_at // 0) < now then "#[fg=brightblack]\($name) reset"
    else (.used_percentage | floor) as $p
      | "#[fg=brightblack]\($name) #[fg=\(color($p))]\(bar($p)) \($p)%#[fg=brightblack] \(.resets_at - now | left)" end;
  "#[fg=\(if $stale then "brightblack" else $color end)]\($icon) "
  + ([ (.five_hour | fmt("5h")), (.seven_day | fmt("7d")) ] | join("  "))
  + "#[fg=brightblack]"' "$cache" 2>/dev/null
