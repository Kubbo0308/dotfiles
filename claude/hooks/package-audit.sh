#!/bin/bash
# PostToolUse hook: Warn about security audit after package installation
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Single regex for all package install commands
INSTALL_RE='npm (install|i |add)|yarn add|pnpm (add|install)|bun (add|install)|pip3? install|go get'

if [[ "$COMMAND" =~ $INSTALL_RE ]]; then
  echo "📦 SECURITY REMINDER: Package installation detected." >&2
  echo "  → Run 'npm audit' / 'pip audit' / 'go vet' to check for vulnerabilities." >&2
  echo "  → Verify the package on its registry (downloads, maintainers, last update)." >&2
  echo "  → Check package.json 'scripts' for suspicious postinstall hooks." >&2
  exit 0
fi

# Detect git clone - warn about OSS backdoor risk
if [[ "$COMMAND" == *"git clone"* ]]; then
  echo "📦 SECURITY REMINDER: Repository cloned. Before using this code:" >&2
  echo "  → Run 'npm audit' if it has package.json" >&2
  echo "  → Check for suspicious packages in node_modules/" >&2
  echo "  → Review package.json 'scripts' for postinstall hooks" >&2
  echo "  → Scan for hardcoded external URLs in source code" >&2
  exit 0
fi

exit 0
