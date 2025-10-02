# dotfiles

Git-managed configuration files with symbolic link setup for easy synchronization across machines.

## Structure

```
~/.dotfiles/
├── .homebrew/                   # Homebrew package management
│   ├── Brewfile                # Homebrew Bundle configuration
│   └── README.md               # Homebrew usage documentation
├── .scripts/                    # Shell scripts
│   ├── install.sh              # Installation script
│   ├── install-oh-my-zsh-plugins.sh # Oh My Zsh plugins installer
│   └── uninstall.sh            # Uninstallation script
├── claude/                      # Claude AI configuration (sensitive files ignored)
├── config/
│   ├── nvim/                   # Neovim configuration
│   └── wezterm/                # WezTerm terminal configuration
├── oh-my-zsh-custom/           # Oh My Zsh custom configurations
│   ├── themes/                 # Custom themes
│   ├── plugins.txt             # External plugins list
│   └── *.zsh                   # Custom zsh files
├── zshrc                       # Zsh shell configuration
├── .gitignore                  # Ignores sensitive files and cache
└── README.md                   # This file
```

## Quick Start

### One-Command Setup (Recommended)
For new machines, use the unified setup script that handles everything:

```bash
git clone <repository-url> ~/.dotfiles
~/.dotfiles/.scripts/setup-environment.sh
```

This will automatically:
- Install Homebrew (if not installed)
- Install all packages from Brewfile
- Install Oh-My-Zsh (if not installed)
- Create symbolic links for all dotfiles
- Set up MCP configurations

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

This will create symbolic links:
- `~/.zshrc` → `~/.dotfiles/zshrc`
- `~/.claude` → `~/.dotfiles/claude`
- `~/.config/wezterm` → `~/.dotfiles/config/wezterm`
- `~/.config/nvim` → `~/.dotfiles/config/nvim`

And install:
- Oh-My-Zsh customizations (themes, plugins)
- Homebrew packages from Brewfile

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

## Workflow

### Backup Current Configurations
Save your current system settings to the dotfiles repository:
```bash
~/.dotfiles/.scripts/sync-to-dotfiles.sh
cd ~/.dotfiles
git add .
git commit -m "update: sync configurations"
git push
```

### Restore Configurations
Restore dotfiles to your home directory:
```bash
~/.dotfiles/.scripts/restore-from-dotfiles.sh
```

### Update Dotfiles
Pull latest changes from the repository:
```bash
cd ~/.dotfiles
git pull
```
