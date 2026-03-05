#!/bin/bash
# Block editing sensitive/secret files (.env, keys, credentials, etc.)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

PROTECTED_PATTERNS=(
  ".env"
  ".env.local"
  ".env.production"
  ".env.staging"
  ".key"
  ".pem"
  ".p12"
  ".pfx"
  ".jks"
  ".keystore"
  "id_rsa"
  "id_ed25519"
  "id_ecdsa"
  "credentials.json"
  "service-account"
  ".secrets"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$BASENAME" == "$pattern" ]] || [[ "$BASENAME" == *"$pattern"* ]] || [[ "$FILE_PATH" == *"/$pattern" ]]; then
    echo "🛡️ Blocked: '$FILE_PATH' matches protected pattern '$pattern'. This file may contain secrets." >&2
    exit 2
  fi
done

exit 0
