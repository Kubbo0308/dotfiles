#!/usr/bin/env bash

# Sync configurations from $HOME to dotfiles repository
# This backs up current system configurations to the dotfiles repo

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

echo "📋 Syncing configurations from \$HOME to $DOTFILES_DIR..."
echo ""

# Files/directories to sync (relative to $HOME)
SYNC_ITEMS=(
    ".zshrc"
    ".config/nvim"
    ".config/wezterm"
    ".claude/settings.json"
    ".claude/CLAUDE.md"
    ".claude/commands"
    ".claude/agents"
)

copy_item() {
    local item=$1
    local src="$HOME/$item"
    local dst="$DOTFILES_DIR/$item"

    if [[ -d "$src" ]]; then
        echo "📁 Syncing directory: $item"
        mkdir -p "$dst"
        if command -v rsync >/dev/null 2>&1; then
            rsync -a --delete "$src/" "$dst/" 2>/dev/null || true
        else
            rm -rf "$dst"
            cp -R "$src" "$dst" 2>/dev/null || true
        fi
    elif [[ -f "$src" ]]; then
        echo "📄 Syncing file: $item"
        mkdir -p "$(dirname "$dst")"
        cp -f "$src" "$dst" 2>/dev/null || true
    else
        echo "⚠️  Not found: $item (skipping)"
    fi
}

# Sync each item
for item in "${SYNC_ITEMS[@]}"; do
    copy_item "$item"
done

# Update Brewfile with current installations
echo ""
echo "🍺 Updating Brewfile with current installations..."
if command -v brew &> /dev/null; then
    brew bundle dump --file="$DOTFILES_DIR/.homebrew/Brewfile" --force 2>/dev/null || true
    echo "✅ Brewfile updated"
else
    echo "⚠️  Homebrew not found, skipping Brewfile update"
fi

echo ""
echo "✅ Sync completed! Configurations saved to $DOTFILES_DIR"
echo ""
echo "📝 Next steps:"
echo "   1. Review changes: cd $DOTFILES_DIR && git status"
echo "   2. Commit changes: git add . && git commit -m 'update: sync configurations'"
echo "   3. Push to remote: git push"
echo ""
