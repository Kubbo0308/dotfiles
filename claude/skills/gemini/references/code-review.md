# Code Review with Gemini CLI

## Basic Review

```bash
gemini --prompt="Review this code for bugs, performance issues, and security concerns." --file="src/main.ts"
```

## Detailed Review Template

```bash
gemini --prompt="
Review the following code:

【Aspects】
1. Bugs and logical errors
2. Performance issues
3. Security vulnerabilities
4. Readability and maintainability
5. Best practice compliance
6. Error handling
7. Test coverage gaps

【Output Format】
- Specific line numbers for each issue
- Concrete code examples for improvements
- Priority levels: High / Medium / Low
" --file="path/to/file"
```

## Pull Request Review

```bash
# Review a git diff
git diff main...HEAD | gemini -p "
Review this pull request diff:
1. Validity of changes
2. Impact on existing code
3. Testing requirements
4. Code style consistency
Provide constructive comments with specific suggestions."
```

## Security-Focused Review

```bash
gemini --prompt="
Security review checklist:
- Input validation
- SQL injection / NoSQL injection
- Authentication and authorization
- Sensitive data handling
- XSS vulnerabilities
- CSRF protection
- API key / secret management
Provide specific countermeasures for each issue found.
" --file="path/to/file"
```

## Performance-Focused Review

```bash
gemini --prompt="
Performance review checklist:
- Algorithm complexity (time & space)
- Memory usage and leaks
- Database query efficiency (N+1, missing indexes)
- Network optimization
- Cache utilization
- Unnecessary computations
Provide specific optimization suggestions.
" --file="path/to/file"
```

## Multi-File Review

```bash
gemini --prompt="
Review these files for:
- Inter-file dependencies and coupling
- Architectural consistency
- Separation of concerns
- Interface design
" --file="src/api.ts" --file="src/service.ts" --file="src/repository.ts"
```

## Collaboration Mode (Claude + Gemini)

When Claude and Gemini collaborate on review:

```bash
# Claude generates context, Gemini reviews
CONTEXT="$(git diff --staged)"
gemini <<EOF
Review the following staged changes:
$CONTEXT

Focus on:
- Breaking changes
- Missing error handling
- Test coverage gaps
EOF
```

Claude then integrates Gemini's findings with its own analysis.
