# n8n Expression構文ガイド

## 基本ルール

n8n expressionは `={{ }}` または `=` プレフィックスで記述する。

## フィールド参照

```
✅ {{ $json.fieldName }}        # 現在のitemのJSONフィールド
✅ {{ $json._spreadsheetId }}   # アンダースコア始まりも$json経由ならOK
❌ {{ .fieldName }}             # invalid syntax（$json省略不可）
❌ {{ ._spreadsheetId }}        # invalid syntax
```

## 他ノードの参照

```javascript
// 特定ノードの最初のitemを取得
$('Copy Template').first().json.id

// 特定ノードの全itemを取得
$('Node Name').all()

// 直前ノードのデータ
$input.all()
$input.first().json.fieldName
```

## 日時

```
{{ $now }}                              // 現在時刻（DateTime）
{{ $now.format("yyyy-MM-dd") }}         // 2026-03-31
{{ $now.format("yyyy-MM-dd_HHmm") }}   // 2026-03-31_1825
{{ $today }}                            // 今日の日付
```

## jsonBody内でのExpression（HTTP Requestノード）

### specifyBody: "json" の場合

JSON文字列全体を `=` プレフィックスでexpressionにする:

```
❌ {"name": "={{ \"prefix_\" + $now.format(\"yyyy-MM-dd\") }}"}
   → 式が評価されず、リテラル文字列 "={{ ... }}" がそのまま送信される

✅ ={"name": "prefix_{{ $now.format("yyyy-MM-dd_HHmm") }}"}
   → `=` プレフィックスでJSON全体がexpressionとして評価される
   → {{ }} 内のexpressionが解決されて "prefix_2026-03-31_1825" になる
```

**ポイント**: `=` プレフィックスを付けると、n8nはフィールド値全体をexpressionとして処理する。
JSON内の `{{ }}` 部分だけが動的に置換される。

## Codeノード内でのexpression

Codeノード（JavaScript）では通常のn8n expression `{{ }}` は使えない。
代わりにn8nのビルトイン変数を直接参照:

```javascript
// ✅ Codeノード内
const id = $('Copy Template').first().json.id;
const items = $input.all();
const now = new Date().toISOString();

// ❌ Codeノード内で {{ }} は使えない
```
