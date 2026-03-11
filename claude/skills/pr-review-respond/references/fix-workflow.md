# Fix Workflow Reference

Step-by-step process for fixing valid review issues and re-requesting review.

## Pre-Fix Setup

### Ensure Correct Branch

```bash
# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
PR_BRANCH=$(gh pr view $PR_NUMBER --json headRefName --jq '.headRefName')

if [ "$CURRENT_BRANCH" != "$PR_BRANCH" ]; then
  gh pr checkout $PR_NUMBER
fi

# Ensure up-to-date
git pull origin $PR_BRANCH
```

### Verify Clean Working Tree

```bash
git status --porcelain
# If dirty, stash or warn user
```

## Fix Process

### Step 1: Plan All Fixes

Before making any changes, plan all fixes together:

```
Fix Plan:
1. path/to/file1.go:42 - Add nil check (Comment #123)
2. path/to/file2.go:15 - Improve error message (Comment #456)
3. path/to/file3.go:88 - Add test case (Comment #789)
```

### Step 2: Apply Fixes

Use the Edit tool for each fix. Read the file first, then apply targeted edits.

**Important**: Make minimal, focused changes. Do not refactor surrounding code.

### Step 3: Verify Fixes

```bash
# Check what changed
git diff

# Run tests if applicable
go test ./...
# or
npm test
```

### Step 4: Stage and Commit

```bash
# Stage only the fixed files
git add path/to/file1.go path/to/file2.go path/to/file3.go

# Commit with descriptive message
git commit -m "$(cat <<'EOF'
fix/ address review feedback

- Add nil check in handler.go for edge case
- Improve error message clarity in service.go
- Add test case for boundary condition

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

### Step 5: Push

```bash
git push origin $PR_BRANCH
```

## Post-Fix: Reply and Resolve

For each fixed comment:

```bash
# Get the new commit SHA
NEW_COMMIT=$(git rev-parse --short HEAD)

# Reply to each fixed comment
gh api repos/$REPO/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies \
  --method POST \
  -f body="Fixed in commit \`$NEW_COMMIT\`. [Brief description of fix]"
```

Then resolve the thread:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="$THREAD_ID"
```

## Re-request Review

### Identify Reviewers

```bash
# Get reviewers who left actionable reviews
REVIEWERS=$(gh api repos/$REPO/pulls/$PR_NUMBER/reviews \
  --jq '[.[] | select(.state == "CHANGES_REQUESTED" or .state == "COMMENTED")] | [.[].user.login] | unique | .[]')
```

### Request Re-review

```bash
# Using gh pr edit (simplest)
for REVIEWER in $REVIEWERS; do
  gh pr edit $PR_NUMBER --add-reviewer "$REVIEWER"
done

# Or using API directly (for programmatic control)
for REVIEWER in $REVIEWERS; do
  gh api repos/$REPO/pulls/$PR_NUMBER/requested_reviewers \
    --method POST \
    --input - <<EOF
{
  "reviewers": ["$REVIEWER"]
}
EOF
done
```

### Post Summary Comment

After all fixes and re-requests:

```bash
gh pr comment $PR_NUMBER --body "$(cat <<'EOF'
All review feedback has been addressed in commit `$NEW_COMMIT`:

- Fixed: [list of fixes]
- Dismissed (with reasoning): [list of dismissals]

Re-requested review from: @reviewer1, @reviewer2

Please re-review at your convenience.
EOF
)"
```

## Error Recovery

### Push Rejected

```bash
# If push is rejected due to remote changes
git pull --rebase origin $PR_BRANCH
git push origin $PR_BRANCH
```

### Merge Conflicts After Fix

```bash
# If conflicts exist with base branch
git fetch origin
git rebase origin/$BASE_BRANCH
# Resolve conflicts manually
git rebase --continue
git push origin $PR_BRANCH --force-with-lease
```

### Test Failures After Fix

1. Do NOT push if tests fail
2. Fix the test failures first
3. Include test fixes in the same commit
4. Verify all tests pass before pushing

## Checklist

```
□ On correct PR branch
□ Branch is up-to-date
□ All fixes applied
□ Tests pass (if applicable)
□ Changes committed with descriptive message
□ Pushed to remote
□ Replied to each fixed comment with fix reference
□ Resolved all addressed threads
□ Re-requested review from relevant reviewers
□ Posted summary comment on PR
```
