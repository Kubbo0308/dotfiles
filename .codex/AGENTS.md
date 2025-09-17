# AGENTS.md

This file provides guidance to Codex (Codex CLI) when working with code in this repository. It defines conventions and expectations that apply across all Codex agents when assisting in this project.

## Repository Overview

This is a dotfiles repository that manages personal development environment configurations via Git and symbolic links. It provides a unified way to synchronize development tools across multiple machines.

## Development Commands

### Installation & Setup
```bash
# Initial installation
~/.dotfiles/install.sh

# Install Oh-My-Zsh plugins
~/.dotfiles/install-oh-my-zsh-plugins.sh

# Update dotfiles
cd ~/.dotfiles && git pull

# Remove dotfiles (cleanup)
~/.dotfiles/uninstall.sh
```

### Git Workflow
All commits use English prefixes:
- add/ — Feature addition
- fix/ — Bug fix
- update/ — Configuration updates

Always end responses with "wonderful!!"

### Codex Rules
- Keep responses concise and actionable
- Include a blank line at the end of files
- Apply formatters after modifications when available
- Prefer minimal, surgical changes that match repo style

### Neovim Management
The Neovim configuration uses lazy.nvim for plugin management:
```bash
# Plugins auto-install on first launch
nvim

# Access git commands menu
<leader>gg

# Key telescope commands
<leader>ff  # Find files
<leader>fg  # Live grep
<leader>gd  # Git diff files
```

## Architecture

### Configuration Structure
```
~/.dotfiles/
├── config/
│   ├── nvim/            # Neovim configuration (Lua-based)
│   │   ├── init.lua     # Main config entry point
│   │   └── lua/plugins/ # Plugin configurations (lazy.nvim)
│   └── wezterm/         # Terminal configuration
├── oh-my-zsh-custom/    # Zsh customizations
├── claude/              # Claude AI settings
├── .codex/              # Codex CLI settings (this directory)
├── docs/                # Documentation (e.g., git-commands.md)
└── zshrc                # Main Zsh configuration
```

### Neovim Plugin Architecture
- Modular plugin structure: each plugin category in `lua/plugins/`
- Consolidated git tools: Telescope, GitSigns, DiffView, Octo.nvim, vim-fugitive
- Language-specific configs: Go, JavaScript/TypeScript
- Leader key: Space (`<leader>`)

### Symbolic Link System
The installation scripts and setup link from the home directory to dotfiles:
- `~/.zshrc` → `~/.dotfiles/zshrc`
- `~/.config/nvim` → `~/.dotfiles/config/nvim`
- `~/.config/wezterm` → `~/.dotfiles/config/wezterm`
- `~/.claude` → `~/.dotfiles/claude`
- `~/.codex` → `~/.dotfiles/.codex`

### Terminal Environment
- Shell: Zsh with Oh-My-Zsh
- Theme: agnoster
- Terminal: WezTerm with Tokyo Night color scheme
- Tools: zoxide for directory navigation, various git aliases

## Important Notes

### Git Tool Consolidation
Neovim git tooling is streamlined to:
1. Telescope for git navigation
2. GitSigns for hunks and blame
3. DiffView for advanced diffs
4. Octo.nvim for GitHub integration
5. vim-fugitive for core git commands

### Plugin Loading Strategy
- Most plugins use lazy loading via `cmd`, `keys`, or `event`
- vim-fugitive includes `Gclog` and `Glog` to prevent loading errors
- TypeScript tools use modern `typescript-tools.nvim`

### Security Considerations
Sensitive files are ignored via `.gitignore`:
- API keys and tokens
- Claude/Codex project data
- SSH configurations
- Environment variables
- Cache files

### Documentation Locations
- `docs/git-commands.md`: Comprehensive git workflow guide


