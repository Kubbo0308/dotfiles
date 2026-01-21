# Cursor IDE Configuration

Configuration for [Cursor](https://cursor.sh/), the AI-powered code editor.

## Directory Structure

```
cursor/
├── README.md                # This file
├── commands/                # Custom commands
│   └── ui-skills.md        # UI development command
└── skills/                  # Skill definitions
    └── ui-skills/
        └── SKILL.md        # UI/UX development skill
```

## Features

### Commands

Custom commands that can be invoked in Cursor:

| Command | Description |
|---------|-------------|
| `ui-skills` | UI development assistance with opinionated constraints |

### Skills

Skills provide domain-specific knowledge:

| Skill | Description |
|-------|-------------|
| `ui-skills` | Opinionated constraints for building better interfaces |

## UI Skills

The `ui-skills` skill provides:
- Interface design constraints
- Component library recommendations
- UX best practices
- Accessibility guidelines

## Setup

Cursor automatically detects configuration in the project directory. Place these files in your project or link them globally.

### Global Configuration

Link to Cursor's config directory (location varies by OS):

**macOS:**
```bash
ln -s ~/.dotfiles/cursor ~/.cursor
```

### Project Configuration

Copy or symlink to your project:

```bash
ln -s ~/.dotfiles/cursor/commands .cursor/commands
ln -s ~/.dotfiles/cursor/skills .cursor/skills
```

## Command Format

Commands are defined in markdown files:

```markdown
# Command Name

Description of what this command does.

## Instructions

1. Step one
2. Step two
3. ...
```

## Skill Format

Skills follow a structured markdown format in `SKILL.md`:

```markdown
# Skill Name

## Overview

Brief description of the skill.

## Guidelines

Specific instructions and patterns.

## Examples

Code examples and usage patterns.
```

## Integration with Other AI Tools

The `ui-skills` skill is shared across:
- Cursor (`cursor/skills/`)
- Claude Code (`claude/skills/`)
- Gemini (`gemini/antigravity/skills/`)

This ensures consistent UI development guidelines across all AI assistants.

## Resources

- [Cursor Documentation](https://cursor.sh/docs)
- [Cursor GitHub](https://github.com/getcursor/cursor)

