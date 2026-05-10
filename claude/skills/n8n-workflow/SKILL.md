---
name: n8n-workflow
description: n8n v2 workflow management via REST API. Use when executing workflows, managing credentials, or modifying nodes programmatically. MUST reference when working with n8n projects.
---

# n8n v2 REST API Skill

## When to Use

- n8nワークフローをCLI/APIから実行する
- ノードのパラメータをプログラムで変更する
- Credentialを作成・更新する
- Expression構文を書く

## Quick Start

```bash
# ログイン
COOKIE=$(curl -s -D - -X POST http://localhost:${N8N_PORT}/rest/login \
  -H 'Content-Type: application/json' \
  -d "{\"emailOrLdapLoginId\":\"$N8N_EMAIL\",\"password\":\"$N8N_PASSWORD\"}" \
  | grep -i 'set-cookie' | head -1 | sed 's/.*: //' | sed 's/;.*//')

# ワークフロー実行（Manual Trigger）
curl -s -b "$COOKIE" -X POST "http://localhost:${N8N_PORT}/rest/workflows/${WF_ID}/run" \
  -H 'Content-Type: application/json' \
  -d '{"triggerToStartFrom":{"name":"Manual Trigger"}}'

# 実行結果確認
curl -s -b "$COOKIE" "http://localhost:${N8N_PORT}/rest/executions/${EXEC_ID}" | \
  python3 -c "import sys,json; print('Status:', json.load(sys.stdin)['data']['status'])"
```

## Critical Rules

1. **実行ペイロードに `workflowData` を含めない** → 含めると `executeManually unexpected payload` エラー
2. **Expression**: `{{ $json.field }}` が正しい。`{{ .field }}` は invalid syntax
3. **jsonBody内Expression**: `=` プレフィックスでJSON全体をexpressionにする
4. **Credential API**: sensitiveフィールドはマスクされて返る。コピー不可
5. **Public API (v1)**: ワークフロー実行エンドポイントは未実装。内部REST APIを使う

## References

- [api-endpoints.md](references/api-endpoints.md) - 全エンドポイント一覧
- [expression-syntax.md](references/expression-syntax.md) - Expression構文と罠
- [execution-patterns.md](references/execution-patterns.md) - 実行パターンとトラブルシューティング
