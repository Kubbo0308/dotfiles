# Custom Slash Commands

ユーザーが `/command-name` で呼び出せるカスタムスラッシュコマンド定義です。各 `.md` ファイルが1つのコマンドのプロンプトテンプレートを定義します。

## コマンド一覧 (38)

### 開発ワークフロー

| Command | 用途 |
|---------|------|
| `/sync-main` | main ブランチと同期 |
| `/add-feature` | 新機能追加 |
| `/bugfix` | バグ修正ワークフロー |
| `/fix-issue` | GitHub Issue 修正 |
| `/fix-ui` | UI バグ修正 |
| `/create-pr` | PR 作成 |
| `/mr` | 3モデル戦略並列コードレビュー |
| `/orchestrator` | チームベースタスクオーケストレーション |

### TDD ワークフロー

| Command | 用途 |
|---------|------|
| `/tdd-requirements` | 要件定義・機能仕様の整理 |
| `/tdd-testcases` | テストケース洗い出し |
| `/tdd-todo` | TDD TODO リスト作成 |
| `/tdd-load-context` | TDD 関連ファイル読み込み |
| `/tdd-red` | Red フェーズ（失敗するテスト） |
| `/tdd-green` | Green フェーズ（最小限の実装） |
| `/tdd-refactor` | Refactor フェーズ |
| `/tdd-verify-complete` | テストケース完全性検証 |

### Kairo ワークフロー

| Command | 用途 |
|---------|------|
| `/kairo-requirements` | 要件収集 |
| `/kairo-design` | ソリューション設計 |
| `/kairo-tasks` | タスク生成 |
| `/kairo-implement` | 実装 |
| `/kairo-task-verify` | タスク検証 |

### レビュー系

| Command | 用途 |
|---------|------|
| `/rev-requirements` | 要件レビュー |
| `/rev-design` | 設計レビュー |
| `/rev-specs` | 仕様レビュー |
| `/rev-tasks` | タスクレビュー |
| `/pr-review-respond` | PR レビューコメント対応 |
| `/geminiReview` | Gemini CLI コードレビュー |

### AI 連携

| Command | 用途 |
|---------|------|
| `/magi` | MAGI 集合意思決定システム |
| `/gemini` | Gemini CLI Web 検索 |

### ドキュメント・その他

| Command | 用途 |
|---------|------|
| `/explain-project` | プロジェクト構造説明 |
| `/feature-log` | 機能変更ログ作成 |
| `/blog` | ブログコンテンツ生成 |
| `/prompt-review` | AI 会話履歴分析 |
| `/ui-skills` | UI 開発スキル |
| `/serena` | Serena MCP コマンド |
| `/start-server` | 開発サーバー起動・管理 |
| `/direct-setup` | 直接セットアップ |
| `/direct-verify` | 直接検証 |

### シェルスクリプト

| File | 用途 |
|------|------|
| `tdd-cycle-full.sh` | TDD フルサイクル実行スクリプト |

## ファイル形式

各 `.md` ファイルはコマンド実行時に展開されるプロンプトテンプレートです。`$ARGUMENTS` プレースホルダーでユーザー引数を受け取れます。
