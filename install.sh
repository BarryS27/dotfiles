#!/usr/bin/env bash
set -euo pipefail

HOME_DIR="${HOME}"
BACKUP_DIR="$HOME_DIR/.dotfiles_backup"

log() {
    printf '➜ %s\n' "$1"
}

install_stow() {
    if command -v stow >/dev/null 2>&1; then
        return
    fi

    log "Installing GNU Stow..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y stow
    elif command -v brew >/dev/null 2>&1; then
        brew install stow
    else
        echo "❌ Could not install stow automatically (missing apt-get/brew)." >&2
        exit 1
    fi
}

install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        return
    fi

    log "Installing zsh..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zsh
    elif command -v brew >/dev/null 2>&1; then
        brew install zsh
    else
        echo "❌ Could not install zsh automatically (missing apt-get/brew)." >&2
        exit 1
    fi
}

backup_if_real_file() {
    local target="$1"

    if [[ -e "$target" && ! -L "$target" ]]; then
        local rel="${target#$HOME_DIR/}"
        local destination="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$destination")"
        mv "$target" "$destination"
        log "Backed up $target -> $destination"
    fi
}

ensure_stow_targets() {
    mkdir -p "$HOME_DIR/.config/nvim"
    mkdir -p "$HOME_DIR/bin"
}

maybe_switch_to_zsh() {
    local current_shell
    current_shell="${SHELL:-}"

    if [[ "$current_shell" == *"/zsh" ]]; then
        log "Default shell is already zsh."
        return
    fi

    local zsh_path
    zsh_path="$(command -v zsh)"

    if ! grep -qx "$zsh_path" /etc/shells; then
        echo "❌ zsh path not present in /etc/shells: $zsh_path" >&2
        exit 1
    fi

    log "Changing default shell to zsh..."
    chsh -s "$zsh_path"
}

main() {
    cd "$(dirname "$0")"

    install_stow
    install_zsh

    mkdir -p "$BACKUP_DIR"
    ensure_stow_targets

    backup_if_real_file "$HOME_DIR/.zshrc"
    backup_if_real_file "$HOME_DIR/.zprofile"
    backup_if_real_file "$HOME_DIR/aliases.zsh"
    backup_if_real_file "$HOME_DIR/.gitconfig"
    backup_if_real_file "$HOME_DIR/.gitignore_global"
    backup_if_real_file "$HOME_DIR/.config/nvim/init.lua"
    backup_if_real_file "$HOME_DIR/bin/sync-barrys27-ui"

    log "Applying GNU Stow packages..."
    stow -T "$HOME_DIR" zsh git nvim scripts

    maybe_switch_to_zsh

    cat <<MSG

✨ Installation complete.
Backups directory: $BACKUP_DIR
Reload shell:
  exec zsh
MSG
}

main "$@"
