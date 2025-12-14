#!/bin/bash

# Set up Codex MCP configuration symlink from dotfiles

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="${SCRIPT_DIR}/config.toml"
TARGET_DIR="${HOME}/.codex"
TARGET_FILE="${TARGET_DIR}/config.toml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Codex MCP config not found: $CONFIG_FILE" >&2
    echo "Generate it first with ${SCRIPT_DIR}/generate-config.sh" >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"

if [ -f "$TARGET_FILE" ] && [ ! -L "$TARGET_FILE" ]; then
    backup="${TARGET_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing Codex config to $backup"
    mv "$TARGET_FILE" "$backup"
elif [ -L "$TARGET_FILE" ]; then
    rm "$TARGET_FILE"
fi

ln -s "$CONFIG_FILE" "$TARGET_FILE"
echo "Linked $TARGET_FILE -> $CONFIG_FILE"
