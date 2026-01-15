---
name: codex-integration
description: Call OpenAI Codex CLI from Claude Code for cross-agent collaboration. Use when you need GPT-5-codex capabilities, web search via Codex, image analysis with OpenAI vision, or to get a second opinion from a different AI model.
---

# Codex Integration from Claude Code

Integrate OpenAI Codex CLI into Claude Code workflows for cross-agent collaboration.

## When to Use Codex

1. **Web Search** - Codex has built-in web search (`--search`)
2. **Image Analysis** - Codex can analyze images with GPT-5-codex
3. **Second Opinion** - Get different perspective on complex problems
4. **OpenAI-specific features** - Leverage GPT-5-codex model capabilities

## Quick Reference

### Basic Execution

```bash
# Simple query (non-interactive)
codex exec "your question or task" -a never --sandbox read-only

# With JSON output for parsing
codex exec "task" --json -a never --sandbox read-only
```

### Web Search

```bash
codex exec --search "what are the latest changes in React 19?" -a never --sandbox read-only
```

### Image Analysis

```bash
codex exec -i screenshot.png "describe this UI" -a never --sandbox read-only
```

### Piped Input

```bash
# Analyze code
cat file.ts | codex exec - "review this code" -a never --sandbox read-only

# Analyze diff
git diff | codex exec - "what changed?" -a never --sandbox read-only
```

## Key Options

| Option | Description |
|--------|-------------|
| `-a never` | No approval prompts (required for automation) |
| `--sandbox read-only` | Safe read-only mode |
| `--json` | Machine-parseable JSONL output |
| `--search` | Enable web search |
| `-i FILE` | Attach image for analysis |
| `--full-auto` | Equivalent to `-a on-failure --sandbox workspace-write` |

## Error Handling

Check for authentication:
```bash
codex login status
```

Common errors:
- **401 Unauthorized**: Token expired, run `codex login`
- **MCP timeout**: Disable MCP with `-c 'mcp_servers={}'`

## Example: Cross-Agent Review

```bash
# Get Codex's opinion on code changes
git diff HEAD~1 | codex exec - "Review these changes for potential issues" \
  -a never --sandbox read-only 2>&1 | grep -v "^{" | head -50
```

## Limitations

- Requires valid OpenAI auth (API key or ChatGPT login)
- ChatGPT OAuth tokens expire frequently
- Not truly interactive from scripts (batch mode only)
- MCP servers add startup latency

## Best Practice

For reliable automation, use API key authentication:
```bash
export OPENAI_API_KEY="your-key"
codex exec "task" -a never --sandbox read-only
```

