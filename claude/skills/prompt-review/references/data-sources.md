# AI Tool Data Sources

各AIツールの会話ログの場所とフォーマット。

## Claude Code (CLI / VS Code)

- **形式**: JSONL
- **場所**:
  - macOS: `~/.claude/projects/*/`
  - Linux: `~/.claude/projects/*/`
  - カスタム: `$CLAUDE_CONFIG_DIR/projects/*/`
- **ファイルパターン**: `*.jsonl`
- **構造**: 1行1JSON、`type` フィールドで区別
  - `type: "human"` → ユーザーメッセージ
  - `type: "assistant"` → AIレスポンス
- **タイムスタンプ**: `timestamp` フィールド (ISO 8601)

## GitHub Copilot Chat

- **形式**: SQLite (state.vscdb)
- **場所**:
  - macOS: `~/Library/Application Support/Code/User/globalStorage/github.copilot-chat/state.vscdb`
  - Linux: `~/.config/Code/User/globalStorage/github.copilot-chat/state.vscdb`
- **テーブル**: `ItemTable`
- **キー**: `chat.panel.conversations` (JSON文字列)
- **構造**: conversations[] → requests[] → message (ユーザー) / response[] (AI)

## Cline / Roo Code

- **形式**: JSON
- **場所**:
  - Cline macOS: `~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/tasks/*/`
  - Roo Code macOS: `~/Library/Application Support/Code/User/globalStorage/rooveterinaryinc.roo-cline/tasks/*/`
  - Linux: `~/.config/Code/User/globalStorage/` + 上記パス
- **ファイル**: `api_conversation_history.json`
- **構造**: メッセージ配列、`role: "user"` / `role: "assistant"`

## Windsurf (Cascade)

- **形式**: テキスト/メモリファイル
- **場所**:
  - macOS: `~/.codeium/windsurf/memories/`
  - Linux: `~/.codeium/windsurf/memories/`
- **構造**: テキストファイル、セクション区切り

## OpenAI Codex CLI

- **形式**: JSONL
- **場所**:
  - macOS: `~/.codex/sessions/` or `$CODEX_HOME/sessions/`
  - Linux: `~/.codex/sessions/` or `$CODEX_HOME/sessions/`
- **ファイルパターン**: `*.jsonl`
- **構造**: `role: "user"` / `role: "assistant"`

## 共通の注意事項

- ファイルパス中の個人名は `<user>` でマスク
- メッセージは500文字で切り詰め
- バイナリファイルやメディアファイルはスキップ
- SQLiteの読み取りはreadonly接続で行う
