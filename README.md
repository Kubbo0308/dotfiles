# dotfiles

Git-managed configuration files with symbolic link setup for easy synchronization across machines.

## Structure

```
~/.dotfiles/
├── .homebrew/                   # Homebrew package management
│   ├── Brewfile                # Homebrew Bundle configuration
│   └── README.md               # Homebrew usage documentation
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
├── install.sh                  # Installation script
├── install-oh-my-zsh-plugins.sh # Oh My Zsh plugins installer
├── uninstall.sh                # Uninstallation script
└── README.md                   # This file
```

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/.dotfiles
   ```

2. Run the installation script:
   ```bash
   ~/.dotfiles/install.sh
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
~/.dotfiles/uninstall.sh
```

## Updates

To update your dotfiles:
```bash
cd ~/.dotfiles
git pull
```
