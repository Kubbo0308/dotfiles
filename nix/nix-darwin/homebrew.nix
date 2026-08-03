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
      # lockfiles removed: Homebrew Bundle dropped lockfile support in 4.4.0 (Oct 2024)
    };

    # Homebrew taps (fonts are now in main cask, no separate tap needed)
    taps = [
    ];

    # CLI tools not available in nixpkgs or with issues.
    # These MUST stay declared: cleanup = "uninstall" removes any brew-managed
    # formula that is not listed here, along with its dependencies.
    brews = [
      "cocoapods" # Expo/React Native iOS builds
      "imagemagick" # app-store screenshot pipeline
      "terraform" # infra/
      "ffmpeg"
      "flyctl"
    ];

    # GUI applications (casks)
    # Terminal is cmux, which ships its own embedded Ghostty — neither the
    # ghostty nor the wezterm cask is installed on purpose.
    casks = [
      # Development
      "visual-studio-code"
      "cursor"
      "drawio"
      # claude-code is intentionally absent: the CLI in use is the npm install
      # at ~/.npm-global/bin/claude, reached via cmux's wrapper. The brew cask
      # sat third in PATH behind both, so it was never executed.
      "tableplus"

      # Cloud Tools
      "gcloud-cli" # renamed from google-cloud-sdk

      # Utilities
      "raycast"
      "voiceink"

      # Fonts (Nerd Fonts for terminal)
      "font-plemol-jp"
      "font-plemol-jp-nf"
      "font-plemol-jp-hs"
      "font-ricty-diminished"
      "font-hack-nerd-font"
      "font-sf-mono-nerd-font-ligaturized"
    ];

    # caskArgs.no_quarantine removed: current Homebrew rejects it with
    # "invalid option: --no_quarantine", which fails every new cask install.
  };
}
