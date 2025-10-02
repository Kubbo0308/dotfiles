#!/bin/bash

# Dotfiles Uninstallation Script
# This script removes symbolic links and optionally restores backups

set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "🗑️  Uninstalling dotfiles symlinks"

# Remove symlink if it exists and points to dotfiles
remove_symlink() {
    local target=$1
    local expected_source=$2
    
    if [ -L "$target" ]; then
        local current_source=$(readlink "$target")
        if [[ "$current_source" == "$expected_source" ]]; then
            echo "🔗 Removing symlink: $target"
            rm "$target"
        else
            echo "⚠️  Warning: $target points to $current_source, not $expected_source. Skipping."
        fi
    elif [ -e "$target" ]; then
        echo "📁 $target is not a symlink. Leaving as is."
    else
        echo "❌ $target does not exist."
    fi
}

# Remove dotfiles symlinks
remove_symlink "$HOME/.zshrc" "$DOTFILES_DIR/zshrc"
remove_symlink "$HOME/.claude" "$DOTFILES_DIR/claude"
remove_symlink "$HOME/.oh-my-zsh" "$DOTFILES_DIR/oh-my-zsh"
remove_symlink "$HOME/.config/wezterm" "$DOTFILES_DIR/config/wezterm"
remove_symlink "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim"

echo ""
echo "✅ Dotfiles symlinks have been removed!"
echo ""
echo "🔍 Looking for backup directories..."

# List available backups
BACKUP_DIRS=($(find "$HOME" -maxdepth 1 -name ".dotfiles_backup_*" -type d 2>/dev/null))

if [ ${#BACKUP_DIRS[@]} -eq 0 ]; then
    echo "📦 No backup directories found."
else
    echo "📦 Found backup directories:"
    for backup_dir in "${BACKUP_DIRS[@]}"; do
        echo "   - $backup_dir"
    done
    
    echo ""
    echo "💡 To restore from a backup:"
    echo "   1. Choose a backup directory"
    echo "   2. Copy files back manually, e.g.:"
    echo "      cp -r /path/to/backup/.zshrc ~/"
    echo "      cp -r /path/to/backup/.claude ~/"
    echo ""
    echo "⚠️  Note: You may want to remove the dotfiles directory:"
    echo "      rm -rf $DOTFILES_DIR"
fi

echo ""
echo "🎉 Uninstallation completed!"