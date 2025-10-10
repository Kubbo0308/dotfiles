# MCP (Model Context Protocol) Configuration

This directory manages MCP server configurations for Claude Desktop and other Claude-compatible tools.

## 📁 Directory Structure

```
claude/mcp/
├── README.md                    # This file
├── claude-desktop-template.json # Template for Claude Desktop MCP config
├── generate-config.sh           # Script to generate configs from templates
├── setup-links.sh              # Script to create symbolic links
└── servers/                    # Directory for additional server templates
```

## 🔐 Security Notes

- **This is a public repository** - never commit files with absolute paths or API keys
- All generated config files (`.json` without `-template` suffix) are gitignored
- Use environment variables for sensitive information

## 🚀 Quick Start

### 1. Set up environment variables

```bash
cd ~/.dotfiles/claude/environments
cp .env.example .env.local
# Edit .env.local with your values
vim .env.local
```

### 2. Generate configurations

```bash
cd ~/.dotfiles/claude/mcp
./generate-config.sh
```

### 3. Create symbolic links

```bash
./setup-links.sh
```

## 📝 Configuration Templates

### claude-desktop-template.json
Template for Claude Desktop's MCP server configuration. Uses environment variables:
- `${MCP_FS_PATH_1}` - First filesystem path (default: ~/Desktop)
- `${MCP_FS_PATH_2}` - Second filesystem path (default: ~/Downloads)

### Adding New MCP Servers

1. Create a template file: `servers/myserver-template.json`
2. Use environment variables for any sensitive data
3. Add the variables to `.env.example`
4. Run `generate-config.sh` to generate the actual config

### Serena MCP Server

Serena MCP provides semantic code understanding and symbol-level editing capabilities.

**Directory Structure:**
```
servers/serena/
├── project.yml      # Serena project configuration
└── memories/        # Project-specific memories (auto-generated)
```

**Configuration:**
- Template: `servers/serena-template.json`
- Project config: `servers/serena/project.yml`
- Language: bash (for dotfiles repository)
- Mode: ide-assistant (optimized for IDE-like features)

**Features:**
- Semantic code search and understanding
- Symbol-level code editing
- Project memory and context
- Multi-language support

**Note:** The Serena project path is set to `servers/serena/` directory to keep all MCP-related data centralized.

### Playwright MCP Server

Playwright MCP enables web automation and browser interaction.

**Directory Structure:**
```
servers/playwright-data/
└── *.png            # Screenshots and automation artifacts (gitignored)
```

**Configuration:**
- Template: `servers/playwright-template.json`
- Uses npx for zero-install execution
- Stores screenshots in `servers/playwright-data/`

### Chrome DevTools MCP Server

Chrome DevTools MCP provides browser automation and debugging capabilities.

**Configuration:**
- Template: `servers/chrome-devtools-template.json`
- Uses npx for zero-install execution
- Environment variables:
  - `CHROME_HEADLESS`: Run in headless mode (true/false)
  - `CHROME_VIEWPORT`: Viewport size (e.g., 1280x720)
  - `CHROME_DEBUG_PORT`: Debug port (default: 9222)

**Features:**
- Browser automation (click, type, scroll, etc.)
- Navigation control (page transitions, reload, history)
- Device and network emulation
- Performance tracing and analysis
- Network request monitoring
- Console logs and screenshots

**Security:**
- Always uses isolated browser instance (`--isolated=true`)
- Separate Chrome profile to protect personal data
- No access to existing cookies or sessions

## 🔧 Scripts

### generate-config.sh
- Reads templates and replaces environment variables
- Generates actual config files (gitignored)
- Must be run before `setup-links.sh`

### setup-links.sh
- Creates symbolic links from generated configs to actual locations
- Backs up existing configs if they're not already symlinks
- Locations:
  - Claude Desktop: `~/Library/Application Support/Claude/claude_desktop_config.json`
  - Cursor: `~/.cursor/mcp.json` (if config exists)

## 🔄 Updating Configuration

After modifying templates or environment variables:

```bash
# Regenerate configs
./generate-config.sh

# Restart Claude Desktop to apply changes
# (Claude Desktop needs to be restarted to pick up MCP config changes)
```

## ⚠️ Important Notes

1. **Never edit generated files directly** - they will be overwritten
2. **Always use templates** for configuration changes
3. **Keep sensitive data in .env.local** (gitignored)
4. **Generated files are gitignored** to prevent leaking paths/tokens

## 🐛 Troubleshooting

### Config not working?
1. Check if .env.local exists and has correct values
2. Run `generate-config.sh` to regenerate configs
3. Run `setup-links.sh` to update symlinks
4. Restart Claude Desktop

### Permission errors?
- Ensure scripts are executable: `chmod +x *.sh`
- Check directory permissions for Claude config directory

### Changes not taking effect?
- Claude Desktop must be restarted after config changes
- Verify symlinks: `ls -la ~/Library/Application\ Support/Claude/`