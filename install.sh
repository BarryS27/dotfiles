#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%F-%T)"

log()  { printf '  \033[34m➜\033[0m  %s\n' "$1"; }
ok()   { printf '  \033[32m✔\033[0m  %s\n' "$1"; }
warn() { printf '  \033[33m⚠\033[0m  %s\n' "$1"; }
die()  { printf '  \033[31m✘\033[0m  %s\n' "$1" >&2; exit 1; }

# ── Backup any real files that would be overwritten ────────────────────
backup_existing() {
    local managed=(
        "$HOME/.zshrc"    "$HOME/.zprofile"      "$HOME/.bashrc"
        "$HOME/.gitconfig" "$HOME/.gitignore_global"
        "$HOME/aliases.zsh" "$HOME/functions.zsh" "$HOME/fzf.zsh"
    )
    for f in "${managed[@]}"; do
        [[ -e "$f" && ! -L "$f" ]] || continue
        local dest="$BACKUP_DIR/${f#"$HOME/"}"
        mkdir -p "$(dirname "$dest")"
        mv "$f" "$dest"
        warn "backed up: $f"
    done
}

# ── macOS — let Homebrew handle everything ─────────────────────────────
install_macos() {
    command -v brew &>/dev/null || die "Homebrew not found — install from https://brew.sh"
    log "Running brew bundle..."
    brew bundle --no-lock --file="$DOTFILES/Brewfile"
}

# ── Linux / Codespaces ────────────────────────────────────────────────
install_linux() {
    log "Installing base packages..."
    sudo apt-get update -qq
    sudo apt-get install -y stow zsh git fzf ripgrep curl unzip

    if ! command -v uv &>/dev/null; then
        log "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if ! command -v bun &>/dev/null; then
        log "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
        export PATH="$HOME/.bun/bin:$PATH"
    fi

    if ! command -v zoxide &>/dev/null; then
        log "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    command -v uv  &>/dev/null && uv tool install ruff --quiet       || true
    command -v bun &>/dev/null && bun add -g @biomejs/biome --silent  || true
}

# ── Link dotfiles ──────────────────────────────────────────────────────
apply_dotfiles() {
    log "Linking dotfiles..."

    if command -v dotter &>/dev/null; then
        dotter deploy --force
    else
        command -v stow &>/dev/null || die "stow not found"
        stow --dir="$DOTFILES" --target="$HOME" --restow zsh git bin

        mkdir -p "$HOME/.config"/{bottom,ghostty,caddy}
        local cfgs=(
            ".config/bottom.toml:$HOME/.config/bottom/bottom.toml"
            ".config/config.ghostty:$HOME/.config/ghostty/config"
            ".config/Caddyfile:$HOME/.config/caddy/Caddyfile"
            ".config/starship.toml:$HOME/.config/starship.toml"
        )
        for pair in "${cfgs[@]}"; do
            local src="${pair%%:*}" dst="${pair##*:}"
            [[ -f "$DOTFILES/$src" ]] && ln -sf "$DOTFILES/$src" "$dst"
        done
    fi

    ok "dotfiles linked"
}

# ── Main ───────────────────────────────────────────────────────────────
main() {
    echo
    echo "🚀 dotfiles bootstrap"
    echo

    mkdir -p "$BACKUP_DIR"
    backup_existing

    case "$(uname -s)" in
        Darwin) install_macos ;;
        Linux)  install_linux ;;
        *)      die "Unsupported OS" ;;
    esac

    apply_dotfiles

    echo
    ok "Done — restart shell: exec zsh"
    [[ -d "$BACKUP_DIR" ]] && echo "   backup: $BACKUP_DIR"
}

main "$@"
