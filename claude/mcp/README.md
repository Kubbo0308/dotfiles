# MCP (Model Context Protocol) Configuration for Claude Code CLI

This directory manages MCP server configurations for **Claude Code CLI**.

## 📁 Directory Structure

```
claude/mcp/
├── README.md                # This file
├── setup-cli-mcp.sh        # Setup script for Claude Code CLI
├── environments/           # Environment variables
│   ├── .env.example       # Example environment variables
│   └── .env.local         # Local environment variables (gitignored)
└── servers/               # MCP server data directories
    ├── serena/           # Serena MCP project data
    │   ├── project.yml   # Serena project configuration
    │   └── memories/     # Project-specific memories
    └── playwright-data/  # Playwright screenshots/artifacts (gitignored)
```

## 🚀 Quick Start

### 1. Set up environment variables

```bash
cd ~/.dotfiles/claude/mcp/environments
cp .env.example .env.local
# Edit .env.local with your values
vim .env.local
```

### 2. Run the setup script

```bash
cd ~/.dotfiles/claude/mcp
./setup-cli-mcp.sh
```

This script will configure all MCP servers for Claude Code CLI.

## 📝 Configured MCP Servers

### Serena MCP Server

**Semantic code understanding and symbol-level editing capabilities.**

- **Template**: Configured via `setup-cli-mcp.sh`
- **Project config**: `servers/serena/project.yml`
- **Language**: bash (for dotfiles repository)
- **Features**:
  - Semantic code search and understanding
  - Symbol-level code editing
  - Project memory and context
  - Multi-language support

**Environment Variables:**
- `UVX_PATH`: Absolute path to uvx command (default: `$HOME/.local/bin/uvx`)
- `SERENA_PROJECT_PATH`: Serena project path (default: `$HOME/.dotfiles`)

### Playwright MCP Server

**Web automation and browser interaction.**

- **Command**: `npx -y @playwright/mcp@latest`
- **Data directory**: `servers/playwright-data/`
- **Features**:
  - Web automation
  - Browser screenshots
  - Page navigation

### Chrome DevTools MCP Server

**Browser automation and debugging capabilities.**

- **Command**: `npx -y chrome-devtools-mcp@latest`
- **Features**:
  - Browser automation (26 tools)
  - Performance tracing and analysis
  - Network request monitoring
  - Device and network emulation
  - Isolated browser instance for security

**Environment Variables:**
- `CHROME_HEADLESS`: Run in headless mode (default: `false`)
- `CHROME_VIEWPORT`: Viewport size (default: `1280x720`)
- `CHROME_DEBUG_PORT`: Debug port (default: `9222`)

**Security:**
- Uses `--isolated=true` flag
- Separate Chrome profile
- No access to existing cookies or sessions

### Filesystem MCP Server

**File system access for specific directories.**

- **Command**: `npx -y @modelcontextprotocol/server-filesystem`
- **Paths**: `~/Desktop`, `~/Downloads`

### Context7 MCP Server

**Context search and retrieval.**

- **Command**: `npx -y @upstash/context7-mcp`

### PostgreSQL MCP Server

**Database access and queries.**

- **Command**: `npx -y @modelcontextprotocol/server-postgres`
- **Connection**: Configured via `.env.local`

**Environment Variable:**
- `POSTGRES_CONNECTION_STRING`: PostgreSQL connection string

## 🔧 Manual MCP Management

### Add a new MCP server

```bash
claude mcp add <name> -- <command> [args...]
```

### List all MCP servers

```bash
claude mcp list
```

### Get server details

```bash
claude mcp get <server-name>
```

### Remove a server

```bash
claude mcp remove <server-name> -s local
```

## 🔄 Updating Configuration

After modifying environment variables in `.env.local`:

```bash
cd ~/.dotfiles/claude/mcp
./setup-cli-mcp.sh
```

The script will re-add all MCP servers with updated configuration.

## ⚠️ Important Notes

1. **CLI-only configuration** - This setup is for Claude Code CLI, not Claude Desktop
2. **Local scope** - MCP servers are configured at project level
3. **Environment variables** - Keep sensitive data in `.env.local` (gitignored)
4. **Serena project data** - Stored in `servers/serena/` directory

## 🐛 Troubleshooting

### MCP servers not showing?

1. Run the setup script: `./setup-cli-mcp.sh`
2. Check server status: `claude mcp list`
3. Restart Claude Code

### Connection errors?

1. Verify environment variables in `.env.local`
2. Check if required tools are installed (uvx, npx, etc.)
3. Review server logs with `claude mcp get <server-name>`

### Permission errors?

- Ensure the setup script is executable: `chmod +x setup-cli-mcp.sh`
- Check file permissions in `servers/` directory

## 📚 Additional Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [Serena MCP GitHub](https://github.com/oraios/serena)
