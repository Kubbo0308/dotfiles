# Scripts Directory

このディレクトリには、dotfiles環境の管理とセットアップに関するスクリプトが含まれています。

## 🚀 環境セットアップスクリプト

### setup-environment.sh
**全環境を一括でセットアップする統合スクリプト**

新しいマシンで開発環境を構築する際に、このスクリプト1つで全てをセットアップできます。

```bash
~/.dotfiles/.scripts/setup-environment.sh
```

**実行内容:**
1. Homebrewのインストール（未インストールの場合）
2. Brewfileからパッケージをインストール
3. Oh-My-Zshのインストール（未インストールの場合）
4. dotfilesのシンボリックリンク作成
5. シェル設定の適用

### install.sh
**dotfilesのシンボリックリンクを作成するスクリプト**

```bash
~/.dotfiles/.scripts/install.sh
```

**機能:**
- `~/.zshrc` → `~/.dotfiles/zshrc` のシンボリックリンク作成
- `~/.config/nvim` → `~/.dotfiles/config/nvim` のシンボリックリンク作成
- Oh-My-Zshプラグインのインストール
- MCPコンフィグのセットアップ
- Homebrewパッケージのインストール

### install-oh-my-zsh-plugins.sh
**Oh-My-Zshプラグインを個別にインストール**

```bash
~/.dotfiles/.scripts/install-oh-my-zsh-plugins.sh
```

### uninstall.sh
**dotfilesのシンボリックリンクを削除**

```bash
~/.dotfiles/.scripts/uninstall.sh
```

## 🔄 バックアップ・同期スクリプト

### sync-to-dotfiles.sh
**現在のシステム設定をdotfilesリポジトリにバックアップ**

システムの設定ファイルをdotfilesリポジトリに同期します。設定を変更した後、リポジトリに反映させたい場合に使用します。

```bash
~/.dotfiles/.scripts/sync-to-dotfiles.sh
```

**同期される項目:**
- `.zshrc`
- `.config/nvim`
- `.config/wezterm`
- `.claude/settings.json`
- `.claude/CLAUDE.md`
- `.claude/commands`
- `.claude/agents`
- Brewfile（現在のインストール状況を反映）

### restore-from-dotfiles.sh
**dotfilesリポジトリからシステムに設定を復元**

dotfilesリポジトリの内容を`$HOME`にコピーして復元します。

```bash
~/.dotfiles/.scripts/restore-from-dotfiles.sh
```

## 🔧 その他のツール

### pr-review-wezterm.zsh
**GitHub Pull Requestの並列AIレビュー**

WezTerm内で3つのAIツール（Claude Code、Cursor Agent、Gemini CLI）を使用して、同時並行でPRレビューを実行します。

```bash
~/.dotfiles/.scripts/pr-review-wezterm.zsh 123
```

詳細は以前のREADME内容を参照してください。

## 📝 使用フロー

### 新しいマシンでのセットアップ
```bash
# 1. dotfilesリポジトリをクローン
git clone <repository-url> ~/.dotfiles

# 2. 統合セットアップスクリプトを実行
~/.dotfiles/.scripts/setup-environment.sh

# 3. ターミナルを再起動
```

### 設定変更後のバックアップ
```bash
# 1. 現在の設定をdotfilesに同期
~/.dotfiles/.scripts/sync-to-dotfiles.sh

# 2. 変更を確認してコミット
cd ~/.dotfiles
git status
git add .
git commit -m "update: sync configurations"
git push
```

### 別マシンでの設定復元
```bash
# 1. dotfilesをクローン
git clone <repository-url> ~/.dotfiles

# 2. 設定を復元
~/.dotfiles/.scripts/restore-from-dotfiles.sh

# 3. 不足しているパッケージをインストール
~/.dotfiles/.scripts/setup-environment.sh
```

## ⚙️ カスタマイズ

各スクリプトは環境変数で動作をカスタマイズできます:

```bash
# dotfilesディレクトリのパスを変更
export DOTFILES_DIR="$HOME/my-custom-dotfiles"

# スクリプトを実行
~/.dotfiles/.scripts/setup-environment.sh
```
