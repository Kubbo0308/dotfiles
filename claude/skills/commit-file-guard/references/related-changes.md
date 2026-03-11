# Related Change Detection Reference

How to determine if a changed file is related to the current task.

## Relatedness Heuristic

### Same Directory Cluster

Files in the same directory or sibling directories are likely related:

```
Changed files:
  claude/skills/pr-review-respond/SKILL.md        ← main change
  claude/skills/pr-review-respond/references/...   ← related (same skill)
  claude/commands/pr-review-respond.md             ← related (matching name)

  nix/flake.lock                                   ← UNRELATED
  codex/models_cache.json                          ← UNRELATED
```

### Name Matching

Files with matching base names across directories are related:

```
pr-review-respond.md (command) ↔ pr-review-respond/ (skill) → RELATED
```

### Common Change Patterns

| Change Type | Related Files |
|-------------|--------------|
| New skill | `skills/<name>/SKILL.md`, `skills/<name>/references/*`, `commands/<name>.md` |
| New feature | Source files, test files, config changes |
| Bug fix | Source file, test file |
| Config update | Config file, possibly lock file |
| Documentation | `.md` files in `docs/` |

## Detection Algorithm

```python
def is_related(file, main_changes):
    # 1. Same directory tree
    for main in main_changes:
        if share_parent_directory(file, main, depth=2):
            return True

    # 2. Name matching
    base_name = extract_base_name(file)
    for main in main_changes:
        if base_name in main:
            return True

    # 3. Import/reference analysis (for code files)
    if is_code_file(file):
        for main in main_changes:
            if file_references(main, file) or file_references(file, main):
                return True

    return False
```

## Practical Implementation

### Step 1: Identify Main Changes

The "main changes" are files that were intentionally created/modified. Determine by:
- Files created via Write/Edit tools in the current session
- Files mentioned in the task description
- Source code files (not config, cache, or lock files)

### Step 2: Group by Directory

```bash
# Get all changed file directories
git status --porcelain | awk '{print $2}' | xargs -I{} dirname {} | sort -u
```

### Step 3: Flag Outliers

Files whose directory doesn't overlap with any main change directory at depth 2 are flagged as WARN.

```bash
# Example: if main changes are in claude/skills/ and claude/commands/
# Then nix/flake.lock is an outlier (different top-level directory)
# But claude/agents/pre-commit-checker.md would be related
```

## User Confirmation for Warnings

When files are flagged as WARN, present them to the user:

```
⚠️ These files are not obviously related to your current changes:

1. nix/flake.lock — Lock file (flake.nix unchanged)
2. codex/models_cache.json — Appears to be a cache file

Include in commit? (Select files to keep, or skip all)
```
