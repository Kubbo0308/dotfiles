---
name: commit-file-guard
description: "Guard against committing unintended files. Detects auto-generated files, unrelated changes, and files that should stay local. Used by pre-commit-checker."
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git ls-files:*)
  - Bash(git reset:*)
  - Glob
  - Grep
  - Read
---

# Commit File Guard Skill

Prevent unintended files from being committed. Integrated into `pre-commit-checker` agent.

## What This Guards Against

### 1. Auto-Generated Files (BLOCK by default)

Files that tools/editors create automatically and should NOT be committed:

| Pattern | Source | Action |
|---------|--------|--------|
| `*.sqlite`, `*.db` | Local databases | BLOCK |
| `*_cache.json`, `*cache*.json` | Tool caches | BLOCK |
| `*.log` | Log files | BLOCK |
| `shell_snapshots/` | Shell history | BLOCK |
| `backups/` | Backup directories | BLOCK |
| `logs/` | Log directories | BLOCK |
| `*.marker` | Tool markers | BLOCK |
| `*failed_events*.json` | Telemetry/crash data | BLOCK |
| `*.lock` (except package locks) | Lock files | BLOCK |
| `tasks/*/` | Claude task sessions | BLOCK |
| `mcp-needs-auth-cache.json` | MCP auth cache | BLOCK |
| `blocklist.json` | Plugin blocklists | BLOCK |
| `.env`, `.env.*` | Environment variables | BLOCK |
| `credentials*`, `*secret*`, `*token*` | Secrets | BLOCK |

### 2. Unrelated Changes (WARN)

Files modified but not related to the current task:

- Files in completely different directories from the main changes
- Config files that weren't intentionally modified
- Lock files updated as side-effects (e.g., `flake.lock`, `models_cache.json`)

### 3. Intentionally Created Files (ALLOW)

Files that SHOULD be committed:

- Files created via explicit user commands (`Write`, `Edit` tools)
- Files created by slash commands (e.g., `/add-feature`, skill creation)
- Source code files in the project's main directories
- Documentation files when documentation was the task
- Configuration files when configuration was the task

## Detection Algorithm

```
For each file in `git status` (staged + unstaged):

1. Check BLOCK list → Match? → Flag as BLOCKED
2. Check .gitignore patterns → Should be ignored? → Flag as BLOCKED
3. Check file extension against known auto-generated patterns → Flag as WARN
4. Check if file directory is related to other changed files → Unrelated? → Flag as WARN
5. Everything else → ALLOW
```

## Blocked File Patterns (Regex)

```
# Databases and caches
\.(sqlite|db|sqlite3)$
_cache\.json$
cache[^/]*\.json$

# Logs and telemetry
\.(log|logs)$
/logs?/
failed_events.*\.json$
/telemetry/

# Tool state
\.marker$
/shell_snapshots/
/backups/
mcp-needs-auth-cache\.json$
blocklist\.json$

# Session/task data
/tasks/[a-f0-9-]+/
/todos/[a-f0-9-]+

# Secrets
\.env(\..+)?$
credentials
secret
token
\.pem$
\.key$
```

## Package Lock Files (Special Handling)

These lock files are ALLOWED if their corresponding manifest was also changed:

| Lock File | Requires Change In |
|-----------|--------------------|
| `package-lock.json` | `package.json` |
| `yarn.lock` | `package.json` |
| `pnpm-lock.yaml` | `package.json` |
| `go.sum` | `go.mod` |
| `Gemfile.lock` | `Gemfile` |
| `poetry.lock` | `pyproject.toml` |
| `Cargo.lock` | `Cargo.toml` |
| `flake.lock` | `flake.nix` |
| `composer.lock` | `composer.json` |

If a lock file changed but its manifest did NOT change → Flag as WARN.

## Output Format

```
## 🛡️ Commit File Guard Report

### ❌ BLOCKED (must unstage before commit)
- `state_5.sqlite` — Auto-generated database file
- `claude/telemetry/failed_events.json` — Telemetry data

### ⚠️ WARNING (review before commit)
- `nix/flake.lock` — Lock file changed but `flake.nix` unchanged
- `codex/models_cache.json` — Cache file, likely auto-generated

### ✅ ALLOWED
- `claude/skills/pr-review-respond/SKILL.md` — Intentionally created
- `claude/commands/pr-review-respond.md` — Intentionally created
```

## Auto-Unstage Blocked Files

```bash
# Unstage blocked files automatically
git reset HEAD <blocked-file-1> <blocked-file-2> ...
```

## References

- Blocked patterns: [blocked-patterns.md](references/blocked-patterns.md)
- Related-change detection: [related-changes.md](references/related-changes.md)
