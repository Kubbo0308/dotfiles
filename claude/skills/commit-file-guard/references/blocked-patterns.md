# Blocked Patterns Reference

Comprehensive list of file patterns that should never be committed.

## Detection Script

Use this script to check for blocked files in git status:

```bash
# Get all files that would be committed (staged + untracked being added)
git status --porcelain | awk '{print $2}' | while read -r file; do
  blocked=false
  reason=""

  case "$file" in
    # Databases
    *.sqlite|*.sqlite3|*.db)
      blocked=true; reason="Database file" ;;

    # Caches
    *_cache.json|*cache*.json)
      blocked=true; reason="Cache file" ;;

    # Logs
    *.log|*/logs/*|*/log/*)
      blocked=true; reason="Log file" ;;

    # Telemetry
    */telemetry/*|*failed_events*)
      blocked=true; reason="Telemetry data" ;;

    # Tool markers
    *.marker)
      blocked=true; reason="Tool marker file" ;;

    # Shell snapshots
    */shell_snapshots/*)
      blocked=true; reason="Shell snapshot" ;;

    # Backups
    */backups/*)
      blocked=true; reason="Backup file" ;;

    # MCP/auth caches
    *mcp-needs-auth-cache*|*blocklist.json)
      blocked=true; reason="Auth/plugin cache" ;;

    # Task/session data
    */tasks/[a-f0-9]*)
      blocked=true; reason="Task session data" ;;

    # Secrets
    .env|.env.*|*credentials*|*.pem|*.key)
      blocked=true; reason="Secret/credential file" ;;

    # IDE/editor files
    .idea/*|.vscode/settings.json|*.swp|*.swo|*~)
      blocked=true; reason="Editor temporary file" ;;

    # OS files
    .DS_Store|Thumbs.db)
      blocked=true; reason="OS metadata file" ;;
  esac

  if [ "$blocked" = true ]; then
    echo "BLOCKED: $file — $reason"
  fi
done
```

## Lock File Validation Script

```bash
# Check if lock files have corresponding manifest changes
check_lock_file() {
  local lock_file="$1"
  local manifest=""

  case "$lock_file" in
    */package-lock.json|*/yarn.lock|*/pnpm-lock.yaml)
      manifest="$(dirname "$lock_file")/package.json" ;;
    */go.sum)
      manifest="$(dirname "$lock_file")/go.mod" ;;
    */flake.lock)
      manifest="$(dirname "$lock_file")/flake.nix" ;;
    */Gemfile.lock)
      manifest="$(dirname "$lock_file")/Gemfile" ;;
    */poetry.lock)
      manifest="$(dirname "$lock_file")/pyproject.toml" ;;
    */Cargo.lock)
      manifest="$(dirname "$lock_file")/Cargo.toml" ;;
    */composer.lock)
      manifest="$(dirname "$lock_file")/composer.json" ;;
    *)
      return 0 ;;  # Not a known lock file
  esac

  # Check if manifest is also in changed files
  if ! git status --porcelain | grep -q "$manifest"; then
    echo "WARN: $lock_file changed but $manifest did not"
    return 1
  fi
  return 0
}
```

## Directory-Based Blocking

Some entire directories should be blocked:

| Directory | Reason |
|-----------|--------|
| `node_modules/` | Dependencies (should be in .gitignore) |
| `.next/` | Next.js build output |
| `dist/` | Build output (unless intentional) |
| `build/` | Build output (unless intentional) |
| `__pycache__/` | Python cache |
| `.pytest_cache/` | Pytest cache |
| `vendor/` | Go vendor (depends on project) |
| `coverage/` | Test coverage reports |
| `.turbo/` | Turborepo cache |

## Dotfiles-Specific Patterns

For the dotfiles repository specifically:

| Pattern | Reason |
|---------|--------|
| `claude/tasks/*/` | Claude session task data |
| `claude/backups/` | Claude config backups |
| `claude/logs/` | Claude operation logs |
| `claude/telemetry/` | Claude telemetry |
| `claude/mcp-needs-auth-cache.json` | MCP auth cache |
| `claude/plugins/blocklist.json` | Plugin blocklist |
| `codex/shell_snapshots/` | Codex shell history |
| `codex/state_*.sqlite` | Codex state database |
| `codex/models_cache.json` | Codex model cache |
| `codex/skills/.system/*.marker` | Codex skill markers |
