# Code Review with Gemini CLI

## Basic Review (stdin)

```bash
cat src/main.ts | gemini -p "review this code for bugs, performance, and security"
```

## Detailed Review

```bash
cat src/main.ts | gemini -p "
Review this code thoroughly:

1. Bugs and logical errors
2. Performance issues
3. Security vulnerabilities
4. Readability and maintainability
5. Best practice compliance
6. Error handling gaps
7. Test coverage needs

Output: specific line references, concrete fixes, priority (High/Medium/Low)
"
```

## Pull Request Review

```bash
# Review staged changes
git diff --staged | gemini -p "
Review this PR diff:
1. Validity of changes
2. Impact on existing code
3. Testing requirements
4. Code style consistency
Provide constructive feedback with specific suggestions."

# Review branch diff
git diff main...HEAD | gemini -p "review this PR for issues"
```

## Security-Focused Review

```bash
cat src/auth.ts | gemini -p "
Security review:
- Input validation
- SQL/NoSQL injection
- Authentication/authorization flaws
- Sensitive data handling
- XSS vulnerabilities
- CSRF protection
- Secret management
Provide specific countermeasures for each issue."
```

## Performance-Focused Review

```bash
cat src/api.ts | gemini -p "
Performance review:
- Algorithm complexity (time & space)
- Memory usage and leaks
- Database query efficiency (N+1, missing indexes)
- Network optimization
- Cache utilization
- Unnecessary computations
Provide specific optimization suggestions."
```

## Multi-File Review

```bash
cat src/api.ts src/service.ts src/repository.ts | gemini -p "
Review these files together for:
- Inter-file coupling
- Architectural consistency
- Separation of concerns
- Interface design"
```

## Auto-Approve Mode (for trusted operations)

```bash
# Let Gemini fix issues directly
cat src/main.ts | gemini -p "fix all lint errors in this code" -y

# Plan mode (read-only, no modifications)
cat src/main.ts | gemini -p "suggest improvements" --approval-mode plan
```

## JSON Output for CI/CD

```bash
git diff --staged | gemini -p "review and list issues as JSON array" -o json
```

## Session-Based Review

```bash
# Start review session
gemini -i "let's review the authentication module"

# Later, resume the same session
gemini -r latest
```

## Claude + Gemini Collaboration

When Claude orchestrates review via Gemini:

```bash
# Claude generates context, Gemini reviews
git diff --staged | gemini -p "review this diff. focus on breaking changes and missing tests"

# Parse structured output
git diff | gemini -p "list all issues as JSON" -o json
```

Claude integrates Gemini's findings with its own analysis for comprehensive review.
