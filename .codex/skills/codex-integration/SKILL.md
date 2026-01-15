---
name: codex-integration
description: Guide for calling OpenAI Codex CLI from Claude Code. Use this skill when you need to leverage Codex's capabilities (GPT-5-codex model, web search, image analysis) from within Claude Code, or when building cross-agent workflows.
metadata:
  short-description: Claude Code to Codex integration
---

# Codex Integration from Claude Code

This skill provides patterns for calling OpenAI Codex CLI from Claude Code.

## Prerequisites

- Codex CLI installed: `npm install -g @openai/codex`
- Authentication: `codex login` or `OPENAI_API_KEY` environment variable
- Verify: `codex login status`

## Core Usage Patterns

### 1. Non-Interactive Batch Mode (Recommended)

```bash
# Basic execution
codex exec "your task description"

# With JSON output for parsing
codex exec "analyze this code" --json

# With full auto mode (no approval prompts)
codex exec "task" --full-auto

# Specific sandbox mode
codex exec "task" --sandbox read-only -a never
```

### 2. Piped Input

```bash
# From file
cat README.md | codex exec - "summarize this"

# From command output
git diff | codex exec - "review these changes"

# From here-doc
codex exec - <<'EOF'
Multi-line
task description
EOF
```

### 3. Image Analysis

```bash
# Single image
codex exec -i screenshot.png "describe what you see"

# Multiple images
codex exec -i before.png -i after.png "compare these"
```

### 4. Structured Output

```bash
# Save output to file
codex exec "task" --output-last-message result.txt

# JSON schema validation
codex exec "task" --output-schema schema.json
```

## Key Options Reference

| Option | Description |
|--------|-------------|
| `--json` | Output as JSONL for machine parsing |
| `--full-auto` | Skip approvals, workspace-write sandbox |
| `-a never` | Never ask for approval |
| `--sandbox read-only` | Read-only file access |
| `-m MODEL` | Specify model (default: gpt-5-codex) |
| `--search` | Enable web search |
| `-i FILE` | Attach image |

## Example Integration Script

```bash
#!/bin/bash
# codex-query.sh - Query Codex from Claude Code

PROMPT="$1"
OUTPUT=$(codex exec "$PROMPT" --json -a never --sandbox read-only 2>&1)

# Check for errors
if echo "$OUTPUT" | grep -q '"type":"error"'; then
    echo "Error: $(echo "$OUTPUT" | grep '"type":"error"' | head -1)"
    exit 1
fi

# Extract final message
echo "$OUTPUT" | grep '"type":"message"' | tail -1
```

## Session Management

```bash
# Resume last session
codex resume --last

# Resume specific session
codex resume <SESSION_ID>
```

## Troubleshooting

### Authentication Errors
```bash
# Check status
codex login status

# Re-authenticate with API key
codex login --api-key "$OPENAI_API_KEY"

# Or re-authenticate via ChatGPT OAuth
codex login
```

### MCP Server Timeouts
If MCP servers cause delays, disable them temporarily:
```bash
codex exec "task" -c 'mcp_servers={}'
```

## Best Practices

1. **Use `--json` for parsing** - Machine-readable output
2. **Set appropriate sandbox** - `read-only` for analysis, `workspace-write` for modifications
3. **Handle errors gracefully** - Check for `"type":"error"` in JSON output
4. **Timeout consideration** - Long tasks may need extended timeouts
5. **Token awareness** - Large prompts consume tokens

## Limitations

- Requires valid OpenAI authentication
- ChatGPT OAuth tokens may expire (use API key for reliability)
- No true interactive mode from automated scripts
- MCP server startup adds latency

