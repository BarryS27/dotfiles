#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"
BACKUP_DIR="$HOME_DIR/.dotfiles_backup/$(date +%F-%T)"

# ── Logging ───────────────────────────────────────────────────────────
log()  { printf '  \033[34m➜\033[0m  %s\n'       "$1"; }
ok()   { printf '  \033[32m✔\033[0m  %s\n'       "$1"; }
warn() { printf '  \033[33m⚠\033[0m  %s\n'       "$1"; }
die()  { printf '  \033[31m✘\033[0m  %s\n' "$1" >&2; exit 1; }

# ── Package installation helpers ──────────────────────────────────────
pkg_install() {
    local pkg="$1"
    if command -v brew &>/dev/null; then
        brew install "$pkg"
    elif command -v apt-get &>/dev/null; then
        sudo apt-get install -y "$pkg"
    else
        die "Cannot install $pkg — neither brew nor apt-get found."
    fi
}

ensure() {
    local cmd="$1" pkg="${2:-$1}"
    command -v "$cmd" &>/dev/null && { ok "$cmd already installed"; return; }
    log "Installing $pkg..."
    pkg_install "$pkg"
}

# ── Backup a real file (not a symlink) ────────────────────────────────
backup_if_real() {
    local target="$1"
    [[ -e "$target" && ! -L "$target" ]] || return 0
    local rel="${target#"$HOME_DIR/"}"
    local dest="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    warn "Backed up  $target  →  $dest"
}

# ── Create directories stow needs on first run ────────────────────────
ensure_stow_targets() {
    mkdir -p "$HOME_DIR/.config/nvim"
    mkdir -p "$HOME_DIR/bin"
}

# ── Backup existing configs ───────────────────────────────────────────
backup_existing() {
    backup_if_real "$HOME_DIR/.zshrc"
    backup_if_real "$HOME_DIR/.zprofile"
    backup_if_real "$HOME_DIR/aliases.zsh"
    backup_if_real "$HOME_DIR/functions.zsh"
    backup_if_real "$HOME_DIR/fzf.zsh"
    backup_if_real "$HOME_DIR/.gitconfig"
    backup_if_real "$HOME_DIR/.gitignore_global"
    backup_if_real "$HOME_DIR/.config/nvim/init.lua"
    backup_if_real "$HOME_DIR/bin/sync-barrys27-ui"
}

# ── Default shell ─────────────────────────────────────────────────────
set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)"
    [[ "$SHELL" == "$zsh_path" ]] && { ok "Default shell is already zsh"; return; }

    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        log "Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    log "Setting default shell to zsh..."
    chsh -s "$zsh_path"
    ok "Default shell changed. Restart your terminal."
}

# ── Main ──────────────────────────────────────────────────────────────
main() {
    printf '\n\033[1m  dotfiles installer\033[0m\n\n'

    ensure stow
    ensure zsh
    ensure nvim neovim

    mkdir -p "$BACKUP_DIR"
    ensure_stow_targets
    backup_existing

    log "Stowing packages: zsh git nvim scripts bin..."
    stow --dir="$DOTFILES" --target="$HOME_DIR" --restow zsh git nvim scripts bin
    ok "Symlinks applied."

    set_default_shell

    printf '\n\033[1m  Done.\033[0m\n'
    printf '  Backups:  %s\n' "$BACKUP_DIR"
    printf '  Reload:   exec zsh\n'
    printf '  Neovim:   open nvim — lazy.nvim will install plugins on first launch\n\n'
}

main "$@"
