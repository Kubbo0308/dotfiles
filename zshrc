export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(git docker brew github composer zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

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
# ルートユーザ
ZSH_HIGHLIGHT_STYLES[root]='bg=red'弧の色を変える

# zsh-autosuggestions color configuration
# Use a lighter gray for better visibility against dark backgrounds
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

# git alias
alias grsh='git reset --soft HEAD^'
alias gst='git status'
alias gl='git pull'
alias gp='git push'

# docker compose
alias dc='docker compose'

# other alias
alias v='nvim .'
alias c='claude'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/takesupasankyu/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/takesupasankyu/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/takesupasankyu/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/takesupasankyu/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

export PATH="$HOME/Downloads/google-cloud-sdk/bin:$PATH"

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

# Initialize zoxide
eval "$(zoxide init zsh)"

# bun completions
[ -s "/Users/y-kubo/.bun/_bun" ] && source "/Users/y-kubo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
