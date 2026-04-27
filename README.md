# dotfiles

Personal shell and tool configuration, managed with `make`.

## Contents

- `.zshrc` — zsh config (oh-my-zsh, plugins, aliases, PATH)
- `.zprofile` — login shell setup (Homebrew shellenv, autoenv)
- `.config/starship.toml` — Starship prompt config

## Install on a new machine

```sh
# 1. Install required tooling
brew install pre-commit gitleaks
# (plus oh-my-zsh, starship, asdf, etc. — see Prerequisites)

# 2. Clone
git clone git@github.com:ashwinimanoj/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles

# 3. Wire pre-commit hooks (one-time, per clone)
make hooks

# 4. Symlink dotfiles into $HOME (auto-backs up anything existing)
make link

# 5. Reload your shell
exec zsh
```

## Prerequisites

The `.zshrc` references several tools — install before sourcing it, or comment out the references:

- [oh-my-zsh](https://ohmyz.sh/)
- oh-my-zsh custom plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-z`, `autoenv`
- [Homebrew](https://brew.sh/)
- [Starship](https://starship.rs/)
- [asdf](https://asdf-vm.com/) (with `golang` plugin)
- [pre-commit](https://pre-commit.com/) and [gitleaks](https://gitleaks.io/) — for the secret-scanning git hook
- Optional, referenced by PATH: Anaconda, Pulumi, Istio, Vagrant, libpq

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
