# Development Skills

Claude Code のスキル定義ディレクトリです。各サブディレクトリが1つのスキルを定義し、`skill.md` にスキルの内容が記述されています。

## スキル一覧 (18)

### コーディング原則

| Skill | 用途 |
|-------|------|
| `clean-code` | クリーンコード原則（凝集度、結合度、命名） |
| `functional-programming` | FP パターン（純粋関数、不変性） |

### レビュー・品質

| Skill | 用途 |
|-------|------|
| `code-review` | 包括的コードレビュー方法論 |
| `pr-review` | GitHub PR レビュー (gh CLI) |
| `pr-review-respond` | PR レビューコメントへの対応・自動返信 |
| `commit-file-guard` | コミット時の意図しないファイル検出 |
| `prompt-review` | AI 会話履歴の技術力分析 |

### テスト

| Skill | 用途 |
|-------|------|
| `go-testing` | Go テーブル駆動テストパターン |

### データベース

| Skill | 用途 |
|-------|------|
| `database-admin` | スキーマ設計・クエリ最適化 |
| `postgres-ai-agent` | PostgreSQL ベストプラクティス (Supabase) |

### 認証

| Skill | 用途 |
|-------|------|
| `better-auth-best-practices` | Better Auth フレームワークのベストプラクティス |
| `create-auth-skill` | 認証レイヤー実装ガイド |

### UI/UX

| Skill | 用途 |
|-------|------|
| `ui-ux-pro-max` | UI スタイル・カラーパレット・コンポーネントDB |
| `ui-skills` | UI 構築の制約・ガイドライン |
| `drawio` | draw.io ダイアグラム XML 生成 |

### AI 連携

| Skill | 用途 |
|-------|------|
| `gemini` | Gemini CLI Web 検索連携 |
| `codex-integration` | OpenAI Codex CLI 連携 |

### リサーチ

| Skill | 用途 |
|-------|------|
| `web-search` | Web 検索ベストプラクティス・検証ガイドライン |

## ディレクトリ構造

```
skills/
├── clean-code/
│   ├── skill.md          # スキル本体 (SKILL.md の場合もあり)
│   └── references/       # 参考資料 (オプション)
├── functional-programming/
│   └── skill.md
└── ...
```

## 使い方

スキルは `Skill` ツールまたはスラッシュコマンドで呼び出します:

```
Skill(skill="clean-code")
Skill(skill="code-review")
```

`CLAUDE.md` の `MUST reference` 指定により、コード記述時に `clean-code` と `functional-programming` は自動的に参照されます。
