# Claude Code Hooks

Claude Codeのフック設定を管理するディレクトリです。

## セットアップ

`settings.json` は機密情報を含む可能性があるため `.gitignore` で除外されています。
新しいマシンでセットアップする場合は、以下の設定を `~/.claude/settings.json` に手動で追加してください。

### hooks 設定の追加

`~/.claude/settings.json` に以下を追加:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "clear",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/on-clear.sh"
          }
        ]
      }
    ]
  }
}
```

既存の settings.json がある場合は、`hooks` キーをマージしてください。

## 利用可能なフック

### on-clear.sh

`/clear` コマンド実行時に自動で発火するフックです。

**機能:**
- セッション開始時に `/sync-main` を実行するよう促すコンテキストを注入
- main ブランチとの同期を促すことで、クリーンな状態で新しいセッションを開始

**関連コマンド:**
- `/sync-main` - 変更を処理してmainブランチに同期

## ワークフロー

1. 作業完了後、`/clear` を実行
2. フックが発火し、Claude が `/sync-main` の実行を提案
3. 変更を stash/commit した後、main ブランチに同期
4. クリーンな状態で新しいセッションを開始
