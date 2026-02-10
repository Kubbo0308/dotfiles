# Codex exec Options Reference (v0.98.0+)

## All Options

| Option | Description |
|--------|-------------|
| `--full-auto` | No approvals, workspace-write sandbox (RECOMMENDED) |
| `-s, --sandbox MODE` | `read-only`, `workspace-write`, `danger-full-access` |
| `--json` | Output as JSONL for machine parsing |
| `--search` | ❌ NOT available in exec (interactive only) |
| `-i FILE` | Attach image(s) |
| `-o FILE` | Save last message to file |
| `-C DIR` | Set working directory |
| `--add-dir DIR` | Add readable directory |
| `-m MODEL` | Specify model (default: gpt-5.3-codex) |
| `-c key=value` | Override config value |
| `--enable FEATURE` | Enable a feature |
| `--disable FEATURE` | Disable a feature |
| `-p PROFILE` | Use config profile |
| `--output-schema FILE` | JSON schema for output validation |
| `--skip-git-repo-check` | Allow running outside git repo |

## Sandbox Modes

| Mode | Description |
|------|-------------|
| `read-only` | Can only read files (safest) |
| `workspace-write` | Can write to workspace and /tmp |
| `danger-full-access` | Full system access (dangerous!) |

## Important Notes

- `exec` mode does **NOT** support `-a` option
- Use `--full-auto` for automation (equivalent to `-a on-request -s workspace-write`)
- Options must come BEFORE `-` when using stdin

