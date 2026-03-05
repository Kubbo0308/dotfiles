#!/bin/bash
# Log agent/subagent/worktree activity
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "N/A"')
AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // "N/A"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "N/A"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"

echo "$TIMESTAMP | $EVENT | type=$AGENT_TYPE | agent=$AGENT_ID | session=$SESSION_ID" >> "$LOG_DIR/agent-activity.log"

exit 0
