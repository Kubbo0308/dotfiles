---
name: go-testing
description: "Generates comprehensive Go tests following best practices including table-driven tests, explicit mock typing, and proper test organization. Use when writing or reviewing Go test code."
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
---

# Go Testing Skill

Generate and review Go tests following industry best practices and idiomatic patterns.

## Quick Start

1. Read the implementation code before writing tests
2. Use table-driven tests for multiple scenarios
3. Avoid `gomock.Any()` - use explicit types
4. Run tests with `-race` flag to detect race conditions

## Core Principles

| Principle | Description |
|-----------|-------------|
| Table-Driven Tests | Use structured test cases with named scenarios |
| Explicit Mocking | Specify exact types instead of `gomock.Any()` |
| Parallel Execution | Use `t.Parallel()` for isolated tests |
| Coverage Analysis | Monitor with `go test -cover` |
| Race Detection | Always test with `-race` flag |

## Output Format

```markdown
## Test Review Summary

### Issues Found
[Missing test cases, improper mocking, race conditions]

### Recommendations
[Table-driven refactoring, explicit type usage]

### Coverage Report
[Uncovered code paths, suggested test cases]
```

## References

- Table-driven tests: [table-driven-tests.md](table-driven-tests.md)
- Mocking best practices: [mocking-guidelines.md](mocking-guidelines.md)
- Test organization: [test-organization.md](test-organization.md)

