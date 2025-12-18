---
name: go-testing
description: "Generates comprehensive Go tests using project-standard table-driven pattern with mock struct and want functions. Use when writing or reviewing Go test code."
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
---

# Go Testing Skill

Generate and review Go tests following project standards and idiomatic patterns.

## Quick Start

1. Analyze function signature and dependencies
2. Identify mock requirements
3. Design test cases (normal, semi-normal, abnormal)
4. Generate test code using project-standard pattern

## Project-Standard Pattern

**Always use this structure for tests with mocks:**

```go
func TestFunctionName(t *testing.T) {
	type mock struct {
		dependency1 *MockDependency1
	}
	tests := []struct {
		name string
		args InputType
		mock func(m mock)
		want func(t *testing.T, got OutputType, err error)
	}{
		// test cases
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			ctrl := gomock.NewController(t)
			m := mock{dependency1: NewMockDependency1(ctrl)}
			tt.mock(m)
			// execute and assert
			tt.want(t, result, err)
		})
	}
}
```

## Test Struct Fields

| Field | Purpose |
|-------|---------|
| `name string` | Test case description |
| `args/cmd` | Input parameters |
| `mock func(m mock)` | Mock setup function |
| `want func(t, got, err)` | Assertion function |

## Mandatory Rules

- **t.Parallel()** in every subtest
- **No defer ctrl.Finish()** - gomock handles cleanup
- **Mock struct initialization** inside loop
- **Use shared error variables** from test setup file

## Test Categories

| Category | Examples |
|----------|----------|
| **Normal** | Valid inputs, happy path |
| **Semi-Normal** | Edge cases, boundary conditions |
| **Abnormal** | Invalid inputs, dependency errors |

## Context7 Integration

| Library | Context7 ID | Use Case |
|---------|-------------|----------|
| Go testing | `/golang/go` | Standard testing package |
| gomock | `/uber-go/mock` | Mock generation |
| testify | `/stretchr/testify` | Assertions and mocking |

## References

- Table-driven tests: [table-driven-tests.md](references/table-driven-tests.md)
- Mocking best practices: [mocking-guidelines.md](references/mocking-guidelines.md)
- Test organization: [test-organization.md](references/test-organization.md)
