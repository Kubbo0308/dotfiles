#!/bin/bash
# Detect hardcoded secrets/credentials in file edits
# Responsibility: static credential patterns ONLY (tokens, API keys, private keys)
INPUT=$(cat)
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Combined secret pattern (single grep call for efficiency)
SECRET_RE='AKIA[0-9A-Z]{16}|sk-ant-[a-zA-Z0-9_-]{20,}|sk-proj-[a-zA-Z0-9_-]{20,}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{22,}|glpat-[a-zA-Z0-9_-]{20,}|xoxb-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24}|xoxp-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24}|-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----|sk_live_[a-zA-Z0-9]{24,}|rk_live_[a-zA-Z0-9]{24,}|sq0atp-[a-zA-Z0-9_-]{22}|AIza[0-9A-Za-z_-]{35}|hf_[a-zA-Z0-9]{34,}|ya29\.[a-zA-Z0-9._-]{68,}'

if echo "$CONTENT" | grep -qE -- "$SECRET_RE"; then
  MATCHED=$(echo "$CONTENT" | grep -oE -- "$SECRET_RE" | head -1)
  echo "🔐 SECURITY: Potential secret/credential detected: '${MATCHED:0:20}...'. Please review the content before proceeding." >&2
  exit 2
fi

exit 0
