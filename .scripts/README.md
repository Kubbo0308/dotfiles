# PR Review Scripts

このディレクトリには、GitHub Pull Request のレビューを効率化するためのスクリプトが含まれています。

## pr-review-wezterm.zsh

WezTerm 内で3つのAIツール（Claude Code、Cursor Agent、Gemini CLI）を使用して、同時並行でPRレビューを実行するスクリプトです。

### 機能

- WezTerm を3つの垂直ペインに分割
- 各ペインで異なるAIツールを起動してPRレビューを実行
  - **左ペイン**: Claude Code
  - **中央ペイン**: Cursor Agent
  - **右ペイン**: Gemini CLI
- GitHub CLI (`gh`) を使用してPR情報を取得
- 日本語でのレビュー実行

### 前提条件

1. **WezTerm** がインストールされていること
2. **GitHub CLI (`gh`)** がインストールされ、認証済みであること
3. 以下のAIツールがインストールされていること（オプション）:
   - Claude Code (`claude` コマンド)
   - Cursor Agent (`cursor-agent` コマンド)
   - Gemini CLI (`gemini` コマンド)
4. `pr-review-prompt.md` ファイルが同じディレクトリに存在すること

### 使用方法

WezTerm 内で以下のコマンドを実行します：

```bash
# PRの番号のみを指定（現在のGitリポジトリから自動的にリポジトリ情報を取得）
./pr-review-wezterm.zsh 123

# PRの番号とリポジトリを指定
./pr-review-wezterm.zsh 123 owner/repo

# GitHub PR の URL を直接指定
./pr-review-wezterm.zsh https://github.com/owner/repo/pull/123
```

### 動作の流れ

1. PR番号とリポジトリ情報を解析
2. `pr-review-prompt.md` のテンプレートを読み込み
3. WezTerm の現在のペインを3つに垂直分割
4. 各ペインで対応するAIツールを起動
5. 各AIツールが以下のコマンドを実行してPRをレビュー:
   - `gh pr view` - PR の詳細情報を取得
   - `gh pr diff` - PR の差分を取得

### エラーハンドリング

- WezTerm 外で実行された場合はエラーを表示
- リポジトリ情報が取得できない場合は手動指定を要求
- AIツールが見つからない場合は、該当ペインにインストール方法を表示

### カスタマイズ

`pr-review-prompt.md` ファイルを編集することで、レビューのプロンプトをカスタマイズできます。

### トラブルシューティング

- **「Error: This script must be run from within WezTerm」が表示される場合**
  - WezTerm 内でスクリプトを実行してください

- **リポジトリが自動検出されない場合**
  - 第2引数として `owner/repo` 形式でリポジトリを指定してください

- **AIツールが起動しない場合**
  - 各ツールが正しくインストールされ、PATH に含まれていることを確認してください

### 注意事項

- このスクリプトは WezTerm 専用です
- 一時ファイルがセッション中に `/tmp` に作成されます
- 各AIツールのレスポンス時間は異なる場合があります