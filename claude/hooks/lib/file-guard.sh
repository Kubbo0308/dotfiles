#!/bin/bash
# Shared helper: parse stdin from Claude Code hooks and extract FILE_PATH/BASENAME
# Sourced by hooks that need file path from tool_input
HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
BASENAME=$(basename "$FILE_PATH" 2>/dev/null || echo "")
