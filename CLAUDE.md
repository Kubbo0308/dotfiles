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

## Learned Lessons (auto-maintained by harness — additive only)

Project-specific lessons captured by `/reflect` land here. See `claude/harness/README.md`.

<!-- HARNESS:LESSONS:START -->
- nix-darwin homebrew.nix: a `brew bundle cleanup` dry-run taken BEFORE activation cannot predict what cleanup will actually do — onActivation runs autoUpdate/upgrade and installs newly-declared casks first, which changes the dependency graph cleanup then evaluates (e.g. installing the renamed gcloud-cli made mpdecimal/readline/sqlite required, and an ffmpeg upgrade pulled in sdl3). Treat the dry-run as indicative only. Also: a tap-scoped cask (`owner/tap/name`) is a DIFFERENT identity from the public cask (`name`) — declaring the bare name does not cover it, and an empty `taps` list makes every tap-scoped install a removal candidate. Reconcile `brew list --cask --full-name` against the declaration, not the short names. (learned 2026-08-03)
<!-- HARNESS:LESSONS:END -->
