#!/usr/bin/env bash
set -euo pipefail

#######################################
# 1. Paths & Variables
#######################################
REPO_URL="https://github.com/BarryS27/dotfiles.git"
HOME_DIR="$HOME"
DOTFILES_DIR="$HOME_DIR/dotfiles"
BACKUP_DIR="$HOME_DIR/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo "🛠️  Installing dotfiles for Bairu Song..."

#######################################
# 2. Utils
#######################################
log() {
    printf "➜ %s\n" "$1"
}

backup() {
    local target=$1
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$target")"
        mv "$target" "$BACKUP_DIR/$target"
        log "Backed up $target"
    fi
}

link() {
    local src=$1
    local dest=$2
    backup "$dest"
    ln -sfn "$src" "$dest"
    log "Linked $dest → $src"
}

#######################################
# 3. Clone / Update Repository
#######################################
if [ ! -d "$DOTFILES_DIR" ]; then
    log "Cloning dotfiles from $REPO_URL..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    log "Dotfiles directory already exists at $DOTFILES_DIR. Pulling latest..."
    git -C "$DOTFILES_DIR" pull origin main --quiet || log "⚠️  Could not pull latest updates."
fi

mkdir -p "$BACKUP_DIR"

#######################################
# 4. OS Detect
#######################################
case "$(uname -s)" in
    Darwin) OS="mac" ;;
    Linux)  OS="linux" ;;
    *)      OS="unknown" ;;
esac
log "Detected OS: $OS"

#######################################
# 5. Symlinks (Fixed Paths)
#######################################
log "Linking configs..."

link "$DOTFILES_DIR/.bashrc" "$HOME_DIR/.bashrc"
link "$DOTFILES_DIR/git/.gitignore_global" "$HOME_DIR/.gitignore_global"
link "$DOTFILES_DIR/git/.gitconfig" "$HOME_DIR/.gitconfig"

#######################################
# 6. Git Global Config
#######################################
log "Configuring git..."
git config --global core.excludesfile "$HOME_DIR/.gitignore_global"

#######################################
# 7. Platform Install
#######################################
if [[ -x "$DOTFILES_DIR/install/$OS.sh" ]]; then
    log "Running $OS setup..."
    bash "$DOTFILES_DIR/install/$OS.sh"
else
    log "No platform installer found. Skipping."
fi

#######################################
# 8. Codespaces
#######################################
if [[ -n "${CODESPACES:-}" ]]; then
    log "Configuring Codespaces..."
    SETTINGS="/home/vscode/.vscode-remote/data/Machine/settings.json"
    mkdir -p "$(dirname "$SETTINGS")"
    [[ -f $SETTINGS ]] || echo "{}" > "$SETTINGS"

    python3 <<EOF
import json
path = "$SETTINGS"
with open(path) as f:
    data = json.load(f)
data.update({
    "workbench.editor.labelFormat": "short",
    "window.title": "\${activeEditorMedium}\${separator}\${rootName}",
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000
})
with open(path, "w") as f:
    json.dump(data, f, indent=2)
EOF
    log "Codespaces ready"
fi

#######################################
# Done
#######################################
cat <<EOF

✨ Installation complete.

Backups saved in: $BACKUP_DIR
Reload shell:
  source ~/.bashrc
EOF