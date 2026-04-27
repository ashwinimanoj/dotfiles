SHELL := /bin/bash
.DEFAULT_GOAL := help

REPO := $(CURDIR)
TS := $(shell date +%Y%m%d-%H%M%S)
BACKUP_DIR := $(REPO)/backups/$(TS)

# Tracked dotfiles. Format: <repo-relative-path>:<home-relative-path>
# Add new files here to bring them under management.
FILES := .zshrc:.zshrc \
         .zprofile:.zprofile \
         .config/starship.toml:.config/starship.toml

.PHONY: help backup install link import diff sync scan hooks hooks-run update-hooks clean-backups doctor

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

backup: ## Back up current ~/ dotfiles to ./backups/<timestamp>/
	@mkdir -p $(BACKUP_DIR)
	@for pair in $(FILES); do \
	  hp="$$HOME/$${pair#*:}"; \
	  rel="$${pair#*:}"; \
	  if [ -e "$$hp" ] || [ -L "$$hp" ]; then \
	    mkdir -p "$$(dirname "$(BACKUP_DIR)/$$rel")"; \
	    cp -L "$$hp" "$(BACKUP_DIR)/$$rel" 2>/dev/null && echo "  backed up $$hp"; \
	  fi; \
	done
	@echo "backup → $(BACKUP_DIR)"

install: backup ## Copy repo files into ~/ (after backup)
	@for pair in $(FILES); do \
	  src="$(REPO)/$${pair%%:*}"; \
	  dst="$$HOME/$${pair#*:}"; \
	  mkdir -p "$$(dirname "$$dst")"; \
	  if [ "$$src" -ef "$$dst" ]; then \
	    echo "  $$dst already linked to repo, skipping"; \
	  else \
	    cp -f "$$src" "$$dst" && echo "  installed $$dst"; \
	  fi; \
	done

link: backup ## Symlink repo files into ~/ (after backup) — recommended
	@for pair in $(FILES); do \
	  src="$(REPO)/$${pair%%:*}"; \
	  dst="$$HOME/$${pair#*:}"; \
	  mkdir -p "$$(dirname "$$dst")"; \
	  ln -snf "$$src" "$$dst" && echo "  linked $$dst → $$src"; \
	done

import: ## Copy ~/ dotfiles INTO the repo (when you edited ~/ directly)
	@for pair in $(FILES); do \
	  src="$$HOME/$${pair#*:}"; \
	  dst="$(REPO)/$${pair%%:*}"; \
	  if [ ! -e "$$src" ]; then \
	    echo "  skip $$src (missing)"; \
	  elif [ "$$src" -ef "$$dst" ]; then \
	    echo "  $$src already linked to repo, skipping"; \
	  else \
	    mkdir -p "$$(dirname "$$dst")"; \
	    cp -L "$$src" "$$dst" && echo "  imported $$src"; \
	  fi; \
	done

diff: ## Show diff between ~/ and repo files
	@for pair in $(FILES); do \
	  hp="$$HOME/$${pair#*:}"; \
	  rp="$(REPO)/$${pair%%:*}"; \
	  if [ -e "$$hp" ] && [ -e "$$rp" ]; then \
	    diff -u "$$rp" "$$hp" || true; \
	  fi; \
	done

sync: scan import ## Scan + import local edits + commit + push
	@git add -A; \
	if git diff --cached --quiet; then \
	  echo "no changes to sync"; \
	else \
	  git commit -m "$${MSG:-sync dotfiles $(TS)}" && git push; \
	fi

scan: ## Scan repo for secrets via gitleaks
	@gitleaks detect --no-banner --redact --source $(REPO)

hooks: ## Install pre-commit git hooks
	@pre-commit install

hooks-run: ## Run all pre-commit hooks against every file
	@pre-commit run --all-files

update-hooks: ## Bump pre-commit hook versions to latest tagged releases
	@pre-commit autoupdate

clean-backups: ## Delete all local backup snapshots
	@rm -rf $(REPO)/backups && echo "backups cleared"

doctor: ## Show install status of each tracked file
	@for pair in $(FILES); do \
	  rel="$${pair#*:}"; hp="$$HOME/$$rel"; rp="$(REPO)/$${pair%%:*}"; \
	  if [ ! -e "$$hp" ]; then \
	    printf "  %-30s  missing\n" "$$rel"; \
	  elif [ -L "$$hp" ] && [ "$$(readlink "$$hp")" = "$$rp" ]; then \
	    printf "  %-30s  linked\n" "$$rel"; \
	  elif [ "$$hp" -ef "$$rp" ]; then \
	    printf "  %-30s  linked (resolved)\n" "$$rel"; \
	  elif diff -q "$$hp" "$$rp" >/dev/null 2>&1; then \
	    printf "  %-30s  in sync (copy)\n" "$$rel"; \
	  else \
	    printf "  %-30s  DIVERGED\n" "$$rel"; \
	  fi; \
	done
