# Agent Team Definitions

タスクカテゴリ別にチーム構成・ワークフロー・役割を YAML で定義し、再利用可能にするための定義ファイル群です。

## 3-Model Strategy

レビュー・調査系のチームでは **3社の AI プロバイダ** の強みを活かした役割分担を採用しています:

| Provider | Strength | Review Focus | Research Focus |
|----------|----------|-------------|----------------|
| **Claude** (Anthropic) | 深い推論、長コンテキスト | 設計・アーキテクチャ・ロジック | 技術ドキュメント分析・コード理解 |
| **Gemini** (Google) | Google Search grounding | 最新ベストプラクティス・非推奨検出 | リアルタイムWeb検索・最新情報 |
| **Codex/GPT** (OpenAI) | パターンマッチング | バグパターン・セキュリティ脆弱性 | GitHub実例・コードパターン |

## ファイル一覧

| ファイル | カテゴリ | 用途 |
|----------|----------|------|
| `feature.yaml` | 機能追加 | 新機能の分析・設計・実装・レビュー |
| `bugfix.yaml` | バグ修正 | 調査・再現・修正・検証 |
| `refactoring.yaml` | リファクタリング | 品質監査・計画・テスト・リファクタ・レビュー |
| `review.yaml` | コードレビュー | `/mr` コマンドの構造化版。3モデル戦略並列レビュー |

## YAML スキーマ

```yaml
name: string              # チーム識別子 (kebab-case)
description: string       # 目的
category: string          # feature | bugfix | refactoring | review

lead:                     # チームリーダー
  name: string
  subagent_type: string   # claude/agents/<name>.md に対応
  role: string
  responsibilities: [string]

members:                  # チームメンバー
  - name: string
    subagent_type: string
    role: string
    responsibilities: [string]
    condition: string     # "always" | "language:go" | "language:typescript"

language_variants:        # 言語別 subagent_type 差し替え
  go:
    replacements:
      - base_name: string       # members の name
        subagent_type: string   # 差し替え先エージェント
  typescript:
    replacements:
      - base_name: string
        subagent_type: string

workflow:
  steps:
    - name: string
      description: string
      execution: "sequential" | "parallel"
      tasks:
        - name: string
          assigned_to: string     # member name または lead name
          description: string
          inputs: [string]
          outputs: [string]

completion:
  required_outputs: [string]
  quality_gates: [string]
```

## 使い方

### 1. Orchestrator からの利用

`/orchestrator` コマンド実行時、orchestrator が以下の手順でチーム定義を活用します:

1. `claude/teams/<category>.yaml` を Read で読み込み
2. 言語検出（git diff のファイル拡張子 / `go.mod` / `package.json`）
3. `condition` フィルタリングと `language_variants` 適用
4. `TeamCreate` → `TaskCreate`（依存関係付き）→ `Task` で Teammate をスポーン

### 2. 言語検出ロジック

| 検出対象 | Go | TypeScript |
|----------|-----|-----------|
| ファイル拡張子 | `.go` | `.ts`, `.tsx`, `.js`, `.jsx` |
| プロジェクトファイル | `go.mod` | `package.json` |

### 3. condition フィールド

- `"always"` — 常にチームに参加
- `"language:go"` — Go ファイルが検出された場合のみ
- `"language:typescript"` — TypeScript/JavaScript ファイルが検出された場合のみ

### 4. language_variants 適用

言語が検出された場合、`replacements` に記載された `base_name` に該当するメンバーの `subagent_type` を差し替えます。

例: Go プロジェクトの場合、`developer` メンバーの `subagent_type` が `general-purpose` → `go-developer` に変更されます。

## `/mr` コマンドとの関係

`review.yaml` は `/mr` コマンドの構造化版です。`/mr` は引き続き直接使用可能で、`review.yaml` はチームベースのオーケストレーションで使用されます。

両方とも **3-Model Strategy** (Claude/Gemini/Codex) に基づいて動作します。
