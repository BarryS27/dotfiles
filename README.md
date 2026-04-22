# dotfiles

Stow-managed dotfiles for Zsh, Git, and Neovim. Plugin-free shell, lazy.nvim for the editor.

## Install

```bash
git clone https://github.com/BarryS27/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer is idempotent. Re-running it backs up any real files that would be overwritten to `~/.dotfiles_backup/<timestamp>/`, then restows.

On first Neovim launch, lazy.nvim bootstraps itself and installs all plugins automatically.

---

## Structure

```
dotfiles/
├── bin/
│   └── npm-publish.sh      version bump + publish to npm
├── git/
│   ├── .gitconfig          delta pager, rerere, histogram diff
│   └── .gitignore_global
├── did/
│   ├── bin/
│   └── identity/
└── zsh/
    ├── .zprofile           PATH, exports, tool init (login shell)
    ├── .zshrc              completion, prompt, zoxide, key bindings
    ├── aliases.zsh         eza / bat / git / npm / python shortcuts
    ├── functions.zsh       mkcd, up, extract, save, note, ...
    └── fzf.zsh             keybindings, previews, fzf-branch, fzf-kill
```

---

## Key Bindings (Zsh)

| Key | Action |
|-----|--------|
| `Ctrl-T` | insert file path via fzf |
| `Ctrl-R` | fuzzy search command history |
| `Alt-C` | cd into subdirectory via fzf |
| `↑` / `↓` | history substring search by prefix |
| `Ctrl-←` / `Ctrl-→` | word navigation |

## Key Bindings (Neovim)

`Space` is the leader key.

| Key | Action |
|-----|--------|
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` | buffers |
| `<leader>fo` | recent files |
| `<leader>ft` | find TODOs |
| `gd` | go to definition |
| `gr` | go to references |
| `K` | hover documentation |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action |
| `<leader>lf` | format buffer |
| `]d` / `[d` | next/prev diagnostic |
| `]h` / `[h` | next/prev git hunk |
| `<leader>gs` | stage hunk |
| `<leader>gb` | git blame line |
| `-` | open parent directory (oil) |
| `<leader>xx` | toggle diagnostics panel |

---

## Shell Functions

| Function | Usage |
|----------|-------|
| `save [path] ["msg"] [--push]` | pull → add → commit → optional push |
| `note [query]` | search `~/Me.archive` with fzf + bat preview |
| `mkcd <dir>` | create directory and cd into it |
| `up [n]` | cd up n levels |
| `extract <file>` | unpack any archive format |
| `fzf-branch` | switch git branch interactively |
| `fzf-kill` | kill process with fzf |
| `json [file]` | pretty-print JSON |
| `port [n]` | show what is listening on a port |

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

Managed via `Brewfile` (macOS) or the `postCreateCommand` in `.devcontainer/devcontainer.json` (Linux/Codespaces).

Core: `stow`, `zsh`, `fzf`, `zoxide`, `fd`, `bat`, `eza`, `ripgrep`, `delta`, `neovim`, `gh`, `jq`
