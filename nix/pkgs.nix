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
  nodePackages.prettier
  typescript
  typescript-language-server
  eslint_d

  # AI CLI Tools
  gemini-cli
  codex

  # Build Tools
  gnumake
  cmake

  # Network & HTTP
  curl
  wget
  httpie

  # Cloud & Infrastructure
  # awscli2
  # terraform
  # kubectl

  # Misc Utilities
  tree
  htop
  watch
  tldr
]
