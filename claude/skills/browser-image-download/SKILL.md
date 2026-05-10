---
name: browser-image-download
description: Chrome DevTools MCP経由でブラウザ上の画像をダウンロードし、指定フォルダに保存するスキル
---

# Browser Image Download

Chrome DevTools MCPを使い、ブラウザ上の画像をローカルに保存する。
ChatGPTの生成画像など、直接curlできない認証付き画像に対応。

## 方式

Chrome「名前を付けて保存」で生成される一時ファイル(`.com.google.Chrome.XXXXX`)をコピーし、ダイアログはキャンセルする。

## Quick Start

```
1. mcp__chrome-devtools__click でDLボタンクリック
2. sleep 4 → 一時ファイルをコピー
3. AppleScriptでダイアログキャンセル
4. 次の画像へ（1に戻る）
```

## Key Points

- **1枚ずつ処理**: DLボタンを複数同時にクリックしない
- **コピー→キャンセルの順**: キャンセルすると一時ファイルが消える
- **ショートカットキーは使わない**: Finderダイアログの操作はUI要素の直接操作のみ
- **ファイル名にパスを入れない**: macOSは`/`を`:`に変換して壊れる
- **ダイアログはwindow 2にも出る**: 全windowをループして探す

## References

- [workflow.md](references/workflow.md) - 完全なワークフロー手順とコマンド例
- [applescript.md](references/applescript.md) - ダイアログキャンセルのAppleScript
