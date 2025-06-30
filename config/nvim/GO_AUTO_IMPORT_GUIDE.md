# Go Auto-Import Functionality in NeoVim

## Overview
Your NeoVim is now configured with enhanced Go auto-import functionality using gopls. This guide explains how to use the features.

## Features Enabled

### 1. Auto-Import Completion
- **What it does**: When you type a function/type that requires an import, NeoVim will suggest completions that automatically add the import
- **How to use**: 
  - Type `fmt.Println` and press `<Tab>` or `<CR>` - the import will be added automatically
  - Type `json.Marshal` and accept the completion - `encoding/json` import will be added
  - Type `http.Get` and accept the completion - `net/http` import will be added

### 2. Import Organization
- **Auto on Save**: Every time you save a Go file (`:w`), imports will be automatically organized and unused imports removed
- **Manual trigger**: Press `<leader>go` (space + g + o) to organize imports manually
- **What it does**:
  - Groups imports: standard library, third-party, local packages
  - Removes unused imports
  - Sorts imports alphabetically within groups

### 3. Auto-Formatting
- **Auto on Save**: Go files are automatically formatted using gofumpt when saved
- **Manual trigger**: Press `<leader>gf` (space + g + f) to format manually

## Keybindings

### General LSP Keybindings
- `gd` - Go to definition
- `gr` - Show references
- `K` - Show hover documentation
- `<leader>vca` - Show code actions
- `<leader>vrn` - Rename symbol
- `<leader>vrr` - Find references
- `<leader>vd` - Show diagnostics
- `[d` / `]d` - Navigate to next/previous diagnostic

### Go-Specific Keybindings
- `<leader>go` - Organize imports manually
- `<leader>gf` - Format Go file manually

## Testing Auto-Import

### Test Files Created
1. `test_auto_import.go` - Basic auto-import testing
2. `test_import_organization.go` - Import organization testing

### How to Test
1. Open `test_auto_import.go` in NeoVim
2. Uncomment the TODO lines one by one
3. Type the functions (e.g., `fmt.Println`) and watch for import suggestions
4. Use `<Tab>` or `<CR>` to accept completions
5. Save the file and see imports get organized automatically

### Example Workflow
```go
// Start typing in a Go file:
func main() {
    fmt.Println("Hello")  // Type this and accept completion
    // The import "fmt" will be added automatically
    
    data := make(map[string]interface{})
    json.Marshal(data)    // Type this and accept completion
    // The import "encoding/json" will be added
}
```

## Advanced Features

### Completion Settings
- **completeUnimported**: Suggests completions for packages not yet imported
- **usePlaceholders**: Shows parameter placeholders in function completions
- **deepCompletion**: Enables deep completions for better suggestions

### Analysis Features
- **unusedparams**: Detects unused function parameters
- **shadow**: Detects variable shadowing
- **unusedwrite**: Detects unused variable writes
- **staticcheck**: Runs staticcheck analysis

### Code Lens
- Shows actionable commands above functions/types
- Generate commands, test commands, tidy commands
- Upgrade dependency suggestions

## Troubleshooting

### If Auto-Import Doesn't Work
1. **Check gopls is running**: `:LspInfo` in NeoVim
2. **Restart LSP**: `:LspRestart`
3. **Check Go module**: Ensure you're in a Go module (`go.mod` file exists)
4. **Update gopls**: `go install golang.org/x/tools/gopls@latest`

### If Imports Don't Organize
1. **Check file is saved**: Auto-organization only works on save
2. **Manual trigger**: Use `<leader>go` to test manually
3. **Check LSP status**: `:LspInfo` should show gopls as attached

### Common Issues
- **PATH**: Ensure `/Users/takesupasankyu/go/bin` is in your PATH
- **Go version**: Ensure Go 1.18+ is installed
- **Module mode**: Work within a Go module for best results

## Performance Tips
- Keep gopls updated for best performance
- Work within Go modules for faster completions
- Large codebases may have slower initial completions

## What's Different Now
**Before**: Basic gopls with minimal features
**After**: Enhanced gopls with:
- ✅ Auto-import completions
- ✅ Import organization on save
- ✅ Enhanced code analysis
- ✅ Better formatting integration
- ✅ Code lens features
- ✅ Go-specific keybindings

Enjoy your enhanced Go development experience in NeoVim!