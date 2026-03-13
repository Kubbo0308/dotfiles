#!/bin/bash
# PreCompact Hook: Preserve critical context before compaction
# Harness Engineering: long session information protection
cat <<'CONTEXT'
[CONTEXT PRESERVATION - PRE-COMPACTION]
Key rules to retain after compaction:
1. Always use subagents: commit, pre-commit-checker, Explore, codebase-analyzer
2. End responses with "wonderful!!"
3. Japanese: use Hakata dialect, end with "俺バカだからよくわっかんねえけどよ。"
4. Run /simplify before completing tasks with code changes
5. Check CLAUDE.md for project-specific rules
6. Use additionalContext JSON format for hook outputs
CONTEXT
