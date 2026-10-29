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
# syntax colors only, no line numbers or pager; piped output stays plain cat
alias cat='bat --style=plain --paging=never'

# fzf: Ctrl-T files (with a bat preview), Alt-C cd
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
command -v fzf >/dev/null && source <(fzf --zsh)

# atuin: Ctrl-R searches the shell history (after fzf, so it takes Ctrl-R);
# the up arrow keeps the plain zsh history
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# Machine-specific settings (CUDA, work aliases, ...) live outside the repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zoxide: `z <part of path>` jumps to frequent dirs, `zi` picks with fzf (keep last)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
