# Subagent Definitions

Claude Code のサブエージェント定義ファイル群です。各 `.md` ファイルが1つのサブエージェントのシステムプロンプトを定義します。

## エージェント一覧 (29)

### 開発系

| Agent | 用途 |
|-------|------|
| `go-developer` | Go 開発アシスタント (DDD, Echo) |
| `typescript-developer` | TypeScript 開発アシスタント |
| `document` | ドキュメント生成 |
| `drawio-diagram-generator` | draw.io ダイアグラム生成 |

### レビュー系

| Agent | 用途 |
|-------|------|
| `review` | Claude ネイティブ深層レビュー |
| `code-reviewer-gemini` | Gemini による最新ベストプラクティスレビュー |
| `codex-reviewer` | OpenAI Codex によるバグ・セキュリティレビュー |
| `code-reviewer-cursor` | Cursor Agent レビュー |
| `go-reviewer` | Go イディオマティックレビュー |
| `typescript-reviewer` | TypeScript/React レビュー |
| `terraform-reviewer` | Terraform レビュー |
| `dbt-reviewer` | dbt SQL レビュー |
| `markdown-reviewer` | Markdown ドキュメントレビュー |
| `clean-code-fp-reviewer` | クリーンコード & FP レビュー |

### テスト系

| Agent | 用途 |
|-------|------|
| `test` | テスト生成・カバレッジ改善 |
| `typescript-test-generator` | TypeScript/React テスト生成 (Jest, RTL) |

### ワークフロー系

| Agent | 用途 |
|-------|------|
| `commit` | Git コミット作成 |
| `pull-request` | PR 作成 |
| `pre-commit-checker` | コミット前差分レビュー |
| `task-decomposer` | タスク分解・TODO 作成 |
| `serena-context` | Serena MCP コンテキスト管理 |
| `github-analyzer` | GitHub Issue/PR 分析 |

### 分析・リサーチ系

| Agent | 用途 |
|-------|------|
| `codebase-analyzer` | Serena MCP によるコード分析 |
| `gemini-search` | Gemini CLI Web 検索 |
| `web-researcher` | マルチモデルリサーチ (Claude + Gemini + Codex) |
| `security` | セキュリティ脆弱性分析 |

### MAGI System

| Agent | 役割 |
|-------|------|
| `magi-melchior` | 科学的・論理的分析 |
| `magi-balthasar` | 実装・実用性重視 |
| `magi-casper` | リスク評価・慎重派 |

## ファイル形式

各 `.md` ファイルはサブエージェントのシステムプロンプトを含みます。`settings.json` の `agents` セクションまたは Agent ツールの `subagent_type` パラメータで参照されます。

## 使い方

```
# Agent ツールから直接呼び出し
Agent(subagent_type="go-developer", prompt="...")

# /mr コマンドで3モデル並列レビュー
/mr
```
