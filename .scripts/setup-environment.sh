#!/usr/bin/env bash

# Unified Environment Setup Script
# This script sets up the complete development environment in one go

set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "🚀 Starting unified environment setup..."
echo ""

# 1. Check if Homebrew is installed
echo "📦 Step 1/5: Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    echo "⚠️  Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew is already installed"
fi
echo ""

# 2. Install Homebrew packages
echo "🍺 Step 2/5: Installing Homebrew packages..."
if [[ -f "$DOTFILES_DIR/.homebrew/Brewfile" ]]; then
    brew bundle install --file="$DOTFILES_DIR/.homebrew/Brewfile"
    echo "✅ Homebrew packages installed"
else
    echo "⚠️  Brewfile not found, skipping Homebrew packages installation"
fi
echo ""

# 3. Install Oh-My-Zsh if not installed
echo "🎨 Step 3/5: Checking Oh-My-Zsh installation..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh-My-Zsh installed"
else
    echo "✅ Oh-My-Zsh is already installed"
fi
echo ""

# 4. Run the main dotfiles installation
echo "🔗 Step 4/5: Installing dotfiles and creating symlinks..."
"$DOTFILES_DIR/.scripts/install.sh"
echo ""

# 4.5. Apply macOS app defaults (machine-local, not covered by symlinks)
bash "$DOTFILES_DIR/.scripts/setup-macos-defaults.sh"
echo ""

# 5. Source zshrc to apply changes
echo "🔄 Step 5/5: Applying shell configuration..."
if [[ -f "$HOME/.zshrc" ]]; then
    # Note: We can't source in a bash script for zsh, so just inform the user
    echo "⚠️  Please run 'source ~/.zshrc' or restart your terminal to apply changes"
fi
echo ""

echo "✅ Environment setup completed successfully! 🎉"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Verify installations: brew list, nvim --version, etc."
echo "   3. Configure any API keys or tokens in ~/.dotfiles/claude/environments/.env.local"
echo ""
