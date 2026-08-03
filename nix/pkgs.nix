# CLI packages managed by Nix
# Add packages here that are available in nixpkgs
# Search packages at: https://search.nixos.org/packages

{ pkgs }:

with pkgs; [
  # Shell & Terminal
  zsh
  tmux
  zoxide
  fzf
  ripgrep
  fd
  eza
  bat
  jq
  yq
  carapace

  # Git & Version Control
  git
  gh
  lazygit
  delta

  # Development Tools
  neovim
  direnv

  # Languages & Runtimes
  go
  nodejs_24
  python3
  rustup

  # Node.js Tools (migrated from npm global)
  pnpm
  yarn
  prettier # was nodePackages.prettier; the nodePackages set was removed from nixpkgs
  typescript
  typescript-language-server
  eslint_d

  # AI CLI Tools
  gemini-cli
  # codex - managed via npm global (@openai/codex) for faster updates

  # Build Tools
  gnumake
  cmake

  # Network & HTTP
  curl
  wget
  httpie

  # Cloud & Infrastructure
  # Moved off the gcloud-cli cask: that cask is auto_updates, so brew never
  # upgraded it (stuck at 552.0.0), and its python@3.14 dependency made
  # `brew bundle cleanup` propose removals that `brew uninstall` then refused
  # on every activation. Extra components now need withExtraComponents.
  google-cloud-sdk
  # awscli2
  # terraform
  # kubectl

  # Database
  turso-cli

  # Misc Utilities
  tree
  htop
  watch
  tldr
]
