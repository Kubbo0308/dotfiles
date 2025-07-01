#!/bin/bash

# Oh-My-Zsh Plugins Installation Script
# This script installs external plugins listed in plugins.txt

set -e

DOTFILES_DIR="$HOME/.dotfiles"
OMZ_CUSTOM_DIR="$HOME/.oh-my-zsh/custom"
PLUGINS_FILE="$DOTFILES_DIR/oh-my-zsh-custom/plugins.txt"

echo "🔌 Installing Oh-My-Zsh custom plugins..."

# Check if oh-my-zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "❌ Oh-My-Zsh is not installed. Please install it first:"
    echo "sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    exit 1
fi

# Create custom plugins directory if it doesn't exist
mkdir -p "$OMZ_CUSTOM_DIR/plugins"

# Read plugins.txt and install each plugin
if [ -f "$PLUGINS_FILE" ]; then
    echo "📋 Reading plugins from $PLUGINS_FILE"
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
            continue
        fi
        
        # Extract plugin name from URL
        plugin_name=$(basename "$line" .git)
        plugin_dir="$OMZ_CUSTOM_DIR/plugins/$plugin_name"
        
        if [ -d "$plugin_dir" ]; then
            echo "🔄 Updating existing plugin: $plugin_name"
            cd "$plugin_dir"
            git pull
        else
            echo "📥 Installing new plugin: $plugin_name"
            git clone "$line" "$plugin_dir"
        fi
    done < "$PLUGINS_FILE"
else
    echo "⚠️  No plugins.txt file found at $PLUGINS_FILE"
fi

echo ""
echo "✅ Oh-My-Zsh plugins installation completed!"
echo "💡 Make sure to add these plugins to your .zshrc plugins array:"
echo "   plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)"