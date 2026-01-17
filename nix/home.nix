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
    # Zsh configuration (required for shellAliases to work)
    zsh = {
      enable = true;
      shellAliases = {
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

      # Oh-My-Zsh configuration
      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        custom = "$HOME/.oh-my-zsh/custom";
        plugins = [ "git" "docker" "brew" "github" "zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" ];
      };

      # Additional zsh configuration (from old zshrc)
      initExtra = ''
        # ZSH Syntax Highlighting configuration
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor root)

        # 連想配列
        typeset -A ZSH_HIGHLIGHT_STYLES
        # ブラケット
        # マッチしない括弧
        ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red,bold'
        # 括弧の階層
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow,bold'
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=cyan,bold'
        # カーソルがある場所にマッチする括弧
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'
        # カーソル
        ZSH_HIGHLIGHT_STYLES[cursor]='bg=blue'
        # ルートユーザーの色を変える
        ZSH_HIGHLIGHT_STYLES[root]='bg=red'

        # zsh-autosuggestions color configuration
        export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

        # Google Cloud SDK
        GCP_SDK_PATH="''${GCP_SDK_PATH:-$HOME/Downloads/google-cloud-sdk}"
        if [ -f "$GCP_SDK_PATH/path.zsh.inc" ]; then . "$GCP_SDK_PATH/path.zsh.inc"; fi
        if [ -f "$GCP_SDK_PATH/completion.zsh.inc" ]; then . "$GCP_SDK_PATH/completion.zsh.inc"; fi
        export PATH="$GCP_SDK_PATH/bin:$PATH"

        # Uv environment
        if [ -f "$HOME/.local/bin/env" ]; then . "$HOME/.local/bin/env"; fi

        # ファイルの内容をクリップボードにコピーする関数
        ccopy() {
          if [ -f "$1" ]; then
            cat "$1" | pbcopy
            echo "'$1' の内容をクリップボードにコピーしました。"
          else
            echo "エラー: ファイル '$1' が見つからないか、有効なファイルではありません。"
          fi
        }

        # bun completions
        [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

        # bun
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        export PATH="$HOME/.local/bin:$PATH"

        # Go environment
        export GOPATH="$HOME/go"
        export PATH="$GOPATH/bin:$PATH"

        # Antigravity
        export PATH="/Users/takesupasankyu/.antigravity/antigravity/bin:$PATH"
      '';
    };

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

}
