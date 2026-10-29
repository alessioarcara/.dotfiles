#!/bin/sh
# Claude Code status line: caches the plan usage for tmux, prints nothing.
cache="$HOME/.cache/claude-usage.json"
jq -ce '.rate_limits // empty' >"$cache.tmp" 2>/dev/null && mv "$cache.tmp" "$cache"
rm -f "$cache.tmp"
