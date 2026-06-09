---
description: "Multi-Review: 3モデル戦略 (Claude/Gemini/Codex) による並列コードレビュー。--auto で自動修正モード"
arguments:
  - name: options
    description: "--auto for auto-fix mode (up to 5 iterations)"
    required: false
---

# Multi-Review (mr) - 3モデル戦略コードレビュー

3社の AI プロバイダ (Claude/Gemini/Codex) が、それぞれの強みに特化してコードを多角的にレビューします。

## 3-Model Strategy

| Provider | Agent | Focus | Why |
|----------|-------|-------|-----|
| **Claude** (Anthropic) | `review` | 設計・アーキテクチャ・ロジック | 深い推論力、長いコンテキスト理解 |
| **Gemini** (Google) | `code-reviewer-gemini` | 最新ベストプラクティス・非推奨検出 | Google Search grounding で鮮度最高 |
| **Codex** (OpenAI) | `codex-reviewer` | バグパターン・セキュリティ脆弱性 | パターンマッチング、OWASP 検出に強い |

**補助レビュワー** (Claude-based、観点特化):
- `clean-code-fp-reviewer`: 凝集度・結合度・関数型パターン
- `security`: セキュリティ深掘り (Codex を補完)
- 言語別: `go-reviewer` / `typescript-reviewer`

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

> **SCOPE LOCK**: ここで得たファイルリストが唯一のレビュー対象スコープ。
> Step 2/3/4 を通じて、**このリストに含まれないファイルへの指摘は生成・統合ともに禁止。**

### Step 2: コア3モデルレビュー（並列実行）

**必ず3プロバイダすべてを並列で起動する。** 各プロバイダの担当観点:

> **NEW-VS-EXISTING ルール（全レビュワー共通）**: 指摘を生成する前に、その問題が
> **このPRのdiffが新規に持ち込んだものか**、**既存コードベースで既に使われているパターンか** を判断すること。
> 既存コード全体に広く見られるパターン（型アサーション慣習・状態設計等）をPR変更箇所だけに指摘するのは誤検知。
> 既存パターンへの言及は「Observation（参考情報）」として注記するにとどめ、Major以上に分類してはならない。

#### Claude (`review` agent) - 設計・アーキ・ロジック
- アーキテクチャ影響度の分析
- 設計パターンの正誤判定
- 複雑なビジネスロジックの検証
- API 契約と後方互換性
- 型設計の妥当性

#### Gemini (`code-reviewer-gemini` agent) - 最新ベストプラクティス
- 最新ベストプラクティスとの照合 (Web 検索付き)
- 非推奨 API・パターンの検出
- ライブラリの既知問題・脆弱性
- マイグレーション推奨

#### Codex (`codex-reviewer` agent) - バグ・セキュリティ
- バグパターン (null ref, off-by-one, etc.)
- OWASP Top 10 セキュリティ脆弱性
- エラーハンドリングのギャップ
- 並行処理の問題

> **VERIFY-BEFORE-ASSERT**: バグ・型エラーを Critical/Major と断定する前に、
> 関連する型定義・インターフェース・API契約ファイルを実際に読んで確認すること。
> 「型が `undefined` になりうる」等の断定は、型定義ファイル上の証拠なしに行ってはならない。

### Step 3: 補助レビュー（並列実行）

コア3モデルに加え、以下の補助レビュワーも並列実行:

- `security`: セキュリティ専門分析（Codex 結果を補完）
- `clean-code-fp-reviewer`: クリーンコード＆関数型プログラミング
  - **MUST use Skills**: `clean-code`, `functional-programming`
- 言語別レビュワー（該当ファイルがある場合のみ）

### Step 4: レビュー結果の統合

全レビュワーからの結果を統合し、以下のように分類:

1. **3モデル間の重複指摘を排除** - 同じ問題を複数モデルが指摘した場合はマージ
2. **各モデルのユニークな発見を強調** - そのモデルだけが見つけた問題をハイライト
3. **Critical/Major/Minor に分類**

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

#### ⚪ Observation (参考情報・分類対象外)
- 既存コードベース全体の慣習・設計上の好み
- 主観的なスタイル差異（意図的な設計判断が明らかなもの）
- このPRが新規に持ち込んでいない既存パターン

> **重大度校正ルール**:
> - 「好み・スタイル・既存慣習」は Minor または Observation。Major以上に格上げ禁止。
> - 実ソース確認なしに断定したバグ疑惑は Observation 止まり。確認済みの場合のみ Critical/Major。
> - 指摘件数が多い場合は「本当にこれはこのPRが新規に導入した問題か？」を自問してから統合すること。

### Step 5: 対応確認（通常モード）

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

### Step 6: 修正の適用

選択された問題に対して修正を適用します。

修正後、関連するファイルに対して**再度レビュー**を実行し、新たな問題がないか確認します。

### Step 7: 繰り返し（自動修正モードのみ）

**自動修正モード**の場合:
1. 修正後に再レビュー
2. 新たなCritical/Major問題があれば修正
3. 最大5回まで繰り返し
4. 5回で解決しない場合は開発者に報告

## Output Format

最終的なレビューサマリー:

```markdown
## Multi-Review Summary (3-Model Strategy)

### Model Coverage
| Provider | Agent | Focus | Issues Found |
|----------|-------|-------|--------------|
| Claude   | review | Architecture & Design | 3 |
| Gemini   | code-reviewer-gemini | Best Practices | 2 |
| Codex    | codex-reviewer | Bugs & Security | 4 |
| (supplementary) | clean-code-fp, security, etc. | Specialized | 3 |

### Statistics
| Language | Files | Critical | Major | Minor |
|----------|-------|----------|-------|-------|
| Go       | 3     | 0        | 2     | 1     |
| TypeScript | 5   | 1        | 3     | 4     |

### 🔴 Critical Issues (must fix)
1. **[codex/security]** `src/api/auth.ts:42` - XSS vulnerability in user input
   - Suggestion: Use DOMPurify to sanitize input

### 🟠 Major Issues (should fix)
1. **[claude/architecture]** `src/services/user.ts:28` - Leaking domain logic to handler
   - Suggestion: Extract to domain service layer
2. **[gemini/deprecation]** `src/utils/date.ts:15` - moment.js is deprecated
   - Suggestion: Migrate to date-fns (source: https://...)

### 🟡 Minor Issues (nice to have)
1. **[clean-code]** `src/utils/calc.ts:10` - Common coupling via global state

### ✅ Applied Fixes
- Fixed XSS vulnerability in `src/api/auth.ts`

### 📝 Deferred Issues
- moment.js migration (major, requires planning)
```

## Implementation Notes

1. **3プロバイダ必須**: Claude, Gemini, Codex すべてを起動すること
2. **並列実行**: 各レビュワーは独立して並列実行
3. **重複排除**: 統合時に同一問題のマージ
4. **JSON出力**: レビュワーはJSON形式で結果を返す
5. **モデル別サマリー**: 各プロバイダの発見を区別して表示

## Error Handling

- レビュワーがタイムアウト: 該当レビューをスキップ（残りで継続）
- CLI未インストール (gemini/codex): 警告を出して残りのモデルで継続
- JSON解析エラー: レビュワーの生出力をログに記録

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
3. **Launch all 3 core model reviewers in parallel** (Claude, Gemini, Codex)
4. Launch supplementary reviewers in parallel
5. Aggregate results with deduplication and model attribution
6. If --auto mode, proceed with auto-fix; otherwise ask for confirmation

$ARGUMENTS
