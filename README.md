# dotfiles

Personal shell and tool configuration.

## Contents

- `.zshrc` — zsh config (oh-my-zsh, plugins, aliases, PATH)
- `.zprofile` — login shell setup (Homebrew shellenv, autoenv)
- `.config/starship.toml` — Starship prompt config

## Install on a new machine

```sh
git clone git@github.com:ashwinimanoj/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles

# Back up anything existing first
for f in .zshrc .zprofile; do
  [ -e ~/$f ] && mv ~/$f ~/$f.backup
done
[ -e ~/.config/starship.toml ] && mv ~/.config/starship.toml ~/.config/starship.toml.backup

# Symlink into $HOME
ln -s ~/projects/dotfiles/.zshrc ~/.zshrc
ln -s ~/projects/dotfiles/.zprofile ~/.zprofile
mkdir -p ~/.config
ln -s ~/projects/dotfiles/.config/starship.toml ~/.config/starship.toml
```

## Prerequisites

The `.zshrc` references several tools — install these before sourcing it, or comment out the references:

- [oh-my-zsh](https://ohmyz.sh/)
- oh-my-zsh custom plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-z`, `autoenv`
- [Homebrew](https://brew.sh/)
- [Starship](https://starship.rs/)
- [asdf](https://asdf-vm.com/) (with `golang` plugin)
- Anaconda (optional — `/opt/anaconda3`)
- Other tools referenced by PATH: Pulumi, Istio, Vagrant, libpq

## Updating

Edit the files in this repo, commit, push. Symlinks ensure `~/.zshrc` etc. stay in sync.
