# Claude Code Configuration

Claude Code AI assistant configuration with subagents, skills, commands, and MCP integrations.

## Directory Structure

```
claude/
├── CLAUDE.md                # Global development standards and instructions
├── settings.json            # Main Claude Code settings
├── agents/                  # Subagent definitions (29+)
├── commands/                # Custom slash commands (37+)
├── skills/                  # Development skills (12)
├── mcp/                     # Model Context Protocol setup
├── plugins/                 # Plugin management
│   └── marketplaces/       # Plugin sources
├── hooks/                   # Lifecycle hooks
├── environments/            # Environment variables
├── projects/                # Project-specific settings
├── session-env/             # Session environments
├── plans/                   # Saved plans
└── cache/                   # Cache files
```

## Subagent First Policy

> **Before every action, verify: Can a Subagent handle this?**

This is the #1 most important rule for efficient Claude Code usage.

## Subagents

| Priority | Agent | Purpose |
|----------|-------|---------|
| **🔴 ALWAYS** | `serena-context` | Load project context at session start |
| **🔴 ALWAYS** | `codebase-analyzer` | Analyze codebase structure |
| **🔴 ALWAYS** | `pre-commit-checker` | Review changes before commit |
| **🟡 HIGH** | `commit` | Generate quality commit messages |
| **🟡 HIGH** | `pull-request` | Create well-documented PRs |
| **🟡 HIGH** | `code-reviewer-gemini` | AI-powered code review |
| **🟡 HIGH** | `typescript-test-generator` | Generate TypeScript/React tests |
| **🟡 HIGH** | `go-developer` | Go development assistance |
| **🟡 HIGH** | `typescript-developer` | TypeScript development assistance |
| **🟢 MEDIUM** | `security` | Security analysis |
| **🟢 MEDIUM** | `web-researcher` | Technical research |
| **🟢 MEDIUM** | `document` | Documentation generation |
| **🟢 MEDIUM** | `task-decomposer` | Break down complex tasks |
| **🟢 MEDIUM** | `drawio-diagram-generator` | Create architecture diagrams |

### Specialized Reviewers

| Agent | Focus Area |
|-------|------------|
| `go-reviewer` | Go idiomatic patterns |
| `typescript-reviewer` | TypeScript/React best practices |
| `terraform-reviewer` | Infrastructure as Code |
| `dbt-reviewer` | dbt SQL style and testing |
| `markdown-reviewer` | Documentation quality |
| `clean-code-fp-reviewer` | Clean code & functional programming |
| `codex-reviewer` | Cross-agent code review |

### MAGI System

Three-agent deliberation system for complex decisions:

| Agent | Role |
|-------|------|
| `magi-melchior` | Scientific/logical analysis |
| `magi-balthasar` | Practical implementation focus |
| `magi-casper` | Risk assessment and caution |

Invoke with `/magi <question>` command.

## Skills

Skills provide domain-specific knowledge and patterns:

| Skill | Description |
|-------|-------------|
| `clean-code` | Clean code principles (cohesion, coupling, naming) |
| `functional-programming` | FP patterns (pure functions, immutability) |
| `code-review` | Comprehensive review methodology |
| `go-testing` | Go table-driven test patterns |
| `database-admin` | Schema design and query optimization |
| `drawio` | draw.io diagram XML generation |
| `pr-review` | GitHub PR review via gh CLI |
| `ui-ux-pro-max` | UI patterns and component library |
| `better-auth-best-practices` | TypeScript authentication patterns |
| `create-auth-skill` | Auth layer implementation guide |
| `codex-integration` | Codex CLI collaboration |
| `ui-skills` | Opinionated UI constraints |

## Commands

### Development Workflow

| Command | Description |
|---------|-------------|
| `/sync-main` | Sync with main branch |
| `/mr` | Merge request workflow |
| `/create-pr` | Create pull request |
| `/add-feature` | Add new feature |
| `/bugfix` | Fix bug workflow |
| `/fix-issue` | Fix GitHub issue |
| `/fix-ui` | UI bug fixes |

### TDD Workflow

| Command | Description |
|---------|-------------|
| `/tdd-requirements` | Define test requirements |
| `/tdd-testcases` | Generate test cases |
| `/tdd-red` | Write failing tests |
| `/tdd-green` | Make tests pass |
| `/tdd-refactor` | Refactor code |
| `/tdd-verify-complete` | Verify completion |

### Kairo Workflow

| Command | Description |
|---------|-------------|
| `/kairo-requirements` | Gather requirements |
| `/kairo-design` | Design solution |
| `/kairo-tasks` | Generate tasks |
| `/kairo-implement` | Implementation |
| `/kairo-task-verify` | Verify tasks |

### AI Integration

| Command | Description |
|---------|-------------|
| `/magi` | Invoke MAGI system |
| `/gemini` | Web search via Gemini |
| `/geminiReview` | Gemini code review |
| `/ui-skills` | UI development skill |

### Documentation

| Command | Description |
|---------|-------------|
| `/explain-project` | Explain project structure |
| `/feature-log` | Log feature changes |
| `/blog` | Generate blog content |

## MCP Servers

See [mcp/README.md](mcp/README.md) for detailed MCP configuration.

Configured servers:
- **Serena**: Semantic code understanding
- **Playwright**: Web automation
- **Chrome DevTools**: Browser debugging
- **Context7**: Documentation search
- **Filesystem**: File access
- **PostgreSQL**: Database access

## Session Start Checklist

```
□ 1. Load context: @serena-context
□ 2. Review context summary
□ 3. Identify required subagents
□ 4. Use @codebase-analyzer for understanding
□ 5. NEVER read files manually when subagents can do it
```

## Development Standards

See [CLAUDE.md](CLAUDE.md) for complete development standards including:
- Pre-task verification checklist
- Subagent usage requirements
- Communication style guidelines
- Commit message conventions

## Benefits of Subagent Approach

- **Token Efficiency**: 60-80% reduction in context usage
- **Quality**: Specialized agents produce better results
- **Speed**: Parallel execution capability
- **Consistency**: Maintains patterns across sessions
- **Memory**: Serena MCP preserves institutional knowledge

## Quick Reference

### Before Any Commit

```bash
# 1. Run pre-commit checker
@pre-commit-checker

# 2. Create commit
@commit
```

### Before Any PR

```bash
# 1. Code review
@code-reviewer-gemini

# 2. Create PR
@pull-request
```

### For Code Understanding

```bash
# Analyze codebase
@codebase-analyzer

# Or for quick search
@Explore
```

