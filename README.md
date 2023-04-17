# .dotfiles

Based on a <a href="https://news.ycombinator.com/item?id=11070797">Hacker News solution proposed by StreakyCobra</a> for managing and versioning dotfiles.

## Usage

1. Clone repository:

```bash
git clone --bare https://github.com/alessioarcara/.dotfiles.git $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

2. Check out the repository's content into your $HOME directory:

```bash
config checkout
```

The step below might fail. This is because your `$HOME` folder might already have some stock configuration files which would be overwritten by Git. The solution is simple: back up the files if you care about them, remove them if you don't care.

3. Configure the local repository to hide untracked files:

```bash
config config --local status.showUntrackedFiles no
```

4. Use config commands to manage your dotfiles:

```bash
config status
config add .vimrc
config commit -m "Add vimrc"
config push

