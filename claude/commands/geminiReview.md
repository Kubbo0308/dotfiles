---
allowed-tools: Bash(gemini:*)
description: Execute code reviews using Gemini CLI
argument-hint: <file-path> - file to review or review type
---

## Code Review with Gemini

**MUST reference `gemini` skill for CLI usage.**
**MUST reference `gemini:code-review` for review templates.**

Execute: `cat <file> | gemini -p "review this code"` (pipe via stdin, no `--file` flag)
