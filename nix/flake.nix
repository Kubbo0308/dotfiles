{
  description = "Dotfiles managed by Nix (multi-machine support)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim nightly (optional, uncomment if needed)
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";

      # Dynamic username from environment variable (requires --impure flag)
      # Uses SUDO_USER when running with sudo, otherwise falls back to USER
      username = let
        sudoUser = builtins.getEnv "SUDO_USER";
        envUser = builtins.getEnv "USER";
      in if sudoUser != "" then sudoUser else (if envUser != "" then envUser else "user");

      # Dynamic hostname from environment variable (requires --impure flag)
      # Falls back to "darwin" if not set
      hostname = let
        envHost = builtins.getEnv "HOSTNAME";
        # Also try HOST if HOSTNAME is empty
        envHost2 = builtins.getEnv "HOST";
      in if envHost != "" then envHost else (if envHost2 != "" then envHost2 else "darwin");

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          # Allow specific unfree packages
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "vscode"
            "slack"
            "discord"
          ];
        };
      };

      # Shared darwin configuration
      darwinConfig = import ./nix-darwin/config.nix { inherit inputs pkgs username; };

      # Helper function to create darwin configuration
      mkDarwinConfig = { hostname, username }: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          darwinConfig
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home.nix;
              extraSpecialArgs = { inherit inputs username; };
              backupFileExtension = "backup";
            };
          }
        ];
      };
    in
    {
      # Dynamic nix-darwin configuration (use with --impure flag)
      # Usage: darwin-rebuild switch --flake .#darwin --impure
      darwinConfigurations.darwin = mkDarwinConfig { inherit hostname username; };

      # Standalone packages (for quick installs)
      packages.${system}.default = pkgs.buildEnv {
        name = "my-packages";
        paths = import ./pkgs.nix { inherit pkgs; };
      };

      # Update script (requires --impure for dynamic username)
      apps.${system}.update = {
        type = "app";
        program = toString (pkgs.writeShellScript "update" ''
          set -e
          echo "🔄 Updating flake inputs..."
          nix flake update

          echo "🍎 Rebuilding nix-darwin..."
          darwin-rebuild switch --flake .#darwin --impure

          echo "🍺 Updating Homebrew packages..."
          brew update && brew upgrade && brew cleanup

          echo "✅ All updates complete!"
        '');
      };

      # Formatter
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
