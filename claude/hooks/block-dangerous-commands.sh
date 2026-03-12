#!/bin/bash
# Block dangerous shell commands
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' | tr '\n' ' ')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Critical: absolutely never allow (regex-based to prevent trivial obfuscation)
CRITICAL_RE='rm\s+-[a-zA-Z]*r[a-zA-Z]*f?\s+(\/|~|\$\{?HOME\}?)|:\(\)\{.*\|.*&\s*\}\s*;|mkfs\.|dd\s+if=\/dev\/(zero|random)\s+of=\/dev|>\s*\/dev\/sd[a-z]|chmod\s+-R\s+777\s+\/'

if echo "$COMMAND" | grep -qEi "$CRITICAL_RE"; then
  echo "🚫 CRITICAL: Blocked extremely dangerous command" >&2
  exit 2
fi

# High risk patterns (single combined grep call for efficiency)
HIGH_RISK_RE='curl\s.*\|\s*(ba)?sh|wget\s.*\|\s*(ba)?sh|chmod\s+777\b|chmod\s+-R\s+777\b|curl\s.*-d\s.*\$\(env\)|curl\s.*-d\s.*process\.env|wget\s.*--post-data.*env|nc\s+-e\s|ncat\s+-e\s|python3?\s+-c\s.*urllib|python3?\s+-c\s.*requests|python3?\s+-c\s.*socket|node\s+-e\s.*https?\.|node\s+-e\s.*fetch|node\s+-e\s.*process\.env|nslookup\s.*\$\(|dig\s.*\$\('

if echo "$COMMAND" | grep -qEi "$HIGH_RISK_RE"; then
  echo "⚠️ HIGH RISK: Blocked potentially dangerous command" >&2
  exit 2
fi

exit 0
