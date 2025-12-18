# gh CLI Commands Reference

Detailed reference for GitHub CLI commands used in PR review.

## PR View Commands

### Basic PR Information

```bash
# View PR in terminal
gh pr view NUMBER --repo OWNER/REPO

# Get specific fields as JSON
gh pr view NUMBER --repo OWNER/REPO --json title,body,author,state,baseRefName,headRefName,url

# Get all available fields
gh pr view NUMBER --repo OWNER/REPO --json title,body,author,state,baseRefName,headRefName,url,additions,deletions,changedFiles,commits,files,labels,reviews
```

### Available JSON Fields

| Field | Description |
|-------|-------------|
| `title` | PR title |
| `body` | PR description |
| `author` | Author information |
| `state` | PR state (OPEN, CLOSED, MERGED) |
| `baseRefName` | Target branch name |
| `headRefName` | Source branch name |
| `url` | PR URL |
| `additions` | Lines added |
| `deletions` | Lines deleted |
| `changedFiles` | Number of files changed |
| `commits` | Commit information |
| `files` | Changed files list |
| `labels` | PR labels |
| `reviews` | Review information |

## PR Diff Commands

### Get Full Diff

```bash
# Get diff output
gh pr diff NUMBER --repo OWNER/REPO

# Get diff for specific file
gh pr diff NUMBER --repo OWNER/REPO -- path/to/file.go

# Get diff with color (for terminal display)
gh pr diff NUMBER --repo OWNER/REPO --color=always
```

## API Commands

### Issues API (PR-level Comments)

```bash
# List all comments
gh api repos/OWNER/REPO/issues/NUMBER/comments

# With jq formatting
gh api repos/OWNER/REPO/issues/NUMBER/comments \
  --jq '.[] | {id, user: .user.login, created_at, body}'

# Post new comment
gh api repos/OWNER/REPO/issues/NUMBER/comments \
  --method POST \
  -f body="Comment text"
```

### Pulls API (Inline Comments)

```bash
# Get PR details including head SHA
gh api repos/OWNER/REPO/pulls/NUMBER

# Get head commit SHA only
gh api repos/OWNER/REPO/pulls/NUMBER --jq '.head.sha'

# List inline comments
gh api repos/OWNER/REPO/pulls/NUMBER/comments

# With jq formatting
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --jq '.[] | {id, user: .user.login, path, line, created_at, body, in_reply_to_id}'
```

### Posting Inline Comments

```bash
# Post inline comment on added/modified line
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --method POST \
  -f body="Comment text" \
  -f commit_id="abc123..." \
  -f path="src/main.go" \
  -F line=42 \
  -f side=RIGHT

# Post comment on deleted line
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --method POST \
  -f body="Comment text" \
  -f commit_id="abc123..." \
  -f path="src/main.go" \
  -F line=42 \
  -f side=LEFT
```

### Reply to Comments

```bash
# Reply to existing inline comment
gh api repos/OWNER/REPO/pulls/NUMBER/comments/COMMENT_ID/replies \
  --method POST \
  -f body="Reply text"
```

## PR Comment Command

Simpler alternative for PR-level comments:

```bash
# Post comment
gh pr comment NUMBER --repo OWNER/REPO --body "Comment text"

# Post comment from file
gh pr comment NUMBER --repo OWNER/REPO --body-file comment.md

# Edit last comment
gh pr comment NUMBER --repo OWNER/REPO --edit-last --body "Updated text"
```

## Common Options

| Option | Description |
|--------|-------------|
| `--repo OWNER/REPO` | Specify repository |
| `--json FIELDS` | Output specific fields as JSON |
| `--jq EXPRESSION` | Filter JSON output |
| `--method METHOD` | HTTP method (GET, POST, PUT, DELETE) |
| `-f key=value` | String field |
| `-F key=value` | Typed field (numbers, booleans) |
