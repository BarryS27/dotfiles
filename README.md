# ⚡ BarryS27's Dotfiles

Minimal, Stow-managed dotfiles focused on Zsh, Git, Neovim, and lightweight shell tooling.

## 📦 Installation

```bash
git clone https://github.com/BarryS27/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer is idempotent and safe to run multiple times.

### What `install.sh` does

1. Installs GNU Stow if missing (`apt-get` or `brew`).
2. Backs up existing non-symlink configs to `~/.dotfiles_backup/`.
3. Runs `stow -T "$HOME" zsh git nvim scripts`.
4. Ensures zsh is installed and sets it as the default shell.

## 📂 Repository Structure

```text
~/dotfiles
├── Brewfile
├── install.sh
├── zsh/
│   ├── .zprofile
│   ├── .zshrc
│   └── aliases.zsh
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── nvim/
│   └── .config/nvim/init.lua
└── scripts/
    └── bin/sync-barrys27-ui
```

## 🧩 Notes

- `zsh/aliases.zsh` contains only aliases migrated from the prior `.bashrc`.
- `zsh/.zprofile` contains exported environment variables.
- `zsh/.zshrc` contains shell behavior, prompt logic, and custom functions.
- `scripts/bin/sync-barrys27-ui` syncs `@barrys27/ui` CSS to a local target directory.
