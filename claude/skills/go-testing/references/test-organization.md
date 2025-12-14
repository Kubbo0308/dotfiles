# Test Organization in Go

Properly organized tests are easier to maintain, debug, and extend.

## File Naming Conventions

```
mypackage/
├── user.go           # Implementation
├── user_test.go      # Unit tests (same package)
├── user_internal_test.go  # Internal tests (mypackage)
└── user_integration_test.go  # Integration tests
```

## Test Function Naming

```go
// Pattern: Test<FunctionName>_<Scenario>
func TestCreateUser_WithValidData(t *testing.T) {}
func TestCreateUser_WithDuplicateEmail(t *testing.T) {}
func TestCreateUser_WithEmptyName(t *testing.T) {}

// For methods: Test<Type>_<Method>_<Scenario>
func TestUserService_Create_Success(t *testing.T) {}
func TestUserService_Create_ValidationError(t *testing.T) {}
```

## Using testify/assert

The testify library simplifies assertions:

```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestUser(t *testing.T) {
    user, err := CreateUser("John", "john@example.com")

    // assert continues on failure
    assert.NoError(t, err)
    assert.Equal(t, "John", user.Name)
    assert.NotEmpty(t, user.ID)

    // require stops on failure (use for critical checks)
    require.NotNil(t, user, "user must not be nil")
}
```

### Common Assert Functions

```go
// Equality
assert.Equal(t, expected, actual)
assert.NotEqual(t, expected, actual)
assert.EqualValues(t, expected, actual)  // type-insensitive

// Nil checks
assert.Nil(t, value)
assert.NotNil(t, value)

// Boolean
assert.True(t, condition)
assert.False(t, condition)

// Error handling
assert.NoError(t, err)
assert.Error(t, err)
assert.ErrorIs(t, err, ErrNotFound)
assert.ErrorContains(t, err, "not found")

// Collections
assert.Len(t, slice, 3)
assert.Empty(t, slice)
assert.Contains(t, slice, element)
assert.ElementsMatch(t, expected, actual)  // order-independent

// Time
assert.WithinDuration(t, expected, actual, delta)
```

## Test Coverage

### Running Coverage

```bash
# Basic coverage
go test -cover ./...

# Generate coverage profile
go test -coverprofile=coverage.out ./...

# View HTML report
go tool cover -html=coverage.out

# Coverage by function
go tool cover -func=coverage.out
```

### Coverage in CI

```bash
# Fail if coverage is below threshold
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep total | awk '{print $3}' | \
    sed 's/%//' | \
    awk '{if ($1 < 80) exit 1}'
```

## Race Detection

**Always run tests with race detection in CI:**

```bash
go test -race ./...
```

### Common Race Condition Patterns

```go
// BAD: Shared variable without synchronization
func TestCounter(t *testing.T) {
    counter := 0
    var wg sync.WaitGroup

    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter++  // RACE CONDITION!
        }()
    }
    wg.Wait()
}

// GOOD: Use atomic or mutex
func TestCounter(t *testing.T) {
    var counter int64
    var wg sync.WaitGroup

    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            atomic.AddInt64(&counter, 1)
        }()
    }
    wg.Wait()
}
```

## Test Helpers

### Setup and Teardown

```go
func TestMain(m *testing.M) {
    // Setup before all tests
    setup()

    code := m.Run()

    // Teardown after all tests
    teardown()

    os.Exit(code)
}

// Per-test cleanup
func TestWithCleanup(t *testing.T) {
    tempFile := createTempFile(t)
    t.Cleanup(func() {
        os.Remove(tempFile)
    })

    // test logic
}
```

### Test Helpers with `t.Helper()`

```go
func assertEqual(t *testing.T, expected, actual interface{}) {
    t.Helper()  // marks this as helper - error points to caller
    if expected != actual {
        t.Errorf("expected %v, got %v", expected, actual)
    }
}

func createTestUser(t *testing.T) *User {
    t.Helper()
    user, err := NewUser("test", "test@example.com")
    if err != nil {
        t.Fatalf("failed to create test user: %v", err)
    }
    return user
}
```

## Build Tags for Test Types

```go
//go:build integration
// +build integration

package mypackage

func TestDatabaseIntegration(t *testing.T) {
    // Only runs with: go test -tags=integration ./...
}
```

## Golden Files Pattern

For complex output comparison:

```go
func TestGenerateReport(t *testing.T) {
    got := GenerateReport(testData)

    golden := filepath.Join("testdata", t.Name()+".golden")

    if *update {
        os.WriteFile(golden, got, 0644)
    }

    want, _ := os.ReadFile(golden)
    if !bytes.Equal(got, want) {
        t.Errorf("output mismatch, run with -update to update golden file")
    }
}
```

## Benchmark Tests

```go
func BenchmarkFoo(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Foo("test input")
    }
}

// Run benchmarks
// go test -bench=. -benchmem ./...
```

## Summary Checklist

- [ ] Use `_test.go` suffix for test files
- [ ] Use table-driven tests for multiple scenarios
- [ ] Use `t.Run()` for subtests
- [ ] Use `t.Parallel()` for isolated tests
- [ ] Use `t.Helper()` in test helper functions
- [ ] Run with `-race` flag
- [ ] Monitor coverage with `-cover`
- [ ] Use `testify/assert` for readable assertions
- [ ] Use `t.Cleanup()` for cleanup

