# Codex MCP Configuration

This directory stores the Codex CLI configuration for Model Context Protocol (MCP) servers. The files here mirror the Claude MCP setup for easier portability.

## Files

- `config-template.toml` – Template tracked in git. Uses `${DOTFILES_DIR}` placeholder for your local dotfiles path.
- `config.toml` – Generated file (gitignored) that contains machine-specific paths.
- `generate-config.sh` – Creates `config.toml` from the template. You can set `DOTFILES_DIR` before running if your dotfiles live elsewhere.
- `setup-links.sh` – Replaces `~/.codex/config.toml` with a symlink to the generated configuration.

## MCP Servers Included

- **context7** – Documentation and API reference search (`@upstash/context7-mcp`).
- **playwright** – Browser automation and screenshots (`@playwright/mcp`).
- **figma-dev-mode** – Connects to the local Figma Dev Mode MCP bridge (expects the bridge at `http://127.0.0.1:3845/mcp`).
- **serena** – Local Serena code intelligence MCP (requires the `serena` CLI and a project config in `${DOTFILES_DIR}/.serena`).

> ℹ️  Export `CONTEXT7_API_KEY` in your shell (or via your existing environment files) for authenticated Context7 usage. The server falls back to unauthenticated mode if the key is missing.
>
> ℹ️  Install the Serena CLI (`pipx install serena` or equivalent) so the `serena mcp` command is available. The template points it at `${DOTFILES_DIR}`; adjust the command if you keep Serena projects elsewhere.

## Usage

```bash
cd ~/.dotfiles/codex/mcp
./generate-config.sh
./setup-links.sh
```

Restart the Codex CLI after linking so it picks up the new MCP entries.

### Trusting project directories

The generator automatically marks a few frequently-used projects as `trusted` so Codex does not prompt you every time:

- `~/Documents/my-brain`
- `~/development/simple-todo-notification`

You can extend the list by exporting `CODEX_EXTRA_PROJECTS` (colon-separated paths). Example:

```bash
export CODEX_EXTRA_PROJECTS="~/work/project-a:~/work/project-b"
./generate-config.sh
```

Re-run `setup-links.sh` afterwards so the CLI picks up the regenerated config.
