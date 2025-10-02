# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **dotfiles repository** that manages personal development environment configurations through Git and symbolic links. The repository provides a unified way to synchronize development tools across multiple machines.

## Development Commands

### Installation & Setup
```bash
# Initial installation
~/.dotfiles/.scripts/install.sh

# Install Oh-My-Zsh plugins
~/.dotfiles/.scripts/install-oh-my-zsh-plugins.sh

# Update dotfiles
cd ~/.dotfiles && git pull

# Remove dotfiles (cleanup)
~/.dotfiles/.scripts/uninstall.sh
```

### Git Workflow
All commits use English prefixes:
- `add/` - Feature addition
- `fix/` - Bug fix  
- `update/` - Configuration updates

Always end responses with "wonderful!!"

### Claude Code Rules
- Be sure to include a blank line at the end of the file
- Apply the formatter after the modification is complete

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
│   ├── nvim/          # Neovim configuration (Lua-based)
│   │   ├── init.lua   # Main config entry point
│   │   └── lua/plugins/  # Plugin configurations (lazy.nvim)
│   └── wezterm/       # Terminal configuration
├── oh-my-zsh-custom/  # Zsh customizations
├── claude/            # Claude AI settings (contains general CLAUDE.md)
├── docs/              # Documentation (git-commands.md)
└── zshrc             # Main Zsh configuration
```

### Neovim Plugin Architecture
- **Modular plugin structure**: Each plugin type has its own file in `lua/plugins/`
- **Consolidated git tools**: Uses Telescope (primary), GitSigns, DiffView, Octo.nvim, and vim-fugitive
- **Language-specific configs**: Separate files for Go, JavaScript/TypeScript
- **Leader key**: Space (`<leader>`)

### Key Plugin Categories
- **git.lua**: Git workflow tools (GitSigns, vim-fugitive, DiffView, Octo.nvim, git-blame)
- **telescope.lua**: Fuzzy finder with custom git diff picker and commands menu
- **lsp.lua**: Language server configurations  
- **go.lua**: Go development tools
- **javascript.lua**: TypeScript/JavaScript tools (uses typescript-tools.nvim)
- **colorscheme.lua**: VSCode theme configuration

### Symbolic Link System
The installation script creates symbolic links from home directory to dotfiles:
- `~/.zshrc` → `~/.dotfiles/zshrc`
- `~/.config/nvim` → `~/.dotfiles/config/nvim`
- `~/.config/wezterm` → `~/.dotfiles/config/wezterm`
- `~/.claude` → `~/.dotfiles/claude`

### Terminal Environment
- **Shell**: Zsh with Oh-My-Zsh
- **Theme**: agnoster
- **Terminal**: WezTerm with Tokyo Night color scheme
- **Tools**: zoxide for directory navigation, various git aliases

## Important Notes

### Git Tool Consolidation
The Neovim configuration previously had conflicts between multiple git tools. It's now streamlined to use:
1. **Telescope** for git navigation
2. **GitSigns** for hunks and blame  
3. **DiffView** for advanced diffs
4. **Octo.nvim** for GitHub integration
5. **vim-fugitive** for core git commands

### Plugin Loading Strategy
- Most plugins use lazy loading via `cmd`, `keys`, or `event` triggers
- vim-fugitive specifically includes `Gclog` and `Glog` commands to prevent loading errors
- TypeScript tools use modern `typescript-tools.nvim` instead of deprecated `typescript.nvim`

### Security Considerations
Sensitive files are ignored via `.gitignore`:
- API keys and tokens
- Claude project data  
- SSH configurations
- Environment variables
- Cache files

### Documentation Locations
- `docs/git-commands.md`: Comprehensive git workflow guide
- `config/nvim/*.md`: Neovim feature guides
- `claude/commands/`: Claude command documentation