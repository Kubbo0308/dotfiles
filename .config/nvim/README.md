# Neovim Configuration

Modern Lua-based Neovim configuration with lazy.nvim plugin management.

## Directory Structure

```
config/nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin version lock file
├── COMMANDS.md             # Full keybinding reference (418 lines)
├── HELP_USAGE.md           # Help feature documentation
└── lua/
    ├── plugins/            # Plugin configurations
    │   ├── bufferline.lua
    │   ├── colorscheme.lua
    │   ├── git.lua
    │   ├── go.lua
    │   ├── help-commands.lua
    │   ├── image-preview.lua
    │   ├── javascript.lua
    │   ├── keybindings.lua
    │   ├── lsp.lua
    │   ├── nvim-tree.lua
    │   ├── search.lua
    │   ├── telescope.lua
    │   ├── terminal.lua
    │   ├── treesitter.lua
    │   └── visual-enhancements.lua
    └── utils/
        └── wezterm.lua     # WezTerm integration
```

## Quick Start

```bash
# Start Neovim (plugins auto-install on first launch)
nvim

# Plugin manager
:Lazy
```

## Key Features

### Plugin Manager
- **lazy.nvim**: Modern plugin manager with lazy loading
- Plugins load on-demand via `cmd`, `keys`, or `event` triggers

### Leader Key
- **Leader**: `Space`

### Color Scheme
- **Theme**: VSCode dark theme

## Essential Keybindings

See [COMMANDS.md](COMMANDS.md) for the complete reference.

### Navigation

| Key | Action |
|-----|--------|
| `<C-b>` | Toggle file tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Git commands menu |
| `<leader>gd` | Git diff files |
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame |
| `<leader>gh` | Preview hunk |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |

### Help

| Key | Action |
|-----|--------|
| `<leader>?h` | All help commands |
| `<leader>?g` | Git help |
| `<leader>?l` | LSP help |

## Plugin Categories

### Git Tools (`git.lua`)
- **GitSigns**: Gutter signs, hunk navigation
- **vim-fugitive**: Core git commands
- **DiffView**: Advanced diff viewing
- **Octo.nvim**: GitHub integration
- **git-blame**: Blame annotations

### Fuzzy Finding (`telescope.lua`)
- **Telescope**: File finder, grep, buffers
- Custom git diff picker
- Commands menu integration

### Language Server (`lsp.lua`)
- **nvim-lspconfig**: LSP configuration
- **mason.nvim**: LSP installer
- Auto-completion support

### Language Support
- **go.lua**: Go development (gopls, go.nvim)
- **javascript.lua**: TypeScript/JavaScript (typescript-tools.nvim)

### UI Enhancements
- **bufferline.lua**: Tab-like buffer display
- **nvim-tree.lua**: File explorer
- **visual-enhancements.lua**: UI improvements
- **colorscheme.lua**: VSCode theme

### Utilities
- **treesitter.lua**: Syntax highlighting
- **terminal.lua**: Integrated terminal
- **search.lua**: Search enhancements
- **help-commands.lua**: Custom help system

## Language Support

### Go
- gopls LSP
- go.nvim for enhanced features
- Test running, debugging support

### TypeScript/JavaScript
- typescript-tools.nvim (modern alternative to tsserver)
- ESLint integration
- Prettier formatting

## Customization

### Add a Plugin

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/my-plugin.lua
return {
    "author/plugin-name",
    lazy = true,
    cmd = { "PluginCommand" },
    config = function()
        require("plugin-name").setup({
            -- options
        })
    end
}
```

### Add Keybindings

Edit `lua/plugins/keybindings.lua` or add to specific plugin files:

```lua
vim.keymap.set("n", "<leader>xx", function()
    -- action
end, { desc = "Description" })
```

## Documentation

- **[COMMANDS.md](COMMANDS.md)**: Complete keybinding reference
- **[HELP_USAGE.md](HELP_USAGE.md)**: Help feature usage guide

## Troubleshooting

### Plugins not loading

```vim
:Lazy sync    " Sync all plugins
:Lazy update  " Update plugins
:checkhealth  " Run health checks
```

### LSP not working

```vim
:LspInfo      " Check LSP status
:Mason        " Manage LSP servers
:LspLog       " View LSP logs
```

### Clear cache

```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

## Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

