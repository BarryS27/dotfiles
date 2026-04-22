#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"
BACKUP_DIR="$HOME_DIR/.dotfiles_backup/$(date +%F-%T)"

# ── Logging ───────────────────────────────────────────────────────────
log()  { printf '  \033[34m➜\033[0m  %s\n' "$1"; }
ok()   { printf '  \033[32m✔\033[0m  %s\n' "$1"; }
warn() { printf '  \033[33m⚠\033[0m  %s\n' "$1"; }
die()  { printf '  \033[31m✘\033[0m  %s\n' "$1" >&2; exit 1; }

# ── detect package manager ───────────────────────────────────────────
install_pkg() {
    local pkg="$1"

    if command -v brew &>/dev/null; then
        brew install "$pkg"
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y "$pkg"
    else
        die "No supported package manager found (brew/apt)."
    fi
}

ensure() {
    local cmd="$1"
    local pkg="${2:-$1}"

    if command -v "$cmd" &>/dev/null; then
        ok "$cmd already installed"
        return
    fi

    log "Installing $pkg..."
    install_pkg "$pkg"
}

# ── backup ────────────────────────────────────────────────────────────
backup_if_real() {
    local target="$1"
    [[ -e "$target" && ! -L "$target" ]] || return 0

    local rel="${target#"$HOME_DIR/"}"
    local dest="$BACKUP_DIR/$rel"

    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"

    warn "backup: $target → $dest"
}

backup_existing() {
    backup_if_real "$HOME_DIR/.zshrc"
    backup_if_real "$HOME_DIR/.zprofile"
    backup_if_real "$HOME_DIR/.gitconfig"
    backup_if_real "$HOME_DIR/.gitignore_global"
}

# ── shell tools (modern CLI stack) ───────────────────────────────────
install_cli_stack() {
    log "Installing modern CLI stack..."

    # shell UX
    ensure zsh
    ensure git

    ensure fzf
    ensure zoxide

    # prompt
    if ! command -v starship &>/dev/null; then
        log "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # bottom (system monitor)
    if ! command -v btm &>/dev/null; then
        log "Installing bottom..."
        cargo install bottom || warn "cargo not ready yet (rustup step later)"
    fi
}

# ── dev tools ────────────────────────────────────────────────────────
install_dev_stack() {

    # Python toolchain
    if ! command -v uv &>/dev/null; then
        log "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    if command -v uv &>/dev/null; then
        uv tool install ruff || true
    fi

    # JS toolchain
    if ! command -v bun &>/dev/null; then
        log "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
    fi

    if command -v npm &>/dev/null; then
        npm install -g @biomejs/biome || true
    fi

    # Rust
    if ! command -v rustup &>/dev/null; then
        log "Installing rustup..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y
    fi

    # reload rust env
    export PATH="$HOME/.cargo/bin:$PATH"

    # DuckDB
    if ! command -v duckdb &>/dev/null; then
        log "Installing duckdb..."
        curl -L https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip -o /tmp/duckdb.zip
        unzip -o /tmp/duckdb.zip -d /tmp
        sudo mv /tmp/duckdb /usr/local/bin/duckdb || warn "duckdb install failed"
    fi
}

# ── stow dotfiles ────────────────────────────────────────────────────
apply_dotfiles() {
    log "Applying dotfiles with stow..."

    command -v stow &>/dev/null || die "stow missing"

    mkdir -p "$BACKUP_DIR"

    stow --dir="$DOTFILES" --target="$HOME_DIR" --restow zsh git bin
    ok "dotfiles linked"
}

# ── main ─────────────────────────────────────────────────────────────
main() {
    echo
    echo "🚀 dotfiles bootstrap (modern CLI edition)"
    echo

    ensure stow
    ensure git

    mkdir -p "$BACKUP_DIR"

    backup_existing

    install_cli_stack
    install_dev_stack

    apply_dotfiles

    echo
    ok "DONE"
    echo "backup: $BACKUP_DIR"
    echo "restart shell: exec zsh"
}

main "$@"