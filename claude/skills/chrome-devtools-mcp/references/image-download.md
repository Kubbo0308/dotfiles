# 認証付き画像のダウンロード手順

## 問題

ChatGPT等の認証付きサイトで生成された画像は、直接 `curl` でダウンロードできない（認証エラーでJSONが返る）。

## 解決: ブラウザ fetch → base64 → ローカルデコード

### Step 1: ブラウザ内で画像URLを取得

```javascript
evaluate_script(() => {
  const imgs = document.querySelectorAll('img');
  const results = [];
  const seen = new Set();
  imgs.forEach(img => {
    if (img.naturalHeight > 1000 && !seen.has(img.src)) {
      seen.add(img.src);
      results.push({
        src: img.src,
        alt: img.alt,
        fileId: img.src.match(/id=([^&]+)/)?.[1] || 'unknown'
      });
    }
  });
  return results;
});
```

### Step 2: ブラウザ内でfetch → base64変換

```javascript
evaluate_script(async () => {
  const imgs = document.querySelectorAll('img');
  let targetUrl = null;
  for (const img of imgs) {
    if (img.src.includes('TARGET_FILE_ID')) {
      targetUrl = img.src;
      break;
    }
  }
  const response = await fetch(targetUrl);
  const blob = await response.blob();
  const reader = new FileReader();
  return new Promise(resolve => {
    reader.onloadend = () => resolve(reader.result.split(',')[1]);
    reader.readAsDataURL(blob);
  });
});
```

結果は大きすぎてツール出力ファイルに保存される。

### Step 3: ローカルでbase64デコード → PNG保存

```python
import json, base64, re

with open("TOOL_RESULT_FILE_PATH") as f:
    data = json.load(f)

text = data[0]['text']
match = re.search(r'"(iVBOR[^"]*)"', text)
if match:
    b64 = match.group(1).replace('\\n', '').replace('\\r', '')
    remainder = len(b64) % 4
    if remainder:
        b64 += '=' * (4 - remainder)
    img_bytes = base64.b64decode(b64)
    with open("OUTPUT_PATH.png", "wb") as f:
        f.write(img_bytes)
```

### 注意事項

- `evaluate_script` の結果が大きい場合、自動的にファイルに保存される
- ファイルパスはエラーメッセージに含まれる
- base64文字列の前後にJSON wrapper (`Script ran on page...`) が含まれるので `re.search` で `iVBOR` マーカーから抽出する
- パディング修正（`%4` の余りを `=` で埋める）が必要な場合がある
