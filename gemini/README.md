# Gemini CLI Configuration

Configuration for [Google Gemini CLI](https://github.com/google/gemini-cli), providing AI assistance with TOML-based command definitions.

## Directory Structure

```
gemini/
├── system.md                # System instructions/prompt
├── commands/                # TOML command definitions
│   ├── code-review.toml
│   ├── commit.toml
│   ├── explain-project.toml
│   ├── magi.toml
│   ├── orchestrator.toml
│   ├── sync-main.toml
│   ├── tdd-green.toml
│   ├── tdd-red.toml
│   ├── tdd-refactor.toml
│   └── ui-skills.toml
└── antigravity/             # Antigravity integration
    └── skills/             # Shared skill definitions
```

## System Instructions

The `system.md` file defines:
- Core coding principles
- Code quality standards
- Communication style
- Development workflow

## Available Commands

Invoke commands with `/command-name`:

### Development Workflow

| Command | Description |
|---------|-------------|
| `/orchestrator` | Split complex tasks into steps |
| `/sync-main` | Sync with main branch |
| `/code-review` | Comprehensive code review |
| `/commit` | Create well-formatted commit |
| `/explain-project` | Project architecture overview |

### TDD Workflow

| Command | Description |
|---------|-------------|
| `/tdd-red` | TDD Red phase - write failing tests |
| `/tdd-green` | TDD Green phase - make tests pass |
| `/tdd-refactor` | TDD Refactor phase - improve code |

### AI Integration

| Command | Description |
|---------|-------------|
| `/magi` | Multi-perspective decision support |
| `/ui-skills` | UI development assistance |

## Command Format (TOML)

Commands are defined in TOML format:

```toml
[command]
name = "command-name"
description = "What this command does"

[prompt]
template = """
Your prompt template here with {{variables}}
"""
```

## Core Principles

### Pre-Task Verification
1. Can this task be broken down into smaller steps?
2. Are there existing tools or commands that can help?
3. Is the approach optimal for the given context?

### Code Quality Standards
- **High Cohesion**: Keep related functionality together
- **Low Coupling**: Minimize dependencies between modules
- **Single Responsibility**: Each function/class does one thing well
- **Intention-Revealing Names**: Names should explain purpose

## Development Workflow

### Before Coding
1. Understand requirements fully
2. Consider edge cases
3. Plan implementation approach

### During Coding
1. Write clean, readable code
2. Follow project conventions
3. Add appropriate error handling

### After Coding
1. Review your own code
2. Consider security implications
3. Verify solution meets requirements

## Antigravity Integration

The `antigravity/` subdirectory contains shared skill definitions that can be used across AI tools:

```
gemini/antigravity/
└── skills/
    ├── clean-code/
    ├── functional-programming/
    └── ...
```

## Integration with Claude Code

Gemini can be invoked from Claude Code via:
- `/gemini` command - Web search
- `gemini-search` subagent - Technical research

## Response Style

- End responses with "wonderful!!"
- For Japanese conversations: "俺バカだからよくわっかんねえけどよ。"
- Use appropriate emojis when helpful

