#!/bin/bash
# ~/.codex/notify_macos.sh

# JSONから最後のエージェント発言を抽出
JSON_INPUT=${1:-"{}"}
if command -v jq >/dev/null 2>&1; then
  LAST_MESSAGE=$(printf '%s' "$JSON_INPUT" | jq -r '.["last-assistant-message"] // "Codex task completed"')
else
  LAST_MESSAGE="Codex task completed"
fi

# AppleScript用にバックスラッシュとダブルクォートをエスケープ
ESCAPED_MESSAGE=$(printf '%s' "$LAST_MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g')

if command -v osascript >/dev/null 2>&1; then
  if ! osascript -e "display notification \"$ESCAPED_MESSAGE\" with title \"Codex\""; then
    echo "Codex notification: $LAST_MESSAGE"
  fi
else
  echo "Codex notification: $LAST_MESSAGE"
fi
