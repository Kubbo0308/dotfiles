# Code Review Checklist

## Table of Contents
1. [General](#general)
2. [Testing](#testing)
3. [Documentation](#documentation)
4. [Git Commands](#git-commands)

---

## General

- [ ] Code compiles/runs without errors
- [ ] No debugging code left (console.log, print statements)
- [ ] No commented-out code blocks
- [ ] Consistent formatting and style
- [ ] No duplicate code
- [ ] Functions are small and focused
- [ ] Variable names are descriptive

## Testing

- [ ] New code has corresponding tests
- [ ] Edge cases are covered
- [ ] Tests are meaningful (not just for coverage)
- [ ] Tests are isolated and independent
- [ ] Mocks are used appropriately

## Documentation

- [ ] Complex logic is commented
- [ ] Public APIs are documented
- [ ] README updated if needed
- [ ] Breaking changes are noted

## Git Commands

```bash
# View staged changes
git diff --cached

# View diff for specific file
git diff <file>

# View recent commits
git log --oneline -10

# View PR details
gh pr view <number>

# View PR diff
gh pr diff <number>
```

