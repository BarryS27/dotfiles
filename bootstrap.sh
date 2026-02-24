#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"

echo "📥 Installing dotfiles..."

if [ ! -d "$DOTFILES" ]; then
    git clone https://github.com/BarryS27/dotfiles.git "$DOTFILES"
fi

ln -sf "$DOTFILES/bash/bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

echo "✅ Done. Restart shell."