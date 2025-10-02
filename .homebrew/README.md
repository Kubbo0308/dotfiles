# Homebrew Configuration

This directory manages Homebrew packages, casks, and VS Code extensions using Homebrew Bundle.

## Usage

### Install all packages from Brewfile
```bash
brew bundle install --file=~/.dotfiles/.homebrew/Brewfile
```

### Update Brewfile with currently installed packages
```bash
brew bundle dump --file=~/.dotfiles/.homebrew/Brewfile --force
```

### Check what's missing
```bash
brew bundle check --file=~/.dotfiles/.homebrew/Brewfile
```

### Cleanup (remove packages not listed in Brewfile)
```bash
brew bundle cleanup --file=~/.dotfiles/.homebrew/Brewfile
```

## What's Included

- **CLI Tools**: Development tools and utilities (git, neovim, go, etc.)
- **Casks**: GUI applications (Cursor, Google Cloud CLI, fonts)
- **VS Code Extensions**: All installed VS Code extensions

## Notes

- The Brewfile is automatically generated and managed
- Run `brew bundle dump` to sync current installations to the Brewfile
- Commit the Brewfile to keep package installations synchronized across machines
