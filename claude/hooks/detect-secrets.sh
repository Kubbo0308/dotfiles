#!/bin/bash
# Detect hardcoded secrets/credentials in file edits
INPUT=$(cat)
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Secret patterns (regex)
SECRET_PATTERNS=(
  'AKIA[0-9A-Z]{16}'                                    # AWS Access Key
  'sk-[a-zA-Z0-9]{20,}'                                 # OpenAI/Stripe secret key
  'ghp_[a-zA-Z0-9]{36}'                                 # GitHub personal access token
  'gho_[a-zA-Z0-9]{36}'                                 # GitHub OAuth token
  'github_pat_[a-zA-Z0-9_]{22,}'                        # GitHub fine-grained PAT
  'glpat-[a-zA-Z0-9_-]{20,}'                            # GitLab personal access token
  'xoxb-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24}'     # Slack bot token
  'xoxp-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24}'     # Slack user token
  '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----'          # Private keys
  'sk_live_[a-zA-Z0-9]{24,}'                            # Stripe live key
  'rk_live_[a-zA-Z0-9]{24,}'                            # Stripe restricted key
  'sq0atp-[a-zA-Z0-9_-]{22}'                            # Square access token
  'AIza[0-9A-Za-z_-]{35}'                               # Google API key
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qE -- "$pattern"; then
    echo "🔐 SECURITY: Potential secret/credential detected matching pattern '$pattern'. Please review the content before proceeding." >&2
    exit 2
  fi
done

exit 0
