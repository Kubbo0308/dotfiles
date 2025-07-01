#!/bin/bash

# Dotfiles Installation Script
# This script creates symbolic links for dotfiles managed in ~/.dotfiles

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "🔗 Installing dotfiles from $DOTFILES_DIR"

# Create backup directory if needed
create_backup() {
    local file=$1
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        echo "📦 Backing up existing $file to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        mv "$file" "$BACKUP_DIR/"
    fi
}

# Create symbolic link safely
create_symlink() {
    local source=$1
    local target=$2
    
    if [ -L "$target" ]; then
        echo "🔄 Updating symlink: $target"
        rm "$target"
    elif [ -e "$target" ]; then
        create_backup "$target"
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    echo "🔗 Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: $DOTFILES_DIR does not exist"
    echo "Please clone your dotfiles repository first:"
    echo "git clone <your-dotfiles-repo> $DOTFILES_DIR"
    exit 1
fi

echo "📁 Found dotfiles directory: $DOTFILES_DIR"

# Install dotfiles
if [ -f "$DOTFILES_DIR/zshrc" ]; then
    create_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
fi

if [ -d "$DOTFILES_DIR/claude" ]; then
    create_symlink "$DOTFILES_DIR/claude" "$HOME/.claude"
fi

if [ -d "$DOTFILES_DIR/oh-my-zsh" ]; then
    create_symlink "$DOTFILES_DIR/oh-my-zsh" "$HOME/.oh-my-zsh"
fi

if [ -d "$DOTFILES_DIR/config/wezterm" ]; then
    create_symlink "$DOTFILES_DIR/config/wezterm" "$HOME/.config/wezterm"
fi

if [ -d "$DOTFILES_DIR/config/nvim" ]; then
    create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
fi

# Install oh-my-zsh custom configurations
if [ -d "$DOTFILES_DIR/oh-my-zsh-custom" ]; then
    echo "🔌 Setting up Oh-My-Zsh custom configurations..."
    
    # Create oh-my-zsh custom directory if it doesn't exist
    mkdir -p "$HOME/.oh-my-zsh/custom"
    
    # Copy custom themes
    if [ -d "$DOTFILES_DIR/oh-my-zsh-custom/themes" ]; then
        echo "🎨 Installing custom themes..."
        cp -r "$DOTFILES_DIR/oh-my-zsh-custom/themes/"* "$HOME/.oh-my-zsh/custom/themes/" 2>/dev/null || true
    fi
    
    # Copy custom zsh files
    if [ -f "$DOTFILES_DIR/oh-my-zsh-custom/example.zsh" ]; then
        echo "📝 Installing custom zsh files..."
        cp "$DOTFILES_DIR/oh-my-zsh-custom/"*.zsh "$HOME/.oh-my-zsh/custom/" 2>/dev/null || true
    fi
    
    # Install plugins from plugins.txt
    if [ -f "$DOTFILES_DIR/install-oh-my-zsh-plugins.sh" ]; then
        echo "📦 Installing Oh-My-Zsh plugins..."
        "$DOTFILES_DIR/install-oh-my-zsh-plugins.sh"
    fi
fi

echo "✅ Dotfiles installation completed!"

if [ -d "$BACKUP_DIR" ]; then
    echo "📦 Backup created at: $BACKUP_DIR"
    echo "You can safely remove it after confirming everything works correctly."
fi

echo ""
echo "🎉 Your dotfiles are now installed and managed by Git!"
echo "💡 To update: cd $DOTFILES_DIR && git pull"