# Language-Specific Guidelines

## Table of Contents
1. [TypeScript/JavaScript](#typescriptjavascript)
2. [Go](#go)
3. [Python](#python)
4. [React](#react)

---

## TypeScript/JavaScript

- Prefer `const` over `let`
- Use strict equality (`===`)
- Avoid `any` type - use proper types or `unknown`
- Use async/await over raw Promises
- Check for null/undefined with optional chaining (`?.`)
- Use nullish coalescing (`??`) over `||` for defaults
- Destructure objects and arrays when appropriate

### Common Issues
```typescript
// Bad: any type
const data: any = fetchData();

// Good: proper typing
const data: UserData = fetchData();

// Bad: type assertion
const user = data as User;

// Good: type guard
if (isUser(data)) {
  const user = data;
}
```

## Go

- Follow Effective Go guidelines
- Handle all errors (no `_` for errors)
- Use context for cancellation and timeouts
- Avoid goroutine leaks
- Use defer for cleanup
- Prefer table-driven tests

### Common Issues
```go
// Bad: ignored error
result, _ := doSomething()

// Good: handle error
result, err := doSomething()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}
```

## Python

- Follow PEP 8 style guide
- Use type hints for function signatures
- Use context managers (`with`) for resources
- Avoid mutable default arguments
- Use f-strings for formatting
- Prefer list comprehensions over map/filter

### Common Issues
```python
# Bad: mutable default
def append_to(element, lst=[]):
    lst.append(element)
    return lst

# Good: None default
def append_to(element, lst=None):
    if lst is None:
        lst = []
    lst.append(element)
    return lst
```

## React

- Use functional components with hooks
- Memoize expensive computations (useMemo)
- Memoize callbacks passed to children (useCallback)
- Clean up effects properly
- Avoid inline object/function definitions in JSX
- Use proper key props in lists

### Common Issues
```tsx
// Bad: inline object causes re-render
<Component style={{ color: 'red' }} />

// Good: memoized or constant
const style = useMemo(() => ({ color: 'red' }), []);
<Component style={style} />
```

