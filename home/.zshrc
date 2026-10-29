# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)

# CLI tools pinned in ~/.config/mise/config.toml (nvim, node, tmux, fzf, ...)
command -v mise >/dev/null && eval "$(mise activate zsh)"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export EDITOR=nvim
export VISUAL=nvim

alias vim='nvim'

# fzf: Ctrl-R history, Ctrl-T files, Alt-C cd
command -v fzf >/dev/null && source <(fzf --zsh)

# Machine-specific settings (CUDA, work aliases, ...) live outside the repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zoxide: `z <part of path>` jumps to frequent dirs, `zi` picks with fzf (keep last)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
