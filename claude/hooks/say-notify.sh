#!/usr/bin/env bash

# say-notify.sh - Context-aware voice notification for Claude Code
# Reads hook JSON from stdin, speaks repo/branch/task summary
# Usage: say-notify.sh <stop|notification>

set -uo pipefail

VOICE="Kyoko"
TYPE="${1:-stop}"

# Read hook JSON from stdin (non-blocking, with timeout)
HOOK_JSON=""
if read -t 1 -r HOOK_JSON; then
    # Read remaining lines if any
    while read -t 0.1 -r LINE; do
        HOOK_JSON="${HOOK_JSON}${LINE}"
    done
fi

# Gather git context
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Extract task summary from hook JSON
TASK_SUMMARY=""
if [ -n "$HOOK_JSON" ] && command -v jq &>/dev/null; then
    case "$TYPE" in
        stop)
            # last_assistant_message contains Claude's final response
            RAW=$(echo "$HOOK_JSON" | jq -r '.last_assistant_message // empty' 2>/dev/null)
            if [ -n "$RAW" ]; then
                # Take first line, truncate to 80 chars for speech
                TASK_SUMMARY=$(echo "$RAW" | head -1 | cut -c1-80)
            fi
            ;;
        notification)
            TASK_SUMMARY=$(echo "$HOOK_JSON" | jq -r '.message // empty' 2>/dev/null)
            ;;
    esac
fi

# Build message
MSG=""

# Repo and branch
if [ -n "$REPO_NAME" ] && [ -n "$BRANCH" ]; then
    MSG="${REPO_NAME}、${BRANCH}。"
elif [ -n "$REPO_NAME" ]; then
    MSG="${REPO_NAME}。"
fi

# Event type and task content
case "$TYPE" in
    stop)
        if [ -n "$TASK_SUMMARY" ]; then
            MSG="${MSG}${TASK_SUMMARY}"
        else
            MSG="${MSG}タスク完了"
        fi
        ;;
    notification)
        if [ -n "$TASK_SUMMARY" ]; then
            MSG="${MSG}${TASK_SUMMARY}"
        else
            MSG="${MSG}入力待ち"
        fi
        ;;
    *)
        MSG="${MSG}通知あり"
        ;;
esac

say -v "$VOICE" "$MSG" &
