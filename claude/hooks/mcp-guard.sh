#!/bin/bash
# Block MCP filesystem writes to sensitive directories
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Normalize path to prevent traversal bypass
FILE_PATH=$(realpath "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")

# Sensitive directories that should not be modified via MCP
BLOCKED_DIRS=(
  "/.ssh"
  "/.aws"
  "/.gnupg"
  "/.kube"
  "/.docker"
  "/.npmrc"
  "/.pypirc"
  "/etc/"
  "/.config/gcloud"
)

for dir in "${BLOCKED_DIRS[@]}"; do
  if [[ "$FILE_PATH" == *"$dir"* ]]; then
    echo "🛡️ MCP BLOCKED: Cannot write to sensitive directory '$dir'" >&2
    exit 2
  fi
done

# Also check for secret file patterns
BASENAME=$(basename "$FILE_PATH")
SECRET_FILES=(".env" ".key" ".pem" "credentials" "id_rsa" "id_ed25519")

for pattern in "${SECRET_FILES[@]}"; do
  if [[ "$BASENAME" == *"$pattern"* ]]; then
    echo "🛡️ MCP BLOCKED: Cannot write to sensitive file '$BASENAME'" >&2
    exit 2
  fi
done

exit 0
