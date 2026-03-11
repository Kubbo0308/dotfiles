# Review Analysis Reference

How to analyze and classify PR review comments.

## Comment Sources

### Bot Reviews

Common CI/CD bots that leave review comments:

| Bot | Type | Typical Comments |
|-----|------|-----------------|
| `github-actions[bot]` | CI/CD | Build failures, test results |
| `codecov[bot]` | Coverage | Coverage decrease warnings |
| `dependabot[bot]` | Dependencies | Security advisories |
| `sonarcloud[bot]` | Code quality | Code smells, vulnerabilities |
| `renovate[bot]` | Dependencies | Update suggestions |
| Custom bots | Various | Project-specific checks |

### Human Reviews

Review states from GitHub API:

| State | Meaning | Action |
|-------|---------|--------|
| `APPROVED` | Reviewer approved | **Skip** - no action needed |
| `CHANGES_REQUESTED` | Reviewer wants changes | Analyze each comment |
| `COMMENTED` | General feedback | Analyze each comment |
| `DISMISSED` | Review was dismissed | **Skip** - already handled |
| `PENDING` | Draft review | May not be visible yet |

## Analysis Process

### Step 1: Fetch All Review Data

```bash
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"

# Get reviews (non-approved, non-dismissed)
gh api repos/$REPO/pulls/$PR_NUMBER/reviews \
  --jq '[.[] | select(.state == "CHANGES_REQUESTED" or .state == "COMMENTED")] | .[] | {
    review_id: .id,
    reviewer: .user.login,
    state: .state,
    body: .body
  }'

# Get unresolved review threads with GraphQL
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
' -f owner="$OWNER" -f repo="$REPO_NAME" -F pr=$PR_NUMBER \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)'
```

### Step 2: Read Context Around Each Comment

For each comment, read the relevant source code:

```bash
# Get the file content at the commented line
FILE_PATH="path/to/file.go"
LINE=42

# Read surrounding context (10 lines before and after)
sed -n "$((LINE-10)),$((LINE+10))p" "$FILE_PATH"
```

### Step 3: Classify Each Comment

Classification decision tree:

```
Is the comment about a security vulnerability?
├── Yes → ALWAYS FIX
└── No
    ├── Is it a valid bug (incorrect logic, missing error handling)?
    │   ├── Yes → FIX
    │   └── No
    │       ├── Is it a project convention violation?
    │       │   ├── Yes, clear convention exists → FIX
    │       │   └── No, just preference → DISMISS
    │       ├── Is it a false positive from a bot/linter?
    │       │   ├── Yes → DISMISS with explanation
    │       │   └── No → Continue analysis
    │       ├── Is the code already correct but reviewer misunderstood?
    │       │   ├── Yes → DISMISS with clarification
    │       │   └── No → FIX
    │       └── Is it ambiguous?
    │           └── ASK USER for guidance
```

### Step 4: Batch Classification

Group comments by classification:

```
DISMISS:
  - Comment #123 (bot false positive)
  - Comment #456 (already handled)

FIX:
  - Comment #789 (valid bug - missing nil check)
  - Comment #012 (convention violation)

ASK_USER:
  - Comment #345 (ambiguous - could go either way)
```

## Bot-Specific Analysis

### Codecov Bot

```
Coverage decreased by 2.5%
```

**Analysis**: Check if the decrease is from:
- New untested code → FIX (add tests)
- Refactoring that moved code → DISMISS (coverage will normalize)
- Deleted tests → FIX (restore or replace tests)

### SonarCloud Bot

```
Code smell: Cognitive complexity of method X is 18 (max allowed 15)
```

**Analysis**: Check if:
- Method genuinely needs simplification → FIX
- Complexity is inherent to the algorithm → DISMISS with reasoning

### GitHub Actions Bot

```
Build failed: type error in file.ts:42
```

**Analysis**: Always FIX build failures.

## Edge Cases

| Situation | Action |
|-----------|--------|
| Reviewer left "nit:" prefix | Low priority, consider DISMISS unless trivial to fix |
| Comment is a question, not a request | Reply with answer, DISMISS |
| Comment on deleted code | Likely outdated, verify and DISMISS |
| Multiple reviewers disagree | ASK USER for guidance |
| Comment references external issue | Verify issue, then classify |
