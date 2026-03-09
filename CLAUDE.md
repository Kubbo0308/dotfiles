# CLAUDE.md

Dotfiles repository managing dev environment configs via Git and symlinks.

## Commands

```bash
~/.dotfiles/.scripts/setup-environment.sh  # Full setup (new machines)
~/.dotfiles/.scripts/install.sh            # Dotfiles only
~/.dotfiles/.scripts/sync-to-dotfiles.sh   # Backup configs to repo
~/.dotfiles/.scripts/restore-from-dotfiles.sh  # Restore from repo
```

## Rules

- Git commits use English prefixes: `add/`, `fix/`, `update/`
- Always end responses with "wonderful!!"
- Include a blank line at the end of files
- Apply the formatter after modifications

## Structure

```
~/.dotfiles/
├── config/nvim/       # Neovim (lazy.nvim, lua/plugins/)
├── config/ghostty/    # Terminal config
├── oh-my-zsh-custom/  # Zsh customizations
├── claude/            # Claude Code config (symlinked as ~/.claude)
└── zshrc              # Main Zsh configuration
```

Symlinks: `~/.zshrc`, `~/.config/nvim`, `~/.claude` → dotfiles

## Security Rules (MANDATORY)

### Absolute Prohibitions
1. NEVER send bulk environment variables to external URLs/APIs
2. NEVER log full request/response bodies in production code
3. NEVER install packages without running npm audit and verifying registry stats
4. NEVER blindly copy patterns from cloned repos without checking for obfuscated code, encoded strings, or hidden external endpoints

### Before Adding Dependencies
- Run `npm audit` after every package addition
- Verify package registry stats (downloads, maintainers, last update)
- Check for suspicious postinstall scripts or top-level side effects

### Code Review Checklist
- No bulk env access sent externally
- No hardcoded unknown URLs or Base64 in network code
- No eval()/new Function() with untrusted input
- Logging does not expose sensitive data
- No suspicious packages in require()/import
