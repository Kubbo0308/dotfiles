# NeoVim VSCode-like Features Guide

This guide covers all the VSCode-like extensions and features added to your NeoVim setup.

## 🌳 File Tree (nvim-tree)

**Already configured and enhanced!**

- `<C-b>` - Toggle file tree
- `<C-m>` - Focus file tree
- Shows Git status indicators
- Auto-opens when starting NeoVim

## 🔗 Git Integration

### GitSigns (Git gutter + blame)
- Shows git changes in the gutter with symbols
- Real-time git blame on current line
- Navigation and staging shortcuts:

**Navigation:**
- `]c` - Next git hunk
- `[c` - Previous git hunk

**Actions:**
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hS` - Stage entire buffer
- `<leader>hR` - Reset entire buffer
- `<leader>hp` - Preview hunk
- `<leader>hb` - Full git blame
- `<leader>tb` - Toggle line blame
- `<leader>hd` - Diff this file

### Fugitive (Git commands)
- `<leader>gs` - Git status (like VSCode Git panel)
- `<leader>ga` - Git add all
- `<leader>gc` - Git commit
- `<leader>gp` - Git push
- `<leader>gl` - Git pull
- `<leader>gb` - Git blame
- `<leader>gd` - Git diff split

### DiffView (Git log viewer)
- `<leader>gv` - Open git diff view
- `<leader>gh` - File history view

## 💻 Terminal Integration (ToggleTerm)

**Multiple terminal options:**
- `<C-\>` - Toggle floating terminal
- `<leader>tf` - Toggle floating terminal
- `<leader>th` - Toggle horizontal terminal
- `<leader>tv` - Toggle vertical terminal

**Special terminals:**
- `<leader>gg` - LazyGit (visual Git interface)
- `<leader>tn` - Node.js REPL
- `<leader>tp` - Python REPL

**Terminal navigation:**
- `<Esc>` or `jk` - Exit terminal mode
- `<C-h/j/k/l>` - Navigate between windows

## 🐹 Go Development

### Test Runner & Tools (go.nvim + vim-go)
**Test commands:**
- `<leader>gt` - Run Go tests
- `<leader>gT` - Run tests in current file
- `<leader>gf` - Run test function under cursor
- `<leader>gc` - Show test coverage

**Build & Run:**
- `<leader>gb` - Build Go project
- `<leader>gr` - Run Go project

**Debug:**
- `<leader>gd` - Debug Go code
- `<leader>gD` - Debug Go tests

**Code tools:**
- `<leader>gi` - Go import
- `<leader>gI` - Add missing imports
- `<leader>ge` - Generate if err statement
- `<leader>gF` - Fill struct fields
- `<leader>gS` - Fill switch cases

**Tags:**
- `<leader>gta` - Add struct tags
- `<leader>gtr` - Remove struct tags

**Navigate:**
- `<leader>gA` - Go to alternate file (test ↔ source)
- `<leader>gV` - Alternate file in vertical split
- `<leader>gH` - Alternate file in horizontal split

**Auto-formatting:** Automatically runs `gofmt` and `goimports` on save.

## 🌐 TypeScript/JavaScript Development

### Test Runner (Neotest)
**Test commands:**
- `<leader>tt` - Run test under cursor
- `<leader>tf` - Run all tests in file
- `<leader>td` - Debug test under cursor
- `<leader>ts` - Toggle test summary panel
- `<leader>to` - Show test output
- `<leader>tO` - Toggle test output panel
- `<leader>tS` - Stop running tests

**Supports:** Jest, Vitest, and other popular test frameworks

### TypeScript Tools
**TypeScript-specific commands:**
- `<leader>to` - Organize imports
- `<leader>tR` - Rename file and update imports
- `<leader>ti` - Add missing imports
- `<leader>tF` - Fix all TypeScript issues
- `<leader>tu` - Remove unused imports
- `<leader>td` - Go to source definition

### Package.json Helper
- Shows version info inline in package.json
- Indicates outdated packages
- Auto-detects npm/yarn/pnpm

### ESLint Integration
- Real-time linting and error detection
- Auto-fix on save
- Code actions for ESLint rules

### Additional Features
- **Auto-tag closing** for HTML/JSX
- **Tailwind CSS** class suggestions and colors
- **REST client** for API testing (`.http` files)

## 🚀 General VSCode-like Features

### Which-Key (Keybinding Help)
- Press `<leader>` and wait to see available commands
- Shows organized command groups
- Helps discover new shortcuts

### Window Management
- `<C-h/j/k/l>` - Navigate between windows
- `<C-Arrow>` - Resize windows
- `<S-h/l>` - Navigate between buffers

### Quick Actions
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>x` - Save and quit
- `<leader>bd` - Close buffer
- `<leader>fc` - Open NeoVim config
- `<leader>h` - Clear search highlights

## 📁 Project Structure

Your new plugin files:
```
~/.config/nvim/lua/plugins/
├── git.lua           # Git integration (GitSigns, Fugitive, DiffView)
├── terminal.lua      # Terminal integration (ToggleTerm)
├── go.lua           # Go development tools
├── javascript.lua   # JS/TS development tools
└── keybindings.lua  # Keybinding management (Which-Key)
```

## 🎯 Getting Started

1. **Restart NeoVim** to load all new plugins
2. **Install dependencies:** Run `:Lazy sync` to install all plugins
3. **Try these workflows:**
   - Open file tree with `<C-b>`
   - Open terminal with `<C-\>`
   - Check Git status with `<leader>gs`
   - Run tests with `<leader>tt` (in Go/JS/TS files)
   - Use `<leader>` to explore available commands

## 🔧 Troubleshooting

- **Missing binaries:** Some Go tools need installation. Run `:GoInstallBinaries`
- **LSP issues:** Make sure you have language servers installed via Mason
- **Plugin errors:** Run `:Lazy sync` to update all plugins
- **Git features not working:** Ensure you're in a Git repository

Your NeoVim is now equipped with powerful VSCode-like features! 🎉