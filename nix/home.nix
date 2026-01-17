# home-manager configuration
# Manages user-specific configurations and dotfiles

{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "takesupasankyu";
  home.homeDirectory = "/Users/takesupasankyu";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # User packages (in addition to system packages)
  home.packages = with pkgs; [
    # Add user-specific packages here
  ];

  # Program configurations
  programs = {
    # Git configuration (updated for home-manager 24.11+)
    git = {
      enable = true;
      settings = {
        user.name = "takesupasankyu";
        # user.email = "your-email@example.com"; # Set your email
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };

    # Delta (git diff pager)
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };

    # Zoxide (smart cd)
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Fzf (fuzzy finder)
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Direnv (directory-based environment)
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Mise (runtime version manager)
    mise = {
      enable = true;
      enableZshIntegration = true;
    };

    # Starship prompt (optional, uncomment if you want to use it)
    # starship = {
    #   enable = true;
    #   enableZshIntegration = true;
    # };
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    LANG = "en_US.UTF-8";
  };

  # Shell aliases
  home.shellAliases = {
    # Nix
    nix-update = "cd ~/.dotfiles/nix && nix run .#update";
    nix-rebuild = "darwin-rebuild switch --flake ~/.dotfiles/nix";

    # Modern replacements
    ls = "eza";
    ll = "eza -la";
    la = "eza -a";
    lt = "eza --tree";
    cat = "bat";

    # Git shortcuts
    g = "git";
    gs = "git status";
    gd = "git diff";
    gl = "git log --oneline";
    gp = "git push";
    grsh = "git reset --soft HEAD^";

    # Docker
    dc = "docker compose";

    # Editor & Tools
    v = "nvim .";
    c = "claude";
  };
}
