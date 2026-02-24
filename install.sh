#!/usr/bin/env bash
set -euo pipefail

#######################################
# Paths
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
HOME_DIR="$HOME"

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo "🛠️  Installing dotfiles for Bairu Song..."
echo "📁 Dotfiles: $DOTFILES_DIR"
echo "📦 Backup:   $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"


#######################################
# Utils
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
# OS Detect
#######################################

case "$(uname -s)" in
    Darwin) OS="mac" ;;
    Linux)  OS="linux" ;;
    *)      OS="unknown" ;;
esac

log "Detected OS: $OS"


#######################################
# Symlinks
#######################################

log "Linking configs..."

link "$DOTFILES_DIR/.bashrc"          "$HOME_DIR/.bashrc"
link "$DOTFILES_DIR/.gitignore_global" "$HOME_DIR/.gitignore_global"
link "$DOTFILES_DIR/.gitconfig" "$HOME_DIR/.gitconfig"


#######################################
# Git Global Config
#######################################

log "Configuring git..."

git config --global core.excludesfile "$HOME_DIR/.gitignore_global"


#######################################
# Platform Install
#######################################

if [[ -x "$DOTFILES_DIR/install/$OS.sh" ]]; then
    log "Running $OS setup..."
    bash "$DOTFILES_DIR/install/$OS.sh"
else
    log "No platform installer found"
fi


#######################################
# Codespaces
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

Backups saved in:
$BACKUP_DIR

Reload shell:

  source ~/.bashrc

EOF