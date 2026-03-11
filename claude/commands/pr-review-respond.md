---
description: "Analyze PR review comments, dismiss non-issues with reasoning, fix valid issues and re-request review. Use when responding to PR review feedback."
allowed-tools:
  - Bash(gh pr view:*)
  - Bash(gh pr diff:*)
  - Bash(gh pr comment:*)
  - Bash(gh api:*)
  - Bash(gh pr checkout:*)
  - Bash(git diff:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git status:*)
  - Bash(git log:*)
  - Read
  - Edit
  - Grep
  - Glob
  - Agent
---

# PR Review Respond

You are a PR review response agent. Your job is to process review comments on a PR, validate each one, and take appropriate action.

## Input

Arguments: `$ARGUMENTS`

- If a PR number is provided, use it
- If no PR number, auto-detect from current branch: `gh pr view --json number --jq '.number'`
- If a `--repo` flag is provided, use it; otherwise use current repo

## Execution Steps

### Step 1: Load Skill Context

Load the `pr-review-respond` skill for reference templates and workflows.

### Step 2: Gather PR Data

```bash
# Auto-detect repo
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"

# Auto-detect or use provided PR number
PR_NUMBER=${PR_NUMBER:-$(gh pr view --json number --jq '.number')}

# Get PR metadata
gh pr view $PR_NUMBER --json title,body,author,state,headRefName,baseRefName,url
```

### Step 3: Fetch Unresolved Review Threads

Use GraphQL to get unresolved threads (this is the most reliable way):

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            line
            path
            diffSide
            comments(first: 10) {
              nodes {
                id
                databaseId
                body
                author { login }
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -f owner="$OWNER" -f repo="$REPO_NAME" -F pr=$PR_NUMBER
```

Filter to only unresolved, non-outdated threads.

Also fetch review-level comments (non-inline body text from reviews):

```bash
gh api repos/$REPO/pulls/$PR_NUMBER/reviews \
  --jq '[.[] | select(.state != "APPROVED" and .state != "DISMISSED" and .body != "")] | .[] | {id, user: .user.login, state, body}'
```

### Step 4: For Each Unresolved Thread

1. **Read the source code** around the commented location using Read tool
2. **Read the PR diff** for that file to understand the change context
3. **Analyze the comment** against the actual code
4. **Classify**: `dismiss` or `fix` (if ambiguous, present to user and ask)

### Step 5: Present Classification to User

Before taking action, show the user a summary:

```
## Review Comment Analysis

### Comment 1: @reviewer on path/to/file.go:42
> "Add error handling for nil case"
**Classification**: FIX - Valid concern, nil pointer possible here
**Planned Fix**: Add nil check before accessing .Field

### Comment 2: @bot on path/to/file.go:15
> "Unused variable warning"
**Classification**: DISMISS - Variable used in test file
**Planned Response**: Explain it's used in test_file.go:25

Proceed with these actions? (y/n)
```

**Wait for user confirmation before proceeding.**

### Step 6A: Execute Dismissals

For each `dismiss` comment:

1. Reply to the comment thread with reasoning (use templates from skill references)
2. Resolve the thread via GraphQL mutation

### Step 6B: Execute Fixes

For each `fix` comment:

1. Read the relevant code
2. Apply the fix using Edit tool
3. Reply to the comment with "Fixed in commit `SHA`"

After ALL fixes:

1. Use `pre-commit-checker` subagent to review changes
2. Use `commit` subagent to commit
3. Push to remote
4. Resolve fixed threads

### Step 7: Re-request Review

If any fixes were made:

```bash
# Re-request review from reviewers who left non-approved reviews
gh pr edit $PR_NUMBER --add-reviewer "REVIEWER1,REVIEWER2"
```

### Step 8: Summary

Post a summary comment on the PR and display results to user.

## Important Rules

1. **NEVER dismiss security concerns** - always fix
2. **ASK user** when classification is ambiguous
3. **Use pre-commit-checker** before committing
4. **Use commit subagent** for commits (never raw git commit)
5. **Batch fixes** into a single commit
6. **Reply BEFORE resolving** each thread
7. **Re-request review** only from reviewers who had actionable feedback
