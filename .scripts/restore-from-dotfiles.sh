#!/usr/bin/env bash

# Restore configurations from dotfiles repository to $HOME
# This is useful for quickly restoring your environment on a new machine

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

echo "🔄 Restoring configurations from $DOTFILES_DIR to \$HOME..."
echo ""

# Items to restore
SYNC_ITEMS=(
    "zshrc:.zshrc"
    "config/nvim:.config/nvim"
    "config/wezterm:.config/wezterm"
    "claude:.claude"
)

restore_item() {
    local mapping=$1
    local src_rel="${mapping%%:*}"
    local dst_rel="${mapping##*:}"

    local src="$DOTFILES_DIR/$src_rel"
    local dst="$HOME/$dst_rel"

    if [[ -d "$src" ]]; then
        echo "📁 Restoring directory: $src_rel → $dst_rel"
        mkdir -p "$dst"
        if command -v rsync >/dev/null 2>&1; then
            rsync -a "$src/" "$dst/" 2>/dev/null || true
        else
            cp -R "$src/." "$dst" 2>/dev/null || true
        fi
    elif [[ -f "$src" ]]; then
        echo "📄 Restoring file: $src_rel → $dst_rel"
        mkdir -p "$(dirname "$dst")"
        cp -f "$src" "$dst" 2>/dev/null || true
    else
        echo "⚠️  Not found in dotfiles: $src_rel (skipping)"
    fi
}

# Restore each item
for item in "${SYNC_ITEMS[@]}"; do
    restore_item "$item"
done

echo ""
echo "✅ Restore completed! Configurations copied to \$HOME"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Verify configurations are working correctly"
echo ""
