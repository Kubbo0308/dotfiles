#!/bin/bash
# Block dangerous shell commands
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Critical: absolutely never allow
CRITICAL_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  'rm -rf $HOME'
  'rm -rf ${HOME}'
  ":(){ :|:& };:"
  "mkfs."
  "dd if=/dev/zero of=/dev"
  "dd if=/dev/random of=/dev"
  "> /dev/sda"
  "chmod -R 777 /"
)

for pattern in "${CRITICAL_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "🚫 CRITICAL: Blocked extremely dangerous command matching '$pattern'" >&2
    exit 2
  fi
done

# High risk patterns (regex)
HIGH_RISK_REGEX=(
  'curl\s.*\|\s*(ba)?sh'
  'wget\s.*\|\s*(ba)?sh'
  'chmod\s+777\b'
  'chmod\s+-R\s+777\b'
)

for regex in "${HIGH_RISK_REGEX[@]}"; do
  if echo "$COMMAND" | grep -qE "$regex"; then
    echo "⚠️ HIGH RISK: Blocked potentially dangerous command matching pattern '$regex'" >&2
    exit 2
  fi
done

exit 0
