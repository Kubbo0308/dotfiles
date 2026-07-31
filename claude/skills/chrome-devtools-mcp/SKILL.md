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
- **セッション途中でツール呼び出しがハングすることがある**（同じセッションで一度成功していても再発する）。
  `new_page` / `list_pages` が120秒でタイムアウトしてバックグラウンドタスク化されたら:
  1. **必ず `TaskStop` で明示的に止める** — 放置すると次の呼び出しも詰まって連鎖する
  2. `pkill -f chrome-devtools-mcp` → `/mcp` で貼り直す
  3. タブが大量に開いていると `list_pages` の応答が重くなるので、不要なタブを閉じてもらう
- **目視確認が目的の本質でないなら、ハングに粘らず代替手段で先に進む**: typecheck / build / API への直接リクエストで
  検証できるならそちらで確定させ、「画面の目視確認だけは未実施」と報告に明記する
- **テキスト入力は `type_text` ではなく `execCommand` を使う**: 改行を含むテキストが分割送信される問題を回避
- **画像ダウンロードはブラウザ fetch → base64 → ローカルデコード**: 認証付きURLは直接curlできない

## References

- [troubleshooting.md](references/troubleshooting.md) - 接続トラブルシューティング
- [browser-automation.md](references/browser-automation.md) - ブラウザ操作パターン集
- [image-download.md](references/image-download.md) - 認証付き画像のダウンロード手順
