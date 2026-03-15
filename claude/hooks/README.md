# Claude Code Hooks

Claude Code のライフサイクルフックを管理するディレクトリです。`settings.json` の `hooks` セクションで設定されています。

## フック一覧 (11 scripts)

### セキュリティ (PreToolUse)

| Script | Matcher | 用途 |
|--------|---------|------|
| `detect-secrets.sh` | `Edit\|Write` | ハードコードされたシークレット・APIキーの検出 |
| `detect-env-exfiltration.sh` | `Edit\|Write` | 環境変数の外部送信パターン検出 |
| `protect-files.sh` | `Edit\|Write` | `.env`、鍵ファイル等の機密ファイル編集ブロック |
| `protect-linter-config.sh` | `Edit\|Write` | リンター・フォーマッター設定ファイルの保護 |
| `block-dangerous-commands.sh` | `Bash` | 危険なシェルコマンドのブロック |
| `mcp-guard.sh` | `mcp__filesystem__*` | MCP 経由の機密ディレクトリ書き込みブロック |

### 品質管理 (PostToolUse)

| Script | Matcher | 用途 |
|--------|---------|------|
| `post-edit-lint.sh` | `Write\|Edit` | ファイル編集後の自動リント (Go/TS/Shell/Nix) |
| `package-audit.sh` | `Bash` | パッケージインストール後のセキュリティ監査警告 |

### ライフサイクル

| Script | Event | 用途 |
|--------|-------|------|
| `on-clear.sh` | `SessionStart:clear` | `/clear` 後に `/sync-main` を促す |
| `pre-compact.sh` | `PreCompact` | コンパクション前の重要コンテキスト保存 |
| `agent-logger.sh` | `SubagentStart/Stop`, `WorktreeRemove` | エージェント活動のログ記録 |

### 共有ライブラリ

| File | 用途 |
|------|------|
| `lib/file-guard.sh` | フック共通ヘルパー（stdin パース、ファイルパス抽出） |

## Prompt Hooks (settings.json 内で定義)

スクリプトファイルではなく `settings.json` 内にインラインで定義されたプロンプトフック:

| Event | 用途 |
|-------|------|
| `PreToolUse:Edit\|Write` | セキュリティ脆弱性の AI レビュー |
| `Stop` | `/simplify` 実行チェック |
| `TaskCompleted` | タスク完了検証 |
| `TeammateIdle` | 未処理タスクの確認 |

## イベントフロー

```
SessionStart → on-clear.sh (clear時) / serena-wrapper.sh (常時)
    ↓
PreToolUse → security checks (Edit/Write/Bash/MCP)
    ↓
PostToolUse → auto-lint (Edit/Write) / package-audit (Bash)
    ↓
SubagentStart/Stop → agent-logger.sh
    ↓
PreCompact → pre-compact.sh
    ↓
Stop → /simplify check + notification
```

## セットアップ

フック設定は `settings.json` に含まれています。新しいマシンでは `settings.json` をセットアップしてください（シンボリンク経由で自動反映）。
