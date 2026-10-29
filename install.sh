#!/usr/bin/env bash
# Install the tools these dotfiles expect. Safe to re-run.
# System packages (needs sudo): zsh git curl make gcc ripgrep xclip unzip
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Symlink configs into $HOME, backing up whatever is already there
link() {
  local src="$DOTFILES/home/$1" dst="$HOME/$1"
  [[ "$(readlink "$dst")" == "$src" ]] && return
  mkdir -p "$(dirname "$dst")"
  [[ -e "$dst" || -L "$dst" ]] && mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  ln -s "$src" "$dst"
}
link .zshrc
link .tmux.conf
link .config/nvim

clone() { [[ -d "$2" ]] || git clone --depth=1 "$1" "$2"; }

# oh-my-zsh + powerlevel10k + plugins
clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
ZSH_CUSTOM=~/.oh-my-zsh/custom
clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# tmux plugin manager
clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# Neovim (latest stable) and tree-sitter CLI into ~/.local
mkdir -p ~/.local/bin ~/.local/opt
case "$(uname -s)" in
  Linux)
    curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
      | tar -xz -C ~/.local/opt
    ln -sfn ~/.local/opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
    curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
      | gunzip > ~/.local/bin/tree-sitter
    chmod +x ~/.local/bin/tree-sitter
    ;;
  Darwin) brew install neovim tree-sitter-cli ;;
esac

# Language tooling used by the nvim config
command -v rustup >/dev/null && rustup component add rust-analyzer
command -v uv >/dev/null && uv tool install ruff

# Plugins, parsers and LSP servers
~/.local/bin/nvim --headless "+Lazy! restore" +qa
