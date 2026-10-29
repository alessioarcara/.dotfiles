# .dotfiles

zsh (oh-my-zsh + powerlevel10k), tmux, Neovim, alacritty and lazygit
configs, plus a tmux setup for coding agents (Claude Code, Codex).

## Install

```bash
git clone git@github.com:alessioarcara/.dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
chsh -s "$(which zsh)"
```

`home/` mirrors `$HOME`. `install.sh` runs three steps, or just the one you
name (`./install.sh links`); all are safe to re-run:

- `links`: symlinks every file under `home/` to the same path in `$HOME`
  (existing files are moved to `*.bak.<timestamp>`). The directories in `WHOLE`
  (`.config/nvim`, `.claude/skills/testing`) are linked as a whole. A new file
  under `home/` needs no other change: just re-run `links`.
- `settings`: merges `fragments/claude-settings.json` (model, theme, plugins,
  status line, worktree base, agent hooks) into `~/.claude/settings.json` and
  `fragments/codex-hooks.json` into `~/.codex/hooks.json`. These files are not
  linked because the tools rewrite them and they also hold machine state
  (trust, auto mode). Fragment keys win, hooks are added only if missing,
  everything else in the file is kept.
- `tools`: installs [mise](https://mise.jdx.dev) and the CLI tools pinned in
  `home/.config/mise/config.toml` (Neovim, tree-sitter, node, tmux, lazygit,
  delta, ripgrep, fd, fzf, zoxide, ...) per user, without sudo; then
  oh-my-zsh, powerlevel10k, tpm, and the Neovim plugins from `lazy-lock.json`.
  `mise upgrade` takes the tools to the newest release matching their pins.

System packages it expects: `zsh git curl make gcc xclip unzip jq
libnotify-bin`, plus `rustup` and `uv` if you want Rust/Python tooling.

Machine-specific shell settings go in `~/.zshrc.local` (not versioned).

## Agents in tmux

| What | Where (under `home/`) |
| --- | --- |
| Window badge per agent: ◐ working, ● waiting for you, ✓ done (unseen), ✗ error, plus `notify-send` | `.tmux/agent-state.sh`, run by the Claude/Codex hooks |
| Claude and Codex plan usage in the status bar | `.tmux/usage.sh claude\|codex`, fed by `.claude/statusline.sh` and `.codex/fetch-usage.py` |
| `prefix W` or `wt [claude\|codex] <name> [prompt]`: an agent (default Claude) in a new worktree, in its own window with a shell on the side | `.local/bin/wt` |
| `wt -n 3 [claude\|codex] <name> prompt`: same prompt to 3 agents, in background windows | `.local/bin/wt` |
| `wt --rm <name>`: remove a worktree and its branch, refusing if that loses work (Claude asks on exit instead) | `.local/bin/wt` |
| Worktree setup: symlink `data` (or the paths in `<repo>/.worktreelink`), `uv sync` | `.local/bin/wt-setup` |

## Neovim

Neovim ≥ 0.12, plugins managed by lazy.nvim. Leader is `<Space>`.

| Keys | Action |
| --- | --- |
| `<leader>pf` / `<C-p>` / `<leader>ps` | find files / git files / grep |
| `<leader>pv` | netrw |
| `gd`, `K`, `[d` `]d` | definition, hover, prev/next diagnostic |
| `<leader>vca` `<leader>vrn` `<leader>vrr` `<leader>vd` `<leader>f` | code action, rename, references, diagnostic float, format |
| `<A-,>` `<A-.>` `<A-1..5>` `<A-c>` `<A-p>` | barbar: prev/next, go to, close, pick |
| `<C-h/j/k/l>` | move between splits and tmux panes |
| `<leader>gs` | fugitive |
