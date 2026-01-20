# Comment Workflow Reference

Complete workflow for posting and managing PR comments via gh CLI.

## Types of Comments

| Type | API Endpoint | Use Case |
|------|--------------|----------|
| PR-level | `/issues/NUMBER/comments` | General feedback, summaries |
| Inline | `/pulls/NUMBER/comments` | Line-specific feedback |
| Reply | `/pulls/NUMBER/comments/ID/replies` | Thread responses |

## Complete Review Workflow

### Step 1: Gather PR Information

```bash
# Get PR metadata
gh pr view NUMBER --repo OWNER/REPO --json title,body,author,state,baseRefName,headRefName,url

# Get head commit SHA (needed for inline comments)
COMMIT_SHA=$(gh api repos/OWNER/REPO/pulls/NUMBER --jq '.head.sha')
```

### Step 2: Get Diff with Line Numbers

```bash
# Process diff to show line numbers
gh pr diff NUMBER --repo OWNER/REPO | awk '
  /^diff --git/{match($0,/b\/(.+)$/,a);f=a[1];h=0;next}
  /^@@/{match($0,/\+([0-9]+)/,a);n=a[1];h=1;print"--- "f" ---";print;next}
  h{if(/^-/)print"     - "substr($0,2);else if(/^\+/){printf"%4d + %s\n",n,substr($0,2);n++}else if(/^ /){printf"%4d   %s\n",n,substr($0,2);n++}}
'
```

### Step 3: Check Existing Comments

```bash
# Get PR-level comments
gh api repos/OWNER/REPO/issues/NUMBER/comments \
  --jq '.[] | "[\(.user.login)] \(.body[0:100])..."'

# Get inline comments
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --jq '.[] | "\(.path):\(.line) [\(.user.login)] \(.body[0:80])..."'
```

### Step 4: Post Comments

#### PR-Level Comment (Summary)

```bash
gh pr comment NUMBER --repo OWNER/REPO --body "## Review Summary

### Observations
- Good test coverage
- Clear variable naming

### Suggestions
- Consider adding error handling in \`processData()\`
- The loop in line 45 could be optimized

LGTM with minor suggestions!"
```

#### Inline Comment (Specific Line)

```bash
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  --method POST \
  -f body="Consider using \`errors.Wrap()\` here for better context in stack traces." \
  -f commit_id="$COMMIT_SHA" \
  -f path="pkg/handler/user.go" \
  -F line=42 \
  -f side=RIGHT
```

#### Reply to Existing Comment

```bash
# First, find the comment ID from Step 3
COMMENT_ID=123456789

gh api repos/OWNER/REPO/pulls/NUMBER/comments/$COMMENT_ID/replies \
  --method POST \
  -f body="Good point! I'll update this in the next commit."
```

## Comment Best Practices

### Inline Comment Guidelines

| Do | Don't |
|----|-------|
| Target specific lines | Post vague comments |
| Include code suggestions | Just say "fix this" |
| Reference documentation | Assume knowledge |
| Be constructive | Be harsh |

### Comment Format Examples

#### Suggestion with Code

```markdown
Consider using a constant for this value:

\`\`\`go
const MaxRetries = 3
\`\`\`

This improves maintainability and makes the intent clearer.
```

#### Question

```markdown
Is this intentional? The timeout seems quite long at 30 seconds.

If so, could we add a comment explaining why?
```

#### Approval with Note

```markdown
LGTM! Just one minor suggestion:

Consider extracting lines 45-52 into a helper function for reusability.
```

## Batch Comment Script

For posting multiple inline comments:

```bash
#!/bin/bash
OWNER="owner"
REPO="repo"
PR_NUMBER=123
COMMIT_SHA=$(gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER --jq '.head.sha')

# Comments array: "path:line:message"
comments=(
  "src/main.go:42:Consider error handling here"
  "src/utils.go:15:This could be a constant"
  "tests/main_test.go:28:Great test case!"
)

for comment in "${comments[@]}"; do
  IFS=':' read -r path line body <<< "$comment"
  gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments \
    --method POST \
    -f body="$body" \
    -f commit_id="$COMMIT_SHA" \
    -f path="$path" \
    -F line="$line" \
    -f side=RIGHT
  echo "Posted comment on $path:$line"
done
```

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| 422 Unprocessable Entity | Invalid line number | Verify line exists in diff |
| 404 Not Found | Wrong commit SHA | Refresh commit SHA |
| 403 Forbidden | No write access | Check repository permissions |

### Validate Before Posting

```bash
# Check if file exists in PR
gh pr diff NUMBER --repo OWNER/REPO | grep -q "^diff --git.*b/$FILE_PATH"

# Verify line number is in diff
gh pr diff NUMBER --repo OWNER/REPO -- "$FILE_PATH" | grep -c "^+"
```

## Review States

When using the Reviews API for formal reviews:

```bash
# Submit a review
gh api repos/OWNER/REPO/pulls/NUMBER/reviews \
  --method POST \
  -f body="Overall looks good!" \
  -f event="APPROVE"  # or COMMENT, REQUEST_CHANGES
```

| Event | Description |
|-------|-------------|
| `APPROVE` | Approve the PR |
| `COMMENT` | General feedback only |
| `REQUEST_CHANGES` | Request changes before merge |
