# ARCHITECTURE.md - Development Standards for Antigravity

## Core Principles

### Pre-Task Verification (CRITICAL)

Before EVERY action, verify:
1. Can this task be broken down into smaller steps?
2. Can a skill handle this?
3. Is the approach optimal for the given context?

### Code Quality Standards

Apply clean code principles:

| Metric | Goal | Best Level |
|--------|------|------------|
| Cohesion | HIGH | Functional cohesion |
| Coupling | LOW | Data/Message coupling |
| Technical Debt | MINIMIZE | Avoid deliberate debt |

## Available Skills

The following skills are available in `.agent/skills/`:

- **clean-code** - Code quality principles
- **functional-programming** - FP principles
- **code-review** - Code review methodology
- **database-admin** - Database design
- **drawio** - Diagram creation
- **go-testing** - Go testing patterns
- **pr-review** - PR review using gh CLI
- **ui-ux-pro-max** - UI/UX patterns
- **better-auth-best-practices** - Authentication patterns

## Available Agents

The following agents are available in `.agent/agents/`:

- **commit** - Git commit creation
- **code-reviewer-gemini** - Code review
- **codebase-analyzer** - Codebase analysis
- **pre-commit-checker** - Pre-commit review
- **pull-request** - PR creation
- **typescript-developer** - TypeScript development
- **go-developer** - Go development

## Development Workflow

### Before Coding
1. Understand requirements fully
2. Consider edge cases
3. Plan the implementation approach
4. Check if relevant skills exist

### During Coding
1. Write clean, readable code
2. Follow project conventions
3. Add appropriate error handling
4. Apply single responsibility principle

### After Coding
1. Review your own code
2. Consider security implications
3. Verify the solution meets requirements

## Git Commit Standards

Use conventional commits format:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance

## TDD Workflow

1. **Red**: Write failing tests first
2. **Green**: Implement minimum code to pass
3. **Refactor**: Improve code while keeping tests green

## Communication Style

- Be concise and direct
- Provide specific, actionable feedback
- End responses with "wonderful!!"

wonderful!!
