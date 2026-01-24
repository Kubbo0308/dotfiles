# Nix initialization (must be at the top)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# nix-darwin environment (includes home-manager aliases)
if [ -e '/etc/static/zshenv' ]; then
  . '/etc/static/zshenv'
fi
if [ -e '/etc/static/zshrc' ]; then
  . '/etc/static/zshrc'
fi

# Docker Desktop CLI (must be before oh-my-zsh for docker plugin)
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git docker brew github zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

source $ZSH/oh-my-zsh.sh

ZSH_HIGHLIGHT_HIGHTLIGHTERS=(main brackets cursor root)
## 連想配列
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
# Use a lighter gray for better visibility against dark backgrounds
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

# Aliases are managed by Nix home-manager (see nix/home.nix)

# The next line updates PATH for the Google Cloud SDK.
GCP_SDK_PATH="${GCP_SDK_PATH:-/opt/homebrew/share/google-cloud-sdk}"
if [ -f "$GCP_SDK_PATH/path.zsh.inc" ]; then . "$GCP_SDK_PATH/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$GCP_SDK_PATH/completion.zsh.inc" ]; then . "$GCP_SDK_PATH/completion.zsh.inc"; fi

export PATH="$GCP_SDK_PATH/bin:$PATH"

if [ -f "$HOME/.local/bin/env" ]; then . "$HOME/.local/bin/env"; fi

# ファイルの内容をクリップボードにコピーする関数
# 例: ccopy my_document.txt
ccopy() {
  if [ -f "$1" ]; then
    cat "$1" | pbcopy
    echo "'$1' の内容をクリップボードにコピーしました。"
  else
    echo "エラー: ファイル '$1' が見つからないか、有効なファイルではありません。"
  fi
}

# zoxide is initialized by Nix home-manager

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Go environment
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# mise is managed by Nix home-manager (see nix/home.nix)

# Added by Antigravity
export PATH="/Users/takesupasankyu/.antigravity/antigravity/bin:$PATH"
