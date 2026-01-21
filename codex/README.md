# Codex CLI Configuration

Configuration for [OpenAI Codex CLI](https://github.com/openai/codex), an alternative AI coding assistant.

## Directory Structure

```
codex/
├── config.toml              # Main configuration
├── AGENTS.md                # Agent definitions reference
├── prompts/                 # Prompt templates (30+)
│   ├── add-feature.md
│   ├── tdd-*.md            # TDD workflow prompts
│   ├── kairo-*.md          # Kairo workflow prompts
│   └── ...
├── rules/                   # Rule definitions
│   └── default.rules
├── skills/                  # Skill integration
│   ├── codex-integration/
│   └── .system/            # System skills
│       ├── skill-creator/
│       └── skill-installer/
├── mcp/                     # MCP configuration
│   ├── README.md
│   ├── config-template.toml
│   ├── generate-config.sh
│   └── setup-links.sh
├── sessions/                # Session history (by date)
│   └── 2025/...
├── log/                     # Logs
├── tmp/                     # Temporary files
├── auth.json                # Authentication (gitignored)
├── history.jsonl            # Command history
└── version.json             # Version info
```

## Quick Setup

1. **Generate MCP configuration:**
   ```bash
   cd ~/.dotfiles/codex/mcp
   ./generate-config.sh
   ./setup-links.sh
   ```

2. **Restart Codex CLI** to pick up changes.

## Prompt Templates

Codex uses markdown prompt templates for common workflows:

### Development Workflow

| Prompt | Description |
|--------|-------------|
| `add-feature.md` | Add new feature |
| `bugfix.md` | Fix bug workflow |
| `fix-issue.md` | Fix GitHub issue |
| `fix-ui.md` | UI bug fixes |
| `create-pr.md` | Create pull request |

### TDD Workflow

| Prompt | Description |
|--------|-------------|
| `tdd-requirements.md` | Define test requirements |
| `tdd-testcases.md` | Generate test cases |
| `tdd-red.md` | Write failing tests |
| `tdd-green.md` | Make tests pass |
| `tdd-refactor.md` | Refactor code |
| `tdd-verify-complete.md` | Verify completion |

### Kairo Workflow

| Prompt | Description |
|--------|-------------|
| `kairo-requirements.md` | Gather requirements |
| `kairo-design.md` | Design solution |
| `kairo-tasks.md` | Generate tasks |
| `kairo-implement.md` | Implementation |
| `kairo-task-verify.md` | Verify tasks |

### AI Integration

| Prompt | Description |
|--------|-------------|
| `gemini.md` | Gemini search |
| `geminiReview.md` | Gemini code review |
| `orchestrator.md` | Multi-agent orchestration |

### Documentation

| Prompt | Description |
|--------|-------------|
| `explain-project.md` | Project explanation |
| `feature-log.md` | Feature changelog |
| `blog.md` | Blog generation |

## MCP Servers

See [mcp/README.md](mcp/README.md) for detailed configuration.

Configured servers:
- **context7**: Documentation and API search
- **playwright**: Browser automation
- **figma-dev-mode**: Figma integration
- **serena**: Code intelligence

## System Skills

Located in `skills/.system/`:

| Skill | Description |
|-------|-------------|
| `skill-creator` | Create new skills |
| `skill-installer` | Install skills |

## Session Management

Session history is organized by date:
```
sessions/
├── 2025/
│   ├── 09/
│   ├── 10/
│   └── ...
└── 2026/
    └── 01/
```

## Integration with Claude Code

Codex can be invoked from Claude Code via the `codex-integration` skill or `codex-reviewer` subagent for cross-agent collaboration.

### Use Cases

- Get a second opinion from GPT-5 Codex
- Web search via Codex
- Image analysis with OpenAI vision
- Compare approaches between AI models

## Configuration

### Environment Variables

```bash
# Context7 API (optional, falls back to unauthenticated)
export CONTEXT7_API_KEY="your-key"

# Trust additional project directories
export CODEX_EXTRA_PROJECTS="~/work/project-a:~/work/project-b"
```

### Regenerate Config

After modifying environment or template:

```bash
cd ~/.dotfiles/codex/mcp
./generate-config.sh
./setup-links.sh
```

## Files (gitignored)

The following sensitive files are excluded from version control:
- `auth.json` - Authentication tokens
- `history.jsonl` - Command history
- `sessions/` - Session data
- `config.toml` - Generated config

