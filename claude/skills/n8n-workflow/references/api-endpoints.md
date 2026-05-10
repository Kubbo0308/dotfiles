# n8n v2 REST API Endpoints

## 認証

### POST /rest/login
```bash
curl -s -D - -X POST http://localhost:${PORT}/rest/login \
  -H 'Content-Type: application/json' \
  -d '{"emailOrLdapLoginId":"<email>","password":"<password>"}'
```
- フィールド名は `emailOrLdapLoginId`（`email` ではない）
- レスポンスの `Set-Cookie` ヘッダーから `n8n-auth=...` を取得

---

## ワークフロー

### GET /rest/workflows/{id}
ワークフロー定義の取得。

### PATCH /rest/workflows/{id}
ワークフロー更新。bodyはワークフロー全体（`data`の中身）。
- PUTではなくPATCH
- ノード追加/削除/パラメータ変更に使用

### POST /rest/workflows/{id}/run
ワークフロー手動実行。ペイロードパターンは [execution-patterns.md](execution-patterns.md) 参照。

---

## 実行

### GET /rest/executions?workflowId={id}&limit={n}
実行一覧。レスポンス構造:
```json
{"data": {"results": [{"id": "1", "status": "success", "finished": true}], "count": 1}}
```

### GET /rest/executions/{id}
実行詳細。`data.data` はn8n独自のフラット化配列形式（JSON文字列）。

---

## Credential

### GET /rest/credentials
一覧取得。レスポンス: `data[]` に `{id, name, type}` の配列。

### POST /rest/credentials
新規作成。
```json
{"name": "名前", "type": "googleDriveOAuth2Api", "data": {"clientId": "...", "clientSecret": "..."}}
```

### PATCH /rest/credentials/{id}
更新。`?includeData=true` で取得しても sensitiveフィールド（clientSecret, oauthTokenData）はマスクされる。

### OAuth認証フロー
1. Credential作成 → 2. n8n UIで「Sign in with Google」 → 3. OAuthポップアップで認証
- REST APIだけではOAuthトークン取得不可（UIのポップアップ機構が必要）
- Chrome DevTools MCPで自動化可能
