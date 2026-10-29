#!/bin/sh
# Generate a conventional commit message from the staged diff with Claude Code,
# let the user edit it, then commit only after explicit confirmation.
set -e

diff=$(git diff --cached)
if [ -z "$diff" ]; then
    echo "Nothing staged." >&2
    exit 1
fi

echo "Generating commit message with Claude..." >&2

prompt='You are given a staged git diff. Write a commit message for it.

Rules:
- Conventional Commits: "<type>: <emoji> <subject>" on the first line, e.g. "fix: 🐛 always return every frame in /propagate" or "refactor: ♻️ extract common SAM parts".
- type is one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
- emoji is a fitting gitmoji (✨ feat, 🐛 fix, 📝 docs, 💄 style, ♻️ refactor, ⚡️ perf, ✅ test, 👷 build, 🎡 ci, 🔨 chore, ⏪ revert, 🔖 version bump, 📌 pin dependency, 🩹 small fix).
- Subject: imperative mood, lowercase, no trailing period, under 72 characters.
- Then a blank line and a short body (2-4 lines) explaining what changed and why, only if the diff is non-trivial.
- Output ONLY the commit message. No markdown, no code fences, no quotes, no explanation. Do not use any tools.

Diff:
'

msgfile=$(git rev-parse --git-dir)/AI_COMMIT_MSG
printf '%s\n%s\n' "$prompt" "$diff" | claude -p > "$msgfile"

# Let the user edit the message. A non-zero editor exit (e.g. :cq in vim) aborts.
editor=$(git var GIT_EDITOR)
if ! sh -c "$editor \"\$1\"" -- "$msgfile"; then
    echo "Editor aborted, nothing committed." >&2
    exit 1
fi

if [ -z "$(sed '/^#/d;/^[[:space:]]*$/d' "$msgfile")" ]; then
    echo "Empty message, nothing committed." >&2
    exit 1
fi

echo
echo "----- commit message -----"
cat "$msgfile"
echo "--------------------------"
printf 'Commit with this message? [y/N] '
read -r answer
case "$answer" in
    y|Y|yes|YES) git commit --file "$msgfile" ;;
    *) echo "Not committed. Message kept in $msgfile" >&2; exit 1 ;;
esac
