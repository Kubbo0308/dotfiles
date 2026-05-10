---
name: chrome-devtools-mcp
description: Chrome DevTools MCP接続・操作のベストプラクティス。接続トラブルシューティングとブラウザ自動操作の定石
---

# Chrome DevTools MCP Skill

Chrome DevTools MCPを使ったブラウザ操作の接続・トラブルシューティング・操作パターン集

## 接続モード

このユーザー環境では **`--autoConnect`** モードを使用する。

```json
{
  "chrome-devtools": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "chrome-devtools-mcp@latest", "--autoConnect"]
  }
}
```

### autoConnectの前提条件
- Chrome 144+（現環境: 146）
- 通常のChromeを普通に起動（`--remote-debugging-port` や `--user-data-dir` は不要）
- `chrome://inspect/#remote-debugging` でAllowする
- **`--remote-debugging-port` 付きで起動するとautoConnectと競合する → 絶対にやらない**

## Key Points

- **接続トラブル時はまずゾンビプロセスを確認**: `ps aux | grep chrome-devtools-mcp` で古いプロセスが残ってないか
- **`/mcp` で再接続しても古いプロセスが生き残る**: `pkill -f chrome-devtools-mcp` してから `/mcp`
- **テキスト入力は `type_text` ではなく `execCommand` を使う**: 改行を含むテキストが分割送信される問題を回避
- **画像ダウンロードはブラウザ fetch → base64 → ローカルデコード**: 認証付きURLは直接curlできない

## References

- [troubleshooting.md](references/troubleshooting.md) - 接続トラブルシューティング
- [browser-automation.md](references/browser-automation.md) - ブラウザ操作パターン集
- [image-download.md](references/image-download.md) - 認証付き画像のダウンロード手順
