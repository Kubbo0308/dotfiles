#!/bin/bash
# PostToolUse Hook: Auto-lint after Write|Edit
# Harness Engineering: fastest feedback loop (ms-level)
source "$(dirname "$0")/lib/file-guard.sh"

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"
ISSUES=""

case "$EXT" in
  go)
    if command -v gofmt &>/dev/null; then
      HASH_BEFORE=$(md5 -q "$FILE_PATH" 2>/dev/null || md5sum "$FILE_PATH" 2>/dev/null | cut -d' ' -f1)
      gofmt -w "$FILE_PATH" 2>/dev/null
      HASH_AFTER=$(md5 -q "$FILE_PATH" 2>/dev/null || md5sum "$FILE_PATH" 2>/dev/null | cut -d' ' -f1)
      if [ "$HASH_BEFORE" != "$HASH_AFTER" ]; then
        ISSUES="gofmt: auto-formatted $FILE_PATH"
      fi
    fi
    if command -v golangci-lint &>/dev/null; then
      LINT_OUT=$(golangci-lint run --fix "$FILE_PATH" 2>&1 | head -10)
      if [ -n "$LINT_OUT" ]; then
        ISSUES="${ISSUES:+$ISSUES | }golangci-lint: $LINT_OUT"
      fi
    fi
    ;;
  ts|tsx|js|jsx|json|css)
    if command -v biome &>/dev/null; then
      LINT_OUT=$(biome check --write "$FILE_PATH" 2>&1 | tail -5)
      if echo "$LINT_OUT" | grep -q "Fixed\|error"; then
        ISSUES="biome: $LINT_OUT"
      fi
    fi
    ;;
  sh|bash)
    if command -v shellcheck &>/dev/null; then
      LINT_OUT=$(shellcheck "$FILE_PATH" 2>&1 | head -10)
      if [ -n "$LINT_OUT" ]; then
        ISSUES="shellcheck: $LINT_OUT"
      fi
    fi
    ;;
  nix)
    if command -v nixfmt &>/dev/null; then
      HASH_BEFORE=$(md5 -q "$FILE_PATH" 2>/dev/null || md5sum "$FILE_PATH" 2>/dev/null | cut -d' ' -f1)
      nixfmt "$FILE_PATH" 2>/dev/null
      HASH_AFTER=$(md5 -q "$FILE_PATH" 2>/dev/null || md5sum "$FILE_PATH" 2>/dev/null | cut -d' ' -f1)
      if [ "$HASH_BEFORE" != "$HASH_AFTER" ]; then
        ISSUES="nixfmt: auto-formatted $FILE_PATH"
      fi
    fi
    ;;
esac

if [ -n "$ISSUES" ]; then
  jq -n --arg msg "LINT: $ISSUES" '{hookSpecificOutput:{additionalContext:$msg}}'
fi

exit 0
