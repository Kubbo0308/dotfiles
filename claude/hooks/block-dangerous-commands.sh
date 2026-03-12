#!/bin/bash
# Block dangerous shell commands
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' | tr '\n' ' ')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Critical: absolutely never allow (bash builtins, no subprocess)
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

# High risk patterns (single combined grep call for efficiency)
HIGH_RISK_RE='curl\s.*\|\s*(ba)?sh|wget\s.*\|\s*(ba)?sh|chmod\s+777\b|chmod\s+-R\s+777\b|curl\s.*-d\s.*\$\(env\)|curl\s.*-d\s.*process\.env|wget\s.*--post-data.*env|nc\s+-e\s|ncat\s+-e\s|python3?\s+-c\s.*urllib|python3?\s+-c\s.*requests|python3?\s+-c\s.*socket|node\s+-e\s.*https?\.|node\s+-e\s.*fetch|node\s+-e\s.*process\.env|nslookup\s.*\$\(|dig\s.*\$\('

if echo "$COMMAND" | grep -qE "$HIGH_RISK_RE"; then
  echo "⚠️ HIGH RISK: Blocked potentially dangerous command" >&2
  exit 2
fi

exit 0
