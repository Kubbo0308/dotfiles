# Gemini CLI Options Reference (v0.27.3)

## Main Command

```bash
gemini [options] [query..]
```

## Flags

| Flag | Description |
|------|-------------|
| `-p, --prompt <text>` | Headless mode. Runs prompt and exits. Stdin is prepended if piped. |
| `-i, --prompt-interactive <text>` | Execute prompt then continue in interactive mode |
| `-m, --model <name>` | Specify model (e.g., `gemini-2.5-flash`, `gemini-3-pro-preview`) |
| `-r, --resume <value>` | Resume session. `"latest"` or index number (e.g., `-r 5`) |
| `-o, --output-format <fmt>` | Output: `text` (default), `json`, `stream-json` |
| `-y, --yolo` | Auto-accept all tool actions |
| `-s, --sandbox` | Run in sandbox |
| `-d, --debug` | Debug mode (F12 for console) |
| `-e, --extensions <list>` | Limit extensions to use (array) |
| `-l, --list-extensions` | List available extensions and exit |
| `-v, --version` | Show version |
| `-h, --help` | Show help |
| `--approval-mode <mode>` | `default`, `auto_edit`, `yolo`, `plan` (read-only) |
| `--allowed-tools <list>` | Tools allowed without confirmation (array) |
| `--allowed-mcp-server-names <list>` | Restrict active MCP servers (array) |
| `--list-sessions` | List sessions for current project |
| `--delete-session <index>` | Delete a session by index |
| `--include-directories <dirs>` | Additional workspace directories (comma-separated or repeated) |
| `--screen-reader` | Accessibility mode |
| `--raw-output` | Disable output sanitization (allow ANSI) |
| `--accept-raw-output-risk` | Suppress `--raw-output` security warning |
| `--experimental-acp` | Start in ACP (Agent Communication Protocol) mode |

## Subcommands

### `gemini mcp` - MCP Server Management

```bash
gemini mcp add <name> <commandOrUrl> [args..]   # Add server
  --scope user|project
  --transport/-t stdio|sse|http
  --env/-e KEY=VALUE
  --header/-H KEY=VALUE
  --timeout <ms>
  --trust
  --description <text>
  --include-tools <list>
  --exclude-tools <list>

gemini mcp remove <name>     # Remove server
gemini mcp list              # List servers
gemini mcp enable <name>     # Enable server
gemini mcp disable <name>    # Disable server
```

### `gemini extensions` - Extension Management

```bash
gemini extensions install <source>    # Install from git/path
  --auto-update --pre-release --ref <branch>
gemini extensions uninstall <names>
gemini extensions list
gemini extensions update [name] [--all]
gemini extensions enable/disable <name> [--scope]
gemini extensions link <path>         # Link local (live updates)
gemini extensions new <path> [template]
  # Templates: custom-commands, exclude-tools, hooks, mcp-server, skills
gemini extensions validate <path>
gemini extensions config [name] [setting] [--scope]
```

### `gemini skills` - Skill Management

```bash
gemini skills list [--all]
gemini skills enable <name>
gemini skills disable <name> [--scope]
gemini skills install <source> [--scope] [--path]
gemini skills uninstall <name> [--scope]
```

### `gemini hooks` - Hook Management

```bash
gemini hooks migrate    # Migrate hooks from Claude Code
```

## Session Management

Sessions are **project-scoped** and **index-based** (not ID-based).

```bash
gemini --list-sessions       # Show all sessions for current project
gemini -r latest             # Resume most recent session
gemini -r 5                  # Resume session #5
gemini --delete-session 3    # Delete session #3
```

## Stdin + Prompt Combination

When using `-p` with stdin, **stdin content is prepended to the prompt**:

```bash
# File review
cat src/main.ts | gemini -p "review this code"

# Git diff review
git diff | gemini -p "review this diff for issues"

# Multiple files
cat src/*.ts | gemini -p "find inconsistencies"

# Command output
npm test 2>&1 | gemini -p "explain these test failures"
```

## Approval Modes

| Mode | Behavior |
|------|----------|
| `default` | Ask before each tool action |
| `auto_edit` | Auto-approve file edits, ask for others |
| `yolo` | Auto-approve everything (same as `-y`) |
| `plan` | Read-only mode, no file modifications |

## Authentication

| Method | Setup |
|--------|-------|
| Google OAuth | `gemini` (interactive login prompt) |
| API Key | `export GEMINI_API_KEY="..."` |
| Vertex AI | `export GOOGLE_API_KEY="..." GOOGLE_GENAI_USE_VERTEXAI=true` |

## Configuration

- **User config**: `~/.gemini/settings.json`
- **Project context**: `GEMINI.md` (like CLAUDE.md)
- **Skills**: `~/.gemini/skills/`
- **MCP servers**: Managed via `gemini mcp` subcommand
