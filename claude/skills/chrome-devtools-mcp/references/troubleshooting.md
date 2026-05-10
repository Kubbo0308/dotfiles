# DevTools MCP 接続トラブルシューティング

## エラー別対処法

### `Network.enable timed out`

**原因**: MCPはChromeに接続できてるがCDPコマンドがハングしてる

**対処（順番に試す）**:
1. ゾンビプロセス確認・削除
   ```bash
   ps aux | grep "chrome-devtools-mcp" | grep -v grep
   pkill -f "chrome-devtools-mcp"
   ```
2. `/mcp` で再接続
3. Chromeで `chrome://inspect/#remote-debugging` を開いてAllowする
4. Chromeのメモリセーバーを無効化（設定 > パフォーマンス）
5. 開いてるタブを減らす（凍結タブがCDPをブロックする）

### `Could not find DevToolsActivePort`

**原因**: MCPがChromeのプロファイルディレクトリからDevToolsActivePortファイルを見つけられない

**対処**:
1. `--user-data-dir=/tmp/...` 付きで起動したChromeが動いてないか確認
   ```bash
   ps aux | grep "Google Chrome" | grep "user-data-dir"
   ```
2. そのChromeを終了して、通常のChromeを起動
3. DevToolsActivePortファイルの存在確認
   ```bash
   cat "$HOME/Library/Application Support/Google/Chrome/DevToolsActivePort"
   ```

### 接続できない全般

**チェックリスト**:
1. Chromeが起動してるか: `pgrep -f "Google Chrome"`
2. ゾンビMCPプロセスがないか: `ps aux | grep chrome-devtools-mcp | grep -v grep`
3. `--remote-debugging-port` 付きChromeが動いてないか（autoConnectと競合）
4. `chrome://inspect/#remote-debugging` でAllowしたか

## 絶対にやってはいけないこと

- **`--autoConnect`使用時に`--remote-debugging-port`付きでChromeを起動しない**: 競合して両方動かなくなる
- **`.claude.json` の `mcpServers` を `--browser-url` に変更しない**: autoConnectが正しい設定
- **古いMCPプロセスを放置しない**: 新しい接続が確立できなくなる
