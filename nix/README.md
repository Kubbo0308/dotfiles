# Nix Configuration

macOS環境をNixで宣言的に管理するための設定ファイル群です。

## ディレクトリ構成

```
nix/
├── flake.nix           # メインエントリーポイント
├── flake.lock          # 依存関係のロックファイル
├── pkgs.nix            # CLIパッケージ一覧
├── home.nix            # home-manager設定
└── nix-darwin/
    ├── config.nix      # nix-darwin設定ハブ
    ├── system.nix      # macOSシステム設定
    └── homebrew.nix    # Homebrew (GUIアプリ/フォント)
```

## 初回セットアップ

### 1. Nixのインストール（未インストールの場合）

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. nix-darwinの初回ビルド

```bash
cd ~/.dotfiles/nix

# flake.lockを生成
nix flake update

# nix-darwinをビルド・適用
nix run nix-darwin -- switch --flake .#kubbo-set
```

### 3. 以降の更新

```bash
# 全て更新（flake + darwin-rebuild + homebrew）
nix run .#update

# または手動で
darwin-rebuild switch --flake ~/.dotfiles/nix
```

## パッケージの追加

### CLIツール（nixpkgs）

1. https://search.nixos.org/packages でパッケージを検索
2. `pkgs.nix` に追加
3. `darwin-rebuild switch --flake ~/.dotfiles/nix`

### GUIアプリ（Homebrew）

1. `nix-darwin/homebrew.nix` の `casks` に追加
2. `darwin-rebuild switch --flake ~/.dotfiles/nix`

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `nix run .#update` | 全て更新 |
| `darwin-rebuild switch --flake .` | nix-darwinを再ビルド |
| `nix flake update` | flake入力を更新 |
| `nix store gc` | 古いビルド成果物を削除 |

## カスタマイズ

### システム設定

`nix-darwin/system.nix` でmacOSの設定を宣言的に管理:

- Dockの表示設定
- Finderの表示オプション
- キーボード・トラックパッド設定
- ホットコーナー設定

### home-manager

`home.nix` でユーザー固有の設定を管理:

- シェルエイリアス
- 環境変数
- プログラム設定（git, zoxide, fzf等）

## 参考記事

- [CLIツールをHomebrewからNixに移行した](https://zenn.dev/kawarimidoll/articles/0a4ec8bab8a8ba)
- [怠惰なHomebrewユーザーでもNixを使いたい!!](https://zenn.dev/smartcamp/articles/c6d174580a54d5)
