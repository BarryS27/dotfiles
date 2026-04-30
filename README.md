# dotfiles

Dotter-managed dotfiles for Zsh, Git, Ghostty, and Zed. Plugin-free shell with a fast custom prompt.

## Install

```bash
git clone https://github.com/asong56/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer is idempotent. Re-running it backs up any real files that would be overwritten to `~/.dotfiles_backup/<timestamp>/`, then restows.

---

## Structure

```
dotfiles/
├── .bashrc                     bash fallback config
├── .config/
│   ├── Caddyfile               local reverse proxy config
│   ├── bottom.toml             system monitor (btm) config
│   ├── starship.toml           terminal behavior config
│   └── config.ghostty          Ghostty terminal config
├── .devcontainer/
│   └── devcontainer.json       Codespaces / Dev Container setup
├── .dotter/
│   └── global.toml             dotter variables (name, font, paths, features)
├── bin/
│   └── npm-publish.sh          version bump + publish to npm
├── did/
│   ├── bin/                    DID signing / verification scripts
│   └── identity/               public key + DID document
├── git/
│   ├── .gitconfig              delta pager, rerere, histogram diff
│   └── .gitignore_global
├── templates/
│   ├── biome.json              shared Biome (JS/TS linter) config
│   └── pyproject.toml          shared Python project template
├── zed/
│   ├── settings.json           Zed editor settings
│   └── asevka.toml             custom font variant config
├── zsh/
│   ├── .zprofile               PATH, exports, tool init (login shell)
│   ├── .zshrc                  history, prompt, completion, key bindings
│   ├── aliases.zsh             eza / bat / git / npm / python shortcuts
│   ├── functions.zsh           mkcd, up, extract, save, note, ...
│   └── fzf.zsh                 fzf key bindings, previews, fzf-branch, fzf-kill
├── dotter.toml                 symlink map for all dotfile targets
├── Brewfile                    macOS dependencies
└── install.sh                  bootstrap: install deps + stow dotfiles
```

---

## Key Bindings (Zsh / fzf)

| Key | Action |
|-----|--------|
| `Ctrl-T` | insert file path via fzf |
| `Ctrl-R` | fuzzy search command history |
| `Alt-C` | cd into subdirectory via fzf |
| `↑` / `↓` | history substring search by prefix |
| `Ctrl-←` / `Ctrl-→` | word navigation |

---

## Shell Functions

| Function | Usage |
|----------|-------|
| `save [path] ["msg"] [--push]` | pull → add → commit → optional push |
| `note [query]` | search `~/Me.archive` with fzf + bat preview |
| `mkcd <dir>` | create directory and cd into it |
| `up [n]` | cd up n levels |
| `extract <file>` | unpack any archive format |
| `gitroot` | cd to repo root |
| `fzf-branch` | switch git branch interactively |
| `fzf-kill` | kill process with fzf |
| `json [file]` | pretty-print JSON |
| `port [n]` | show what is listening on a port |
| `envdiff <file>` | show env changes after sourcing a file |

---

## Local Overrides

Machine-specific config that is not tracked:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | extra shell config (secrets, work env, machine-specific) |
| `~/.gitconfig.local` | work email, GPG signing key, local git settings |

`~/.gitconfig` includes `~/.gitconfig.local` automatically if it exists.

---

## Dependencies

Managed via `Brewfile` (macOS) or the `postCreateCommand` in `.devcontainer/devcontainer.json` (Linux / Codespaces).

Core: `dotter`, `stow`, `zsh`, `fzf`, `zoxide`, `fd`, `starship`, `ripgrep`, `bottom`, `git`, `gh`

Dev: `uv`, `ruff`, `bun`, `rustup`, `biome`, `duckdb`
