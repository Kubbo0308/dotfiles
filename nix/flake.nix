{
  description = "takesupasankyu's dotfiles managed by Nix";

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
      hostname = "kubbo-set";
      username = "takesupasankyu";

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
    in
    {
      # nix-darwin configuration
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          darwinConfig
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home.nix;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };

      # Standalone packages (for quick installs)
      packages.${system}.default = pkgs.buildEnv {
        name = "my-packages";
        paths = import ./pkgs.nix { inherit pkgs; };
      };

      # Update script
      apps.${system}.update = {
        type = "app";
        program = toString (pkgs.writeShellScript "update" ''
          set -e
          echo "🔄 Updating flake inputs..."
          nix flake update

          echo "🍎 Rebuilding nix-darwin..."
          darwin-rebuild switch --flake .#${hostname}

          echo "🍺 Updating Homebrew packages..."
          brew update && brew upgrade && brew cleanup

          echo "✅ All updates complete!"
        '');
      };

      # Formatter
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
