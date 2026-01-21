# dotfiles

Git-managed configuration files with symbolic link setup for easy synchronization across machines.

## Structure

```
~/.dotfiles/
├── config/                      # Application configurations
│   ├── nvim/                   # Neovim configuration (Lua-based)
│   └── wezterm/                # WezTerm terminal configuration
├── claude/                      # Claude Code AI configuration
│   ├── agents/                 # Subagent definitions (30+)
│   ├── commands/               # Custom slash commands
│   ├── skills/                 # Development skills (12+)
│   └── mcp/                    # Model Context Protocol setup
├── antigravity/                 # Anthropic Agent SDK configuration
│   ├── agents/                 # Agent definitions
│   ├── skills/                 # Shared skills
│   └── workflows/              # Workflow definitions
├── codex/                       # Codex CLI configuration
│   ├── prompts/                # Prompt templates
│   ├── skills/                 # Skill integration
│   └── mcp/                    # MCP configuration
├── gemini/                      # Gemini AI configuration
│   ├── commands/               # TOML command definitions
│   └── antigravity/            # Antigravity integration
├── cursor/                      # Cursor IDE configuration
│   ├── commands/               # Custom commands
│   └── skills/                 # UI skills
├── nix/                         # Nix/home-manager configuration
│   ├── nix-darwin/             # macOS system settings
│   ├── home.nix                # User environment
│   └── pkgs.nix                # CLI package list
├── .scripts/                    # Setup and utility scripts
│   ├── setup-environment.sh    # One-command full setup
│   ├── install.sh              # Symlink installation
│   ├── sync-to-dotfiles.sh     # Backup configs
│   └── restore-from-dotfiles.sh # Restore configs
├── oh-my-zsh-custom/            # Oh My Zsh customizations
│   ├── themes/                 # Custom themes
│   └── plugins.txt             # External plugins list
├── docs/                        # Documentation
│   └── git-commands.md         # Git workflow guide
├── zshrc                        # Zsh shell configuration
├── CLAUDE.md                    # Claude Code project instructions
└── README.md                    # This file
```

## Quick Start

### One-Command Setup (Recommended)

For new machines, use the unified setup script:

```bash
git clone <repository-url> ~/.dotfiles
~/.dotfiles/.scripts/setup-environment.sh
```

This will automatically:
- Install Homebrew (if not installed)
- Install all packages from Brewfile
- Install Oh-My-Zsh (if not installed)
- Create symbolic links for all dotfiles
- Set up MCP configurations for AI tools

### Manual Installation

If you prefer step-by-step installation:

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/.dotfiles
   ```

2. Run the installation script:
   ```bash
   ~/.dotfiles/.scripts/install.sh
   ```

### Nix Setup (Optional)

For declarative macOS environment management:

```bash
cd ~/.dotfiles/nix
nix flake update
nix run nix-darwin -- switch --flake .#kubbo-set
```

See [nix/README.md](nix/README.md) for detailed instructions.

## Symbolic Links Created

| Target | Link |
|--------|------|
| `~/.dotfiles/zshrc` | `~/.zshrc` |
| `~/.dotfiles/config/nvim` | `~/.config/nvim` |
| `~/.dotfiles/config/wezterm` | `~/.config/wezterm` |
| `~/.dotfiles/claude` | `~/.claude` |

## Key Features

### Shell Environment
- **Shell**: Zsh with Oh-My-Zsh
- **Theme**: agnoster
- **Terminal**: WezTerm (Tokyo Night color scheme)
- **Navigation**: zoxide for smart directory jumping

### Editor (Neovim)
- **Plugin Manager**: lazy.nvim with lazy loading
- **Git Integration**: Telescope, GitSigns, DiffView, Octo.nvim
- **Languages**: Go, TypeScript/JavaScript (typescript-tools.nvim)
- **Leader Key**: `Space`

See [config/nvim/README.md](config/nvim/README.md) for keybindings.

### AI Tool Integration
- **Claude Code**: Primary AI assistant with 30+ subagents
- **Antigravity**: Anthropic Agent SDK configuration
- **Codex CLI**: Alternative AI coding assistant
- **Gemini**: Google AI integration

See [claude/README.md](claude/README.md) for AI workflow details.

### Package Management
- **Nix**: Declarative CLI tool management
- **Homebrew**: GUI applications and fonts
- **home-manager**: User environment configuration

## Workflow

### Backup Current Configurations

```bash
~/.dotfiles/.scripts/sync-to-dotfiles.sh
cd ~/.dotfiles
git add .
git commit -m "update: sync configurations"
git push
```

### Restore Configurations

```bash
~/.dotfiles/.scripts/restore-from-dotfiles.sh
```

### Update Dotfiles

```bash
cd ~/.dotfiles
git pull
```

### Update Nix Packages

```bash
cd ~/.dotfiles/nix
nix run .#update
```

## Security

Sensitive files are automatically ignored via `.gitignore`:
- API keys and tokens
- Claude settings and project data
- SSH keys and configurations
- Environment variables with sensitive data
- Cache and temporary files

## Uninstallation

To remove all symbolic links:

```bash
~/.dotfiles/.scripts/uninstall.sh
```

## Directory Documentation

| Directory | README | Description |
|-----------|--------|-------------|
| `.scripts/` | [README.md](.scripts/README.md) | Setup scripts and tools |
| `nix/` | [README.md](nix/README.md) | Nix/home-manager configuration |
| `config/nvim/` | [README.md](config/nvim/README.md) | Neovim setup and keybindings |
| `config/wezterm/` | [README.md](config/wezterm/README.md) | WezTerm configuration |
| `claude/` | [README.md](claude/README.md) | Claude Code AI setup |
| `antigravity/` | [README.md](antigravity/README.md) | Anthropic Agent SDK |
| `codex/` | [README.md](codex/README.md) | Codex CLI configuration |
| `gemini/` | [README.md](gemini/README.md) | Gemini AI setup |
| `cursor/` | [README.md](cursor/README.md) | Cursor IDE configuration |
| `oh-my-zsh-custom/` | [README.md](oh-my-zsh-custom/README.md) | Zsh customizations |
| `docs/` | [README.md](docs/README.md) | Additional documentation |

