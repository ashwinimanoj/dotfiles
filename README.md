# dotfiles

Personal shell and tool configuration, managed with `make`.

## Contents

- `.zshrc` — zsh config (oh-my-zsh, plugins, aliases, PATH)
- `.zprofile` — login shell setup (Homebrew shellenv, autoenv)
- `.config/starship.toml` — Starship prompt config
- `iterm2/com.googlecode.iterm2.plist` — iTerm2 preferences (XML, exported via `make iterm-export`)

## Install on a new machine

```sh
# 1. Install Homebrew if you don't have it: https://brew.sh
git clone git@github.com:ashwinimanoj/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles

# 2. One-shot: install brew packages, oh-my-zsh, custom plugins,
#    symlink dotfiles into ~/ (with auto-backup), wire pre-commit hooks
make setup

# 3. Reload your shell
exec zsh
```

If you'd rather do it piecemeal, run `make bootstrap`, `make link`, `make hooks` separately.

## What `bootstrap` installs

- **Homebrew packages**: `starship`, `asdf`, `autoenv`, `libpq`, `pre-commit`, `gitleaks`
- **[oh-my-zsh](https://ohmyz.sh/)** (theme `agnoster`, no extra install)
- **Custom oh-my-zsh plugins**: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-z`

Optional things `.zshrc` references but `bootstrap` does NOT install (do these yourself if you use them): asdf language plugins (`asdf plugin add golang`, `python`, etc.), tmux, AWS CLI, kubectl, terraform.

## Common workflows

Run `make help` to see all available targets. Most-used:

| Command         | What it does                                                |
|-----------------|-------------------------------------------------------------|
| `make link`     | Symlink repo files into `~/` (after backing up existing)    |
| `make doctor`   | Show install status of each tracked file                    |
| `make diff`     | Show what's different between `~/` and the repo             |
| `make import`   | Copy `~/` files INTO the repo (if you edited `~/` directly) |
| `make scan`     | Run gitleaks against the repo                               |
| `make sync`     | Scan + import + commit + push                               |
| `make backup`   | Snapshot `~/` files into `./backups/<timestamp>/`           |
| `make iterm-export` | Snapshot current iTerm2 prefs into the repo as XML      |
| `make iterm-import` | Apply repo iTerm2 prefs to `~/Library/` (iTerm2 must be quit) |

## Updating

If you have things symlinked (`make link`), edits to `~/.zshrc` flow into the repo automatically — just `git commit` and `git push`. The `pre-commit` hook will run gitleaks on every commit and reject any leaked secret.

If you edited `~/` directly without linking, run `make sync` to import, scan, commit, and push in one shot.

To bump pre-commit hook versions periodically:

```sh
make update-hooks
```

## Adding a new dotfile

1. Add an entry to the `FILES` list in the `Makefile` (format `repo-path:home-path`).
2. `make import` to copy it into the repo.
3. `git add` + commit.
