---
description: "Multi-Review: マルチエージェントコードレビュー。言語別・観点別の専門レビュワーが並列でコードをレビュー。--auto で自動修正モード"
arguments:
  - name: options
    description: "--auto for auto-fix mode (up to 5 iterations)"
    required: false
---

# Multi-Review (mr) - マルチエージェントコードレビュー 🔍

言語別・観点別の専門レビュワーがコードを多角的にレビューします。

## Options

- `--auto`: 自動修正モード（開発者の承認なしに修正を適用、最大5回繰り返し）

## Process

### Step 1: 変更ファイルの検出

まず `git diff` で変更されたファイルを検出し、言語ごとに分類します。

```bash
git diff --name-only HEAD
git diff --staged --name-only
```

ファイル拡張子による言語分類:
- `.go` → Go reviewer
- `.ts`, `.tsx`, `.js`, `.jsx` → TypeScript reviewer
- `.tf` → Terraform reviewer
- `.sql` (dbt project) → dbt reviewer
- `.md` → Markdown reviewer

### Step 2: 並列レビュー実行

検出された言語に対応するレビュワーを **並列で** 起動します。

各レビュワーに渡す情報:
1. 変更されたファイルの一覧
2. 各ファイルの差分 (`git diff`)
3. ファイルの全文（コンテキスト用）

**使用するサブエージェント:**

#### 🌐 共通レビュワー（常に実行）
- `security`: セキュリティ専門分析（OWASP Top 10、脆弱性検出）
- `clean-code-fp-reviewer`: クリーンコード＆関数型プログラミング専門
  - **MUST use Skills**: `clean-code`, `functional-programming`
  - 凝集度（7レベル）、結合度（7レベル）、命名規則
  - 純粋関数、イミュータビリティ、宣言的パターン
  - 参照: `claude/skills/clean-code/`, `claude/skills/functional-programming/`
- `code-reviewer-gemini`: Gemini Web検索で最新ベストプラクティスを取得
- `code-reviewer-cursor`: Cursor AIによる包括的レビュー
- `codex-reviewer`: OpenAI Codex CLIによる非インタラクティブレビュー
  - Primary: `codex review --uncommitted` または `--base main`
  - Fallback: `codex exec` with piped diff（認証問題時）
  - 参照: `claude/skills/codex-integration/SKILL.md`

#### 📝 言語別レビュワー（該当ファイルがある場合のみ）
- `go-reviewer`: Go コード専門（Idiomatic, Test, Consistency, Layer）
- `typescript-reviewer`: TypeScript/React 専門（Type Safety, Performance, Layer）
- `terraform-reviewer`: Terraform 専門（Idiomatic, Consistency, Validation）
- `dbt-reviewer`: dbt/SQL 専門（SQL Style, Schema, Privacy Governance）
- `markdown-reviewer`: Markdown 専門（CLAUDE.md/SKILL.md/一般で観点分岐）

### Step 3: レビュー結果の統合

全レビュワーからのJSON結果を統合し、以下のように分類します:

#### 🔴 Critical Issues (即時対応必須)
- セキュリティ脆弱性
- データ損失リスク
- 本番障害の可能性

#### 🟠 Major Issues (対応推奨)
- パフォーマンス問題
- 設計上の問題
- テスト不足

#### 🟡 Minor Issues (検討事項)
- コードスタイル
- ドキュメント改善
- リファクタリング提案

### Step 4: 対応確認（通常モード）

**通常モード**の場合、開発者に確認します:

```
以下の問題が検出されました:
- Critical: 2件
- Major: 5件
- Minor: 8件

どの問題を修正しますか？
1. すべてのCritical + Majorを修正
2. Criticalのみ修正
3. 問題を選択して修正
4. 修正せずに終了
```

**自動修正モード (`--auto`)** の場合:
- このステップをスキップ
- すべてのCritical + Major問題を自動修正

### Step 5: 修正の適用

選択された問題に対して修正を適用します。

修正後、関連するファイルに対して**再度レビュー**を実行し、新たな問題がないか確認します。

### Step 6: 繰り返し（自動修正モードのみ）

**自動修正モード**の場合:
1. 修正後に再レビュー
2. 新たなCritical/Major問題があれば修正
3. 最大5回まで繰り返し
4. 5回で解決しない場合は開発者に報告

## Output Format

最終的なレビューサマリー:

```markdown
## 🔍 Multi-Review Summary

### 📊 Statistics
| Language | Files | Critical | Major | Minor |
|----------|-------|----------|-------|-------|
| Go       | 3     | 0        | 2     | 1     |
| TypeScript | 5   | 1        | 3     | 4     |
| Terraform | 2    | 0        | 1     | 0     |

### 🔴 Critical Issues (must fix)
1. **[typescript]** `src/api/auth.ts:42` - XSS vulnerability in user input
   - Suggestion: Use DOMPurify to sanitize input

### 🟠 Major Issues (should fix)
1. **[go]** `internal/handler/user.go:28` - Missing error context
   - Suggestion: Wrap error with `fmt.Errorf("failed to get user: %w", err)`

### 🟡 Minor Issues (nice to have)
1. **[go]** `internal/service/order.go:15` - Consider using table-driven test

### ✅ Applied Fixes
- Fixed XSS vulnerability in `src/api/auth.ts`
- Added error context in `internal/handler/user.go`

### 📝 Deferred Issues
- Table-driven test suggestion (minor, manual review needed)
```

## Implementation Notes

1. **並列実行**: 各言語レビュワーは独立して並列実行
2. **JSON出力**: レビュワーはJSON形式で結果を返す
3. **冪等性**: 同じコードに対して同じレビュー結果
4. **コンテキスト保持**: 修正後も元の問題コンテキストを保持

## Error Handling

- レビュワーがタイムアウト: 該当言語のレビューをスキップ
- JSON解析エラー: レビュワーの生出力をログに記録
- 修正失敗: 問題をDeferredリストに移動

## Usage Examples

```bash
# 通常モード（確認あり）
/mr

# 自動修正モード（確認なし、最大5回繰り返し）
/mr --auto
```

---

**Now execute the Multi-Review process based on the current git changes.**

1. First, detect changed files using `git diff`
2. Classify files by language/type
3. Launch appropriate reviewers in parallel using Task tool
4. Aggregate results and present to user
5. If --auto mode, proceed with auto-fix; otherwise ask for confirmation

$ARGUMENTS

