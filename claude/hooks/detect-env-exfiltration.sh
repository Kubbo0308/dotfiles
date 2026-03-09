#!/bin/bash
# Detect environment variable exfiltration patterns in code
# Responsibility: env bulk access, env-to-network exfiltration, sensitive data logging
INPUT=$(cat)
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Pattern 1: Bulk env access (single grep call)
BULK_RE='JSON\.stringify\(process\.env\)|Object\.keys\(process\.env\)|Object\.entries\(process\.env\)|Object\.values\(process\.env\)|\.\.\.process\.env|env:\s*process\.env|Object\.assign\(\{\},\s*process\.env\)|os\.environ\.copy\(\)'

if echo "$CONTENT" | grep -qE -- "$BULK_RE"; then
  echo "🔐 SECURITY: Detected bulk environment variable access. Use specific env vars (e.g., process.env.NODE_ENV) instead of accessing the entire env object." >&2
  exit 2
fi

# Pattern 2: Env sent via network (single grep call)
EXFIL_RE='process\.env.*fetch\(|fetch\(.*process\.env|process\.env.*axios|axios.*process\.env|process\.env.*https?\.request|https?\.request.*process\.env|process\.env.*XMLHttpRequest|process\.env.*\.post\(|process\.env.*\.get\(|os\.environ.*urlopen|os\.environ.*requests\.|os\.environ.*urllib|ENV\[.*Net::HTTP'

if echo "$CONTENT" | grep -qE -- "$EXFIL_RE"; then
  echo "🚫 SECURITY: Detected potential environment variable exfiltration. Environment variables must NEVER be sent to external endpoints." >&2
  exit 2
fi

# Pattern 3: Suspicious logging of sensitive data (single grep call)
LEAK_RE='console\.log.*process\.env|logger\.\w+.*process\.env|log\.\w+.*process\.env|console\.log.*req\.body|console\.log.*res\.body'

if echo "$CONTENT" | grep -qE -- "$LEAK_RE"; then
  echo "⚠️ SECURITY: Detected logging of sensitive data. Avoid logging full request bodies or environment variables." >&2
  exit 2
fi

exit 0
