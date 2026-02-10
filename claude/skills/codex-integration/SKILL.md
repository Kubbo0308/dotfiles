---
name: codex-integration
description: Call OpenAI Codex CLI from Claude Code for cross-agent collaboration. Use when you need GPT-5.3-codex capabilities, web search via Codex, image analysis with OpenAI vision, or to get a second opinion from a different AI model.
---

# Codex Integration from Claude Code

## When to Use

- **Web Search**: `codex --search "query"` (interactive only)
- **Image Analysis**: `codex exec -i image.png "describe" --full-auto`
- **Second Opinion**: Get GPT-5.3-codex perspective
- **Code Review**: `codex exec review`

## Quick Start (v0.98.0+)

```bash
# Basic execution
codex exec "your task" --full-auto

# With context via stdin
echo "Code: $(cat file.ts)" | codex exec --full-auto -

# JSON output for parsing
codex exec "task" --json --full-auto
```

## Key Points

- **Use `--full-auto`** for automation (no approvals)
- **`exec` has no `-a` option** - use `--full-auto` instead
- **Pass context via stdin** with `-` marker
- **Options before `-`** when using stdin

## Common Patterns

```bash
# File analysis
cat src/main.ts | codex exec --full-auto -

# Git diff review
git diff | codex exec --full-auto -

# Web search (interactive mode only, not in exec)
codex --search "React 19 features"

# Image comparison
codex exec -i before.png -i after.png "compare" --full-auto
```

## References

- [exec-options.md](references/exec-options.md) - All CLI options
- [context-patterns.md](references/context-patterns.md) - Context passing methods
- [troubleshooting.md](references/troubleshooting.md) - Common errors and fixes

