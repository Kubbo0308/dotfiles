# Codex Troubleshooting

## Authentication Errors

```bash
# Check status
codex login status

# Re-authenticate with API key
codex login --api-key "$OPENAI_API_KEY"

# Or re-authenticate via ChatGPT OAuth
codex login
```

## MCP Server Timeouts

Disable MCP temporarily:
```bash
codex exec "task" -c 'mcp_servers={}'
```

## Common Error Messages

| Error | Solution |
|-------|----------|
| 401 Unauthorized | Token expired, run `codex login` |
| unexpected argument '-a' | Use `--full-auto` instead of `-a never` |
| MCP timeout | Use `-c 'mcp_servers={}'` |

## Config Overrides

```bash
# Change model
codex exec "task" -m o3

# Use profile
codex exec "task" -p my-profile

# Multiple overrides
codex exec "task" -c model="o3" -c 'sandbox_permissions=["disk-full-read-access"]'
```

