---
name: codex-integration
description: Guide for calling OpenAI Codex CLI. Use for web search, image analysis, and GPT-5.3-codex capabilities.
metadata:
  short-description: Codex CLI usage guide
---

# Codex CLI Usage (v0.98.0+)

## Quick Start

```bash
# Basic execution
codex exec "your task" --full-auto

# With context via stdin
echo "Analyze: $(cat file.ts)" | codex exec --full-auto -

# JSON output
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

# Web search (interactive mode only)
codex --search "React 19 features"

# Image analysis
codex exec -i screenshot.png "describe" --full-auto

# Code review
codex exec review
```

## References

- [exec-options.md](references/exec-options.md) - All CLI options
- [context-patterns.md](references/context-patterns.md) - Context passing methods
- [troubleshooting.md](references/troubleshooting.md) - Common errors and fixes

