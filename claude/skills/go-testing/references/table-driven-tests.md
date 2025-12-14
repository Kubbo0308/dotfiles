# Table-Driven Tests in Go

Table-driven tests are the idiomatic way to write tests in Go. They provide clear structure, easy maintenance, and comprehensive coverage.

## Basic Pattern

```go
func TestFoo(t *testing.T) {
    tests := []struct {
        name  string
        input string
        want  string
    }{
        {
            name:  "valid input returns expected output",
            input: "hello",
            want:  "HELLO",
        },
        {
            name:  "empty input returns empty string",
            input: "",
            want:  "",
        },
        {
            name:  "special characters are preserved",
            input: "hello!@#",
            want:  "HELLO!@#",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Foo(tt.input)
            if got != tt.want {
                t.Errorf("Foo(%q) = %q, want %q", tt.input, got, tt.want)
            }
        })
    }
}
```

## With Error Cases

```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Config
        wantErr bool
    }{
        {
            name:  "valid JSON config",
            input: `{"port": 8080}`,
            want:  &Config{Port: 8080},
        },
        {
            name:    "invalid JSON returns error",
            input:   `{invalid}`,
            wantErr: true,
        },
        {
            name:    "empty input returns error",
            input:   "",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig(tt.input)

            if tt.wantErr {
                if err == nil {
                    t.Error("expected error, got nil")
                }
                return
            }

            if err != nil {
                t.Errorf("unexpected error: %v", err)
                return
            }

            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("got %+v, want %+v", got, tt.want)
            }
        })
    }
}
```

## Parallel Execution

Use `t.Parallel()` for tests that don't share state:

```go
func TestConcurrentSafe(t *testing.T) {
    tests := []struct {
        name  string
        input int
        want  int
    }{
        {"double 5", 5, 10},
        {"double 10", 10, 20},
        {"double 0", 0, 0},
    }

    for _, tt := range tests {
        tt := tt // capture range variable
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel() // run subtests in parallel
            got := Double(tt.input)
            if got != tt.want {
                t.Errorf("Double(%d) = %d, want %d", tt.input, got, tt.want)
            }
        })
    }
}
```

## Nested Subtests for Complex Scenarios

```go
func TestUserService(t *testing.T) {
    t.Run("Create", func(t *testing.T) {
        t.Run("with valid data succeeds", func(t *testing.T) {
            // test logic
        })

        t.Run("with duplicate email fails", func(t *testing.T) {
            // test logic
        })
    })

    t.Run("Delete", func(t *testing.T) {
        t.Run("existing user succeeds", func(t *testing.T) {
            // test logic
        })

        t.Run("non-existent user returns error", func(t *testing.T) {
            // test logic
        })
    })
}
```

## Anti-Patterns to Avoid

### Don't: Separate test functions for each case

```go
// BAD: Repetitive and hard to maintain
func TestFoo_ValidInput(t *testing.T) {
    got := Foo("hello")
    if got != "HELLO" {
        t.Error("failed")
    }
}

func TestFoo_EmptyInput(t *testing.T) {
    got := Foo("")
    if got != "" {
        t.Error("failed")
    }
}
```

### Don't: Anonymous test cases without names

```go
// BAD: No test names, hard to identify failures
tests := []struct {
    input string
    want  string
}{
    {"hello", "HELLO"},
    {"", ""},
}
```

### Don't: Forget to capture range variable in parallel tests

```go
// BAD: Race condition - all iterations share same tt
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()
        // tt may have changed by the time this runs!
        got := Foo(tt.input)
    })
}

// GOOD: Capture the variable
for _, tt := range tests {
    tt := tt // capture!
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()
        got := Foo(tt.input)
    })
}
```

## Best Practices

1. **Descriptive test names**: Use names that describe the scenario and expected outcome
2. **One assertion focus**: Each test case should verify one specific behavior
3. **Setup/teardown**: Use `t.Cleanup()` for cleanup instead of defer when possible
4. **Test data**: Keep test data close to the test, avoid external files when possible
5. **Error messages**: Include actual vs expected values in error messages

