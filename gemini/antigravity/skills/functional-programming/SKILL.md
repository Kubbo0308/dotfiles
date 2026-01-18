---
name: functional-programming
description: MUST reference when writing code. Functional programming principles - prefer declarative over imperative, pure functions, and immutability.
---

# Functional Programming Principles

Apply these principles to improve readability, testability, and maintainability.

## Quick Start

1. Use declarative array methods (`map`, `filter`, `reduce`) instead of `for`/`while` loops
2. Write pure functions (no side effects, same input → same output)
3. Avoid mutation (use spread/destructuring for updates)
4. Define data structures with interfaces/types

## Core Principles

| Principle | Rule |
|-----------|------|
| Loops | MUST use `map`, `filter`, `reduce` instead of `for`/`while` |
| Variables | MUST use `const`, avoid `let` |
| Mutation | MUST NOT mutate, use spread/destructuring |
| Functions | MUST be pure when possible |
| Types | MUST define interfaces for data structures |
| Readonly | SHOULD use `readonly` for immutable data |

## How to Use

- `/functional-programming` - Apply constraints to code in this conversation
- `/functional-programming <file>` - Review file for violations

## References

- Declarative patterns: [declarative-patterns.md](references/declarative-patterns.md)
- Pure functions: [pure-functions.md](references/pure-functions.md)
- Immutability guide: [immutability.md](references/immutability.md)
- Data interfaces: [data-interfaces.md](references/data-interfaces.md)
