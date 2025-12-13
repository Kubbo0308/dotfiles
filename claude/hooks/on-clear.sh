#!/bin/bash
# Hook script executed after /clear command
# Injects instruction to run /sync-main as additional context

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "⚠️ IMPORTANT: This session was started with /clear. Please run /sync-main first to sync with main branch before starting any work. Ask the user if they want to proceed with sync-main."
  }
}
EOF
