---
name: pr-review-respond
description: "Analyze PR review comments (excluding Approved), validate issues, auto-reply to dismiss non-issues, or fix code and re-request review for valid issues. Use when responding to PR review feedback."
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
---

# PR Review Respond Skill

Automatically process PR review comments, validate each issue, and take appropriate action:
- **Non-issues**: Reply with reasoning and resolve the conversation thread
- **Valid issues**: Fix code, commit, push, and re-request review

## Usage

```
/pr-review-respond [PR_NUMBER] [--repo OWNER/REPO]
```

- If `PR_NUMBER` is omitted, auto-detect from current branch
- If `--repo` is omitted, use current repository

## Workflow Overview

### Phase 1: Gather Review Data

```bash
# Auto-detect PR number from current branch
PR_NUMBER=$(gh pr view --json number --jq '.number' 2>/dev/null)
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

# Get PR metadata
gh pr view $PR_NUMBER --json title,body,author,state,headRefName,baseRefName,url,reviews

# Get all review comments (excluding APPROVED reviews)
gh api repos/$REPO/pulls/$PR_NUMBER/reviews \
  --jq '[.[] | select(.state != "APPROVED" and .state != "DISMISSED")] | .[] | {id, user: .user.login, state, body}'

# Get inline review comments (pending + submitted, not resolved)
gh api "repos/$REPO/pulls/$PR_NUMBER/comments" \
  --jq '[.[] | select(.in_reply_to_id == null)] | .[] | {id, user: .user.login, path, line, body, created_at, pull_request_review_id}'

# Get review threads to check resolved status
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 10) {
              nodes {
                id
                databaseId
                body
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -f owner="${REPO%%/*}" -f repo="${REPO##*/}" -F pr=$PR_NUMBER
```

### Phase 2: Analyze Each Comment

For each unresolved review comment:

1. **Read the relevant code** around the commented line
2. **Understand the reviewer's concern** - what issue are they raising?
3. **Classify the comment**:
   - `dismiss`: False positive, already handled, style preference not matching project conventions, or not applicable
   - `fix`: Valid bug, security issue, performance concern, or legitimate improvement

### Phase 3A: Dismiss Non-Issues

For comments classified as `dismiss`:

```bash
# Reply to the comment with reasoning
gh api repos/$REPO/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies \
  --method POST \
  -f body="$(cat <<'BODY'
This is not an issue because:

[Clear, specific reasoning why this comment can be dismissed]

- [Evidence from code/docs/conventions]
BODY
)"

# Resolve the thread via GraphQL
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="$THREAD_ID"
```

### Phase 3B: Fix Valid Issues

For comments classified as `fix`:

1. **Checkout the PR branch** (if not already on it)
2. **Make the code fix** using Edit tool
3. **Stage and commit** with descriptive message
4. **Push** to update the PR

```bash
# Ensure on the correct branch
gh pr checkout $PR_NUMBER

# After making fixes...
git add <fixed-files>
git commit -m "$(cat <<'EOF'
fix/ address review feedback

- [Description of fix 1]
- [Description of fix 2]

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"

git push
```

### Phase 4: Re-request Review (if fixes were made)

```bash
# Get reviewers who left non-approved reviews
REVIEWERS=$(gh api repos/$REPO/pulls/$PR_NUMBER/reviews \
  --jq '[.[] | select(.state != "APPROVED" and .state != "DISMISSED")] | [.[].user.login] | unique | join(",")')

# Re-request review from those reviewers
gh api repos/$REPO/pulls/$PR_NUMBER/requested_reviewers \
  --method POST \
  -f "reviewers[]=$REVIEWER"

# Or using gh pr edit
gh pr edit $PR_NUMBER --add-reviewer "$REVIEWERS"
```

### Phase 5: Summary Report

Output a summary of actions taken:

```
## PR Review Response Summary

### PR: #NUMBER - Title
### Repository: OWNER/REPO

### Dismissed Comments (X)
| Reviewer | File | Reason |
|----------|------|--------|
| bot-name | path/to/file.go:42 | False positive - already handled by... |

### Fixed Comments (Y)
| Reviewer | File | Fix Applied |
|----------|------|-------------|
| reviewer | path/to/file.go:15 | Added error handling for nil case |

### Actions Taken
- [x] Replied to X comments with dismissal reasoning
- [x] Resolved X conversation threads
- [x] Committed Y fixes (commit: abc1234)
- [x] Pushed to branch feature/xxx
- [x] Re-requested review from: reviewer1, reviewer2
```

## Decision Criteria

### When to Dismiss

| Scenario | Example |
|----------|---------|
| False positive from linter/bot | "unused variable" but variable is used in test |
| Style preference not in project conventions | "use camelCase" but project uses snake_case |
| Already handled elsewhere | "add nil check" but nil check exists upstream |
| Intentional design decision | "why not use interface?" with clear architectural reason |
| Outdated comment | Code was already changed in a subsequent commit |

### When to Fix

| Scenario | Example |
|----------|---------|
| Valid bug | Missing error handling, race condition |
| Security vulnerability | SQL injection, XSS, exposed secrets |
| Performance issue | N+1 query, unnecessary allocation |
| Missing test coverage | Untested edge case |
| Convention violation | Project has clear convention being violated |
| Correctness issue | Wrong logic, off-by-one error |

## Important Notes

- **NEVER dismiss valid security concerns** - always fix these
- **Ask the user** when classification is ambiguous
- **Preserve reviewer intent** - understand what they're actually asking for
- **Batch fixes** into a single commit when possible
- **Use pre-commit-checker** before committing fixes

## References

- Review analysis: [review-analysis.md](references/review-analysis.md)
- Response templates: [response-templates.md](references/response-templates.md)
- Fix workflow: [fix-workflow.md](references/fix-workflow.md)
