#!/usr/bin/env bash
# Set up these dotfiles. Safe to re-run.
#   ./install.sh [links|settings|tools]    no argument: all three
# System packages (needs sudo): zsh git curl make gcc xclip unzip jq libnotify-bin
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Directories under home/ linked as a whole; everything else is linked file by
# file, so tools can keep their own files next to ours (~/.claude, ~/.config, ...)
WHOLE=(.config/nvim .claude/skills/testing)

link() {  # link <path under home/>: symlink it to the same path in $HOME
  local src="$DOTFILES/home/$1" dst="$HOME/$1"
  [[ -e "$src" ]] || { echo "install.sh: missing $src" >&2; return 1; }
  [[ "$(readlink "$dst")" == "$src" ]] && return
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$DOTFILES"/* ]]; then
    rm "$dst"  # stale link into this repo: the file moved within it
  elif [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$src" "$dst"
}

links() {
  local d f prune=()
  for d in "${WHOLE[@]}"; do link "$d"; prune+=(-path "./$d" -o); done
  while IFS= read -r f; do link "$f"; done < <(
    cd "$DOTFILES/home" && find . \( "${prune[@]}" -false \) -prune -o \( -type f -o -type l \) -printf '%P\n')
}

# Claude Code / Codex rewrite their settings files, which also hold machine
# state (trust, auto mode), so they aren't linked: fragments/ holds the part
# we version, merged in. Keys are deep-merged (the fragment wins), hooks are
# appended per event unless one with the same command is already there.
# "$HOME" in a fragment string becomes the real home.
merge() {  # merge <fragment> <settings file>
  local file=$2
  [[ -f "$file" ]] || { mkdir -p "$(dirname "$file")"; echo '{}' > "$file"; }
  jq --arg home "$HOME" --slurpfile frag "$DOTFILES/fragments/$1" '
    ($frag[0] | walk(if type == "string" then gsub("\\$HOME"; $home) else . end)) as $f
    | . * ($f | del(.hooks))
    | reduce ($f.hooks // {} | to_entries[]) as $e (.;
        reduce $e.value[] as $g (.;
          if any(.hooks[$e.key][]?.hooks[]?; .command as $c | any($g.hooks[]; .command == $c)) then .
          else .hooks[$e.key] += [$g] end))' \
    "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

settings() {
  merge claude-settings.json ~/.claude/settings.json
  merge codex-hooks.json ~/.codex/hooks.json
}

clone() { [[ -d "$2" ]] || git clone --depth=1 "$1" "$2"; }

tools() {
  # CLI tools pinned in home/.config/mise/config.toml (needs `links` first)
  [[ -x ~/.local/bin/mise ]] || curl -fsSL https://mise.run | sh
  ~/.local/bin/mise install

  # oh-my-zsh + powerlevel10k + plugins
  clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  local ZSH_CUSTOM=~/.oh-my-zsh/custom
  clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

  # tmux plugin manager, run with the tmux from mise
  clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.local/bin/mise exec -- ~/.tmux/plugins/tpm/bin/install_plugins

  # Language tooling used by the nvim config
  command -v rustup >/dev/null && rustup component add rust-analyzer
  command -v uv >/dev/null && uv tool install ruff

  # Plugins, parsers and LSP servers
  ~/.local/bin/mise exec -- nvim --headless "+Lazy! restore" +qa
}

case "${1:-all}" in
  links | settings | tools) "$1" ;;
  all) links; settings; tools ;;
  *) sed -n '2,3p' "$0" >&2; exit 2 ;;
esac
