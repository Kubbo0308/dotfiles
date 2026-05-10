# ブラウザ操作パターン集

## テキスト入力

### NG: `type_text` に改行を含むテキスト

`type_text` の `submitKey: Enter` は改行ごとにメッセージを分割送信する。ChatGPT等のフォームで複数行のプロンプトを送ると、1行目だけが送信されて残りが入力欄に残る。

```
// NG: 改行で分割される
type_text("1行目\n2行目\n3行目", submitKey: "Enter")
// → 「1行目」だけ送信、「2行目\n3行目」が入力欄に残る
```

### OK: `execCommand('insertText')` + `press_key Enter`

```javascript
// OK: 1つのメッセージとして入力してからEnter
evaluate_script(() => {
  const el = document.querySelector('[contenteditable="true"]');
  el.focus();
  document.execCommand('insertText', false, 'プロンプト全文を1行で');
  return 'inserted';
});
press_key("Enter");
```

**ルール**: プロンプトは必ず改行なしの1行にまとめて `execCommand` で入力する。

## ページ内要素の待機

### ChatGPT画像生成の待機

`wait_for` でテキストを待つ方法はタイムアウトしやすい。代わりに `sleep` + `evaluate_script` で画像数をポーリングする。

```javascript
// 画像数を確認
evaluate_script(() => {
  const imgs = document.querySelectorAll('img');
  const results = [];
  const seen = new Set();
  imgs.forEach(img => {
    if (img.naturalHeight > 1000 && !seen.has(img.src)) {
      seen.add(img.src);
      results.push({
        alt: img.alt,
        fileId: img.src.match(/id=([^&]+)/)?.[1] || 'unknown'
      });
    }
  });
  return { count: results.length, latest: results[results.length - 1] };
});
```

**パターン**: `sleep 90` → 画像数確認 → 増えてなければもう一度待つ

## スナップショットの使い分け

| ツール | 用途 |
|--------|------|
| `take_screenshot` | 視覚的な状態確認（画像生成結果の確認等） |
| `take_snapshot` | DOM構造の確認（UID取得、ボタン特定等） |
| `evaluate_script` | データ取得（画像URL、要素数等） |

- ボタンをクリックする前に `take_snapshot` でUIDを取得
- 画像が生成されたか確認するには `evaluate_script` で `img` タグを検索
- 最終確認には `take_screenshot` で視覚的に確認
