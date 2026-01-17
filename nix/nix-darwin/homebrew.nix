# Homebrew configuration for nix-darwin
# Manages GUI applications and packages not available in nixpkgs

{ pkgs, ... }:

{
  # Enable Homebrew management
  homebrew = {
    enable = true;

    # Automatically update Homebrew
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall"; # Less aggressive than "zap"
    };

    # Global Homebrew configuration
    global = {
      brewfile = true;
      lockfiles = false;
    };

    # Homebrew taps (fonts are now in main cask, no separate tap needed)
    taps = [
    ];

    # CLI tools not available in nixpkgs or with issues
    brews = [
      # Add brew packages here if needed
    ];

    # GUI applications (casks)
    casks = [
      # Development
      "wezterm"
      "visual-studio-code"
      "cursor"
      "orbstack"
      "drawio"
      "claude-code"

      # Cloud Tools
      "google-cloud-sdk"

      # Utilities
      "raycast"

      # Fonts (Nerd Fonts for terminal)
      "font-plemol-jp"
      "font-plemol-jp-nf"
      "font-plemol-jp-hs"
      "font-ricty-diminished"
      "font-hack-nerd-font"
      "font-sf-mono-nerd-font-ligaturized"
    ];

    # Disable quarantine for fonts
    caskArgs.no_quarantine = true;
  };
}
