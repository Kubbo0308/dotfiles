# nix-darwin configuration hub
# Imports all darwin-specific configurations

{ inputs, pkgs, username, ... }:

{
  imports = [
    ./system.nix
    ./homebrew.nix
  ];

  # Primary user for user-specific settings (required for nix-darwin)
  system.primaryUser = username;

  # Disable nix-darwin's Nix management (using Determinate Nix)
  nix.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (available to all users)
  environment.systemPackages = import ../pkgs.nix { inherit pkgs; };

  # Enable Touch ID for sudo (new option name)
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # System state version
  system.stateVersion = 5;
}
