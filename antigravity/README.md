# Antigravity Configuration

Anthropic Agent SDK configuration for standardized AI agent development.

## Overview

Antigravity is the configuration directory for the [Anthropic Agent SDK](https://github.com/anthropics/anthropic-agent-sdk). It provides a standardized structure for agent definitions, skills, and workflows that can be shared across projects.

## Directory Structure

```
antigravity/
├── ARCHITECTURE.md          # Development standards and principles
├── agents/                  # Agent definitions
│   ├── serena-context.md
│   ├── codebase-analyzer.md
│   ├── commit.md
│   ├── pre-commit-checker.md
│   ├── pull-request.md
│   ├── code-reviewer-gemini.md
│   ├── typescript-developer.md
│   ├── go-developer.md
│   └── ...
├── skills/                  # Skill definitions (shared with claude/)
│   ├── clean-code/
│   ├── functional-programming/
│   ├── code-review/
│   ├── go-testing/
│   ├── database-admin/
│   ├── drawio/
│   ├── ui-ux-pro-max/
│   └── ...
└── workflows/               # Workflow definitions
```

## Relationship with Claude Code

Antigravity shares many configurations with `claude/`:

| Component | Claude Code | Antigravity | Notes |
|-----------|-------------|-------------|-------|
| Agents | `claude/agents/` | `antigravity/agents/` | Similar definitions |
| Skills | `claude/skills/` | `antigravity/skills/` | Shared skills |
| Commands | `claude/commands/` | - | Claude-specific |
| MCP | `claude/mcp/` | - | Claude-specific |

## Core Principles

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed standards.

### Code Quality Goals

| Metric | Target | Ideal Level |
|--------|--------|-------------|
| Cohesion | HIGH | Functional cohesion |
| Coupling | LOW | Data/Message coupling |
| Technical Debt | MINIMIZE | Avoid deliberate debt |

### Pre-Task Verification

Before every action:
1. Can this task be broken down into smaller steps?
2. Can a skill handle this?
3. Is the approach optimal?

## Available Agents

| Agent | Purpose |
|-------|---------|
| `serena-context` | Load project context |
| `codebase-analyzer` | Analyze codebase structure |
| `commit` | Generate commit messages |
| `pre-commit-checker` | Review changes before commit |
| `pull-request` | Create pull requests |
| `code-reviewer-gemini` | AI code review |
| `typescript-developer` | TypeScript assistance |
| `go-developer` | Go development assistance |

## Available Skills

| Skill | Description |
|-------|-------------|
| `clean-code` | Clean code principles |
| `functional-programming` | FP patterns |
| `code-review` | Review methodology |
| `go-testing` | Go test patterns |
| `database-admin` | DB design |
| `drawio` | Diagram creation |
| `pr-review` | PR review via gh CLI |
| `ui-ux-pro-max` | UI/UX patterns |
| `better-auth-best-practices` | Auth patterns |

## Git Commit Standards

Use conventional commits:

| Prefix | Purpose |
|--------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation |
| `style:` | Formatting |
| `refactor:` | Code refactoring |
| `test:` | Adding tests |
| `chore:` | Maintenance |

## TDD Workflow

1. **Red**: Write failing tests first
2. **Green**: Implement minimum code to pass
3. **Refactor**: Improve while keeping tests green

## Development Workflow

### Before Coding
1. Understand requirements fully
2. Consider edge cases
3. Plan implementation approach
4. Check for relevant skills

### During Coding
1. Write clean, readable code
2. Follow project conventions
3. Add appropriate error handling
4. Apply single responsibility principle

### After Coding
1. Review your own code
2. Consider security implications
3. Verify solution meets requirements

## Future Direction

Antigravity serves as:
- **Standardization layer** for AI agent configurations
- **Potential migration target** from Claude Code-specific configs
- **Cross-tool compatibility** for agent definitions

