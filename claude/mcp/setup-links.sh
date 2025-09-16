#!/bin/bash

# MCP Symbolic Link Setup Script
# Creates symbolic links from dotfiles to actual config locations

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to create symbolic link with backup
create_link() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    if [ ! -f "$source" ]; then
        echo -e "${YELLOW}Warning: Source file not found: $source${NC}"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        echo "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Backup existing file if it exists and is not a symlink
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing $name to: $backup${NC}"
        mv "$target" "$backup"
    fi
    
    # Remove existing symlink if it exists
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    # Create new symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Created symlink for $name${NC}"
    echo "  $target → $source"
}

echo "Setting up MCP configuration symbolic links..."
echo

# Check if configs have been generated
if [ ! -f "${SCRIPT_DIR}/claude-desktop.json" ]; then
    echo -e "${RED}Error: Configuration files not generated yet!${NC}"
    echo "Please run: ${SCRIPT_DIR}/generate-config.sh"
    exit 1
fi

# Claude Desktop config
CLAUDE_CONFIG_DIR="${HOME}/Library/Application Support/Claude"
create_link \
    "${SCRIPT_DIR}/claude-desktop.json" \
    "${CLAUDE_CONFIG_DIR}/claude_desktop_config.json" \
    "Claude Desktop MCP config"

# Cursor config (if it exists)
if [ -f "${SCRIPT_DIR}/cursor.json" ]; then
    CURSOR_CONFIG_DIR="${HOME}/.cursor"
    create_link \
        "${SCRIPT_DIR}/cursor.json" \
        "${CURSOR_CONFIG_DIR}/mcp.json" \
        "Cursor MCP config"
fi

echo
echo -e "${GREEN}Symbolic link setup complete!${NC}"
echo
echo "Note: You may need to restart Claude Desktop and/or Cursor for changes to take effect."