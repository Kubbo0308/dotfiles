---
name: gemini
description: Google Gemini CLI integration for web search, code review, and cross-agent collaboration. Use when you need web search via Gemini, code review with a second opinion, or real-time technical research.
---

# Gemini CLI Integration

## When to Use

- **Web Search**: `gemini -p "WebSearch: query"` for technical research
- **Code Review**: `gemini --prompt="review" --file="path"` for second opinion
- **X (Twitter) Search**: `gemini -p "WebSearch: site:x.com query"`
- **Collaboration**: Pipe context to Gemini for cross-agent analysis

## Quick Start

```bash
# Web search
gemini -p "WebSearch: React 19 new features 2026"

# Code review
gemini --prompt="Review this code for bugs and security issues" --file="src/main.ts"

# Pipe context
git diff | gemini -p "Review this diff for issues"

# Here-doc for complex prompts
gemini <<EOF
Analyze the following architecture and suggest improvements:
$(cat docs/architecture.md)
EOF
```

## Key Points

- **Use `-p` flag** for single-line prompts
- **Use `--file`** to pass files for review
- **Use heredoc** (`<<EOF`) for complex multi-line prompts
- **Add year** to searches for latest results (e.g., "2026")
- **MUST verify X (Twitter) results** - see web-search skill

## Common Patterns

```bash
# Technical documentation search
gemini -p "WebSearch: TypeScript 5.x strict mode best practices 2026"

# Error debugging
gemini -p "WebSearch: TypeError cannot read property of undefined React 19"

# X (Twitter) developer insights
gemini -p "WebSearch: site:x.com react team announcement 2026"

# Multi-file review
gemini --prompt="Review these files for consistency" --file="src/a.ts" --file="src/b.ts"

# Git diff review
git diff HEAD~1 | gemini -p "Review this diff. Focus on bugs and security."

# Collaboration mode
PROMPT="Review: $(cat src/main.ts)"
gemini <<EOF
$PROMPT
Focus on: security, performance, readability
EOF
```

## References

- [cli-options.md](references/cli-options.md) - All CLI options and usage
- [search-queries.md](references/search-queries.md) - Effective search patterns
- [code-review.md](references/code-review.md) - Code review templates and best practices
