---
name: pr-review
description: "Provides comprehensive GitHub PR review capabilities using gh CLI. Use when reviewing pull requests, fetching PR information, viewing diffs with line numbers, and posting review comments."
allowed-tools:
  - Bash(gh pr view:*)
  - Bash(gh pr diff:*)
  - Bash(gh pr comment:*)
  - Bash(gh api:*)
  - Read
  - Grep
  - Glob
---

# PR Review Skill

Comprehensive GitHub PR review operations using `gh` CLI commands.

## Quick Start

1. Fetch PR metadata and description
2. Get diff with accurate line numbers
3. Retrieve existing comments
4. Post review comments (PR-level or inline)

## Core Commands

### PR Information

```bash
# Get PR metadata as JSON
gh pr view NUMBER --repo OWNER/REPO --json title,body,author,state,baseRefName,headRefName,url

# Get PR diff (raw)
gh pr diff NUMBER --repo OWNER/REPO
```

### Diff with Line Numbers

To get accurate line numbers matching GitHub's web interface:

```bash
gh pr diff NUMBER --repo OWNER/REPO | awk '
  /^diff --git/ {
    # Extract filename from diff header
    match($0, /b\/(.+)$/, arr)
    current_file = arr[1]
    in_hunk = 0
    next
  }
  /^@@/ {
    # Parse hunk header: @@ -old_start,old_count +new_start,new_count @@
    match($0, /\+([0-9]+)(,([0-9]+))?/, arr)
    new_line = arr[1]
    in_hunk = 1
    print "--- " current_file " ---"
    print $0
    next
  }
  in_hunk {
    if (/^-/) {
      # Deleted line (no line number in new file)
      print "     - " substr($0, 2)
    } else if (/^\+/) {
      # Added line
      printf "%4d + %s\n", new_line, substr($0, 2)
      new_line++
    } else if (/^ /) {
      # Context line
      printf "%4d   %s\n", new_line, substr($0, 2)
      new_line++
    }
  }
'
```

### Retrieve Comments

```bash
# Get PR-level comments (issue comments)
gh api repos/OWNER/REPO/issues/NUMBER/comments \
  --jq '.[] | {id, user: .user.login, created_at, body}'

# Get inline review comments
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --jq '.[] | {id, user: .user.login, path, line, created_at, body, in_reply_to_id}'
```

### Post Comments

```bash
# Post PR-level comment
gh pr comment NUMBER --repo OWNER/REPO --body "Your comment here"

# Get commit SHA for inline comments
gh api repos/OWNER/REPO/pulls/NUMBER --jq '.head.sha'

# Post inline comment on specific line
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --method POST \
  -f body="Comment text" \
  -f commit_id="COMMIT_SHA" \
  -f path="path/to/file.py" \
  -F line=15 \
  -f side=RIGHT

# Reply to existing comment
gh api repos/OWNER/REPO/pulls/NUMBER/comments/COMMENT_ID/replies \
  --method POST \
  -f body="Reply text"
```

## Command Reference

| Operation | Command |
|-----------|---------|
| View PR metadata | `gh pr view NUMBER --json ...` |
| Get diff | `gh pr diff NUMBER` |
| PR-level comments | `gh api repos/.../issues/NUMBER/comments` |
| Inline comments | `gh api repos/.../pulls/NUMBER/comments` |
| Post PR comment | `gh pr comment NUMBER --body "..."` |
| Post inline comment | `gh api repos/.../pulls/NUMBER/comments --method POST ...` |
| Reply to comment | `gh api repos/.../pulls/NUMBER/comments/ID/replies --method POST ...` |

## Inline Comment Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `body` | Comment text | Yes |
| `commit_id` | HEAD commit SHA | Yes |
| `path` | File path relative to repo root | Yes |
| `line` | Line number in the new file | Yes |
| `side` | `RIGHT` for additions, `LEFT` for deletions | Yes |

## Review Workflow

1. **Fetch PR info**: Get title, description, author, and branch info
2. **Get diff with line numbers**: Use the awk script for accurate line mapping
3. **Review existing comments**: Check what's already been discussed
4. **Analyze changes**: Review code for quality, security, performance
5. **Post comments**: Use inline comments for specific lines, PR-level for general feedback

## References

- gh CLI commands: [gh-commands.md](references/gh-commands.md)
- Diff processing: [diff-processing.md](references/diff-processing.md)
- Comment workflow: [comment-workflow.md](references/comment-workflow.md)
