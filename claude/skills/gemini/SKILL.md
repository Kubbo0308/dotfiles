---
name: gemini
description: Google Gemini CLI integration for web search, code review, and cross-agent collaboration. Use when you need web search via Gemini, code review with a second opinion, or real-time technical research.
---

# Gemini CLI Integration (v0.27.3+)

## When to Use

- **Web Search**: Gemini has built-in Google Search grounding
- **Code Review**: Pipe code via stdin for second opinion
- **Session Continuity**: Resume previous sessions with `-r`
- **Headless Automation**: `-p` flag for CI/CD and scripting

## Quick Start

```bash
# Web search (Google Search grounding built-in)
gemini -p "latest React 19 features 2026"

# Code review via stdin
cat src/main.ts | gemini -p "review this code for bugs and security issues"

# Git diff review
git diff | gemini -p "review this diff"

# JSON output for parsing
gemini -p "explain this error: ECONNREFUSED" -o json

# Auto-approve all actions
gemini -p "refactor this function" -y

# Resume previous session
gemini -r latest
gemini -r 5
```

## Key Points

- **No `WebSearch:` prefix needed** - Google Search grounding is built-in
- **Use `-p` for headless mode** (non-interactive, exits after response)
- **Use `-i` for prompt + interactive** (runs prompt then stays interactive)
- **Pipe stdin** with `-p` to pass file/diff content
- **`-r/--resume`** resumes sessions (interactive mode only, NOT with `-p`)
- **`-o json`** for structured output parsing
- **`-y/--yolo`** auto-accepts all tool actions

## Session Management

- **`-r/--resume`**: Resume by index or `"latest"` - **interactive mode only**
- **`--list-sessions`**: List sessions for current project
- **`-p` is stateless**: Each `-p` call is independent, no session continuity
- **Workaround**: Pass all context via stdin in each `-p` call
- **Workaround**: Use `-o json` to capture output, feed into next call
- Sessions stored in `~/.gemini/tmp/<project_hash>/chats/`
- Interactive commands: `/resume`, `/chat save <tag>`, `/chat resume <tag>`, `/compress`

## Common Patterns

```bash
# Technical research
gemini -p "Go error handling best practices idiomatic 2026"

# Error debugging
gemini -p "TypeError cannot read property of undefined React 19"

# Multi-file context via stdin
cat src/api.ts src/service.ts | gemini -p "review these files for consistency"

# Specific model
gemini -p "explain this architecture" -m gemini-2.5-flash

# Session management
gemini --list-sessions          # List all sessions
gemini -r latest                # Resume most recent
gemini --delete-session 3       # Delete session #3

# With additional workspace directories
gemini -p "analyze this project" --include-directories ../shared-lib
```

## References

- [cli-options.md](references/cli-options.md) - All CLI flags and subcommands
- [search-queries.md](references/search-queries.md) - Effective search patterns
- [code-review.md](references/code-review.md) - Code review patterns
