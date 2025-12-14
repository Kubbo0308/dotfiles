---
name: code-review
description: "Performs comprehensive code review focusing on quality, security, performance, and maintainability. Use when reviewing code changes, pull requests, diffs, or when asked to review specific files or functions."
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git show:*)
  - Bash(gh pr view:*)
  - Bash(gh pr diff:*)
---

# Code Review Skill

Analyze code for quality, security, performance, and maintainability issues.

## Quick Start

1. Gather context (purpose, affected files, related tests)
2. Review using the four categories below
3. Output findings in structured format

## Review Categories

| Category | Focus |
|----------|-------|
| Quality | Readability, naming, DRY, error handling |
| Security | Input validation, injection, auth, secrets |
| Performance | Algorithm efficiency, queries, caching |
| Maintainability | Complexity, docs, tests, modularity |

## Output Format

```markdown
## Code Review Summary

### Critical Issues
[Security vulnerabilities, data loss risks]

### Major Issues
[Logic errors, performance problems]

### Minor Issues
[Style, naming, documentation]

### Positive Observations
[Good practices observed]
```

## References

- Review checklist: [checklist.md](checklist.md)
- Language-specific guidelines: [language-guidelines.md](language-guidelines.md)
- Security review details: [security-review.md](security-review.md)

