# n8n ワークフロー実行パターン

## 実行エンドポイント

`POST /rest/workflows/{id}/run`

**Public API (`/api/v1/`) にはワークフロー実行エンドポイントは存在しない**（v2.13.x時点、PR #20304未マージ）。

## ペイロードパターン

n8nの `executeManually` メソッドは以下3パターンのいずれかにマッチするペイロードのみ受け付ける。

### パターン1: 既知のトリガーから全実行（推奨）
```json
{"triggerToStartFrom": {"name": "Manual Trigger"}}
```
- Manual Triggerノードを持つワークフローに最適
- `name` はワークフロー内のノード名と完全一致

### パターン2: トリガー自動選択で全実行
```json
{}
```
- ピン留めされたトリガーがある場合に自動選択

### パターン3: 特定ノードまでの部分実行
```json
{
  "destinationNode": {"nodeName": "ノード名"},
  "runData": {"Manual Trigger": [[{"json": {}}]]}
}
```

## 絶対にやってはいけないこと

```json
// ❌ workflowDataを含めるとエラー
{
  "workflowData": {...},
  "triggerToStartFrom": {"name": "Manual Trigger"}
}
// → "executeManually was called with an unexpected payload"

// ❌ startNodesを使う（旧API形式）
{
  "startNodes": [{"name": "Manual Trigger"}],
  "runData": {}
}
// → 同上エラー
```

## 実行結果の確認

```bash
# ステータス確認
curl -s -b "$COOKIE" "/rest/executions/${EXEC_ID}" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['data']['status'])"

# 一覧（最新5件）
curl -s -b "$COOKIE" "/rest/executions?workflowId=${WF_ID}&limit=5" | \
  python3 -c "
import sys,json
for e in json.load(sys.stdin)['data']['results']:
    print(f\"ID:{e['id']} Status:{e['status']}\")
"
```

### ステータス値
| status | 意味 |
|---|---|
| `success` | 全ノード正常完了 |
| `error` | いずれかのノードでエラー |
| `running` | 実行中 |
| `waiting` | Webhook待ちなど |

## トラブルシューティング

### "executeManually was called with an unexpected payload"
→ ペイロードから `workflowData`, `startNodes`, `runData` を削除。`triggerToStartFrom` のみにする。

### "Cannot read properties of null (reading 'Manual Trigger')"
→ Copy Templateなど中間ノードの「Execute step」を直接押した場合に発生。Manual Triggerから実行する。

### "invalid syntax" in Expression
→ `{{ .field }}` を `{{ $json.field }}` に修正。[expression-syntax.md](expression-syntax.md) 参照。

### Apify実行に時間がかかる
→ TikTok Scraperは通常60-120秒。タイムアウトを十分に設定する。

### Execution status: error だがログにエラーがない
→ n8nの実行データはフラット化配列形式で格納される。`docker compose logs` で確認するか、実行データ内で `error` キーワードを検索。
