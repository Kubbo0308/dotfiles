# WezTerm Preview System User Guide

## Overview

The WezTerm Preview System provides seamless file preview functionality for oil.nvim file manager using WezTerm terminal panes. This system allows you to preview text files, images, and directories in a dedicated pane while navigating files in oil.nvim.

## Features

- 🖼️ **Image Preview**: Display images directly in terminal using `wezterm imgcat`
- 📄 **Text File Preview**: Syntax-highlighted preview using `bat` or `cat`
- 📁 **Directory Preview**: Colored directory listing with `ls -la`
- ⚡ **Auto-Preview**: Automatic preview updates on cursor movement (with debouncing)
- 🎯 **Manual Preview**: On-demand preview with keybindings
- 🧹 **Auto-Cleanup**: Automatic pane cleanup when leaving oil buffers
- 🛡️ **Error Handling**: Graceful handling of edge cases and errors

## Requirements

### Essential
- **WezTerm**: Terminal with CLI support
- **Neovim**: With oil.nvim plugin installed
- **Running in WezTerm**: Must be executed within WezTerm terminal

### Optional (Recommended)
- **bat**: For syntax highlighting (`brew install bat`)
- **Modern shell**: Zsh, Bash, or Fish

## Installation

The system is already configured in your dotfiles. No additional installation required.

## Usage

### Basic Workflow

1. **Open oil.nvim**:
   ```vim
   :Oil
   " or
   <leader>o
   ```

2. **Navigate to files** using arrow keys or `j/k`

3. **Preview files** using keybindings:
   - `gp` - Preview current file/directory
   - `gP` - Toggle auto-preview mode

### Keybindings

#### In oil.nvim buffers:

| Key | Action | Description |
|-----|--------|-------------|
| `gp` | Preview current item | Creates preview pane and shows current file/directory |
| `gP` | Toggle auto-preview | Enables/disables automatic preview on cursor movement |
| `<leader>p` | Legacy image preview | Direct image preview (legacy method) |
| `<leader>P` | Clear preview pane | Clears content of preview pane |
| `<leader>C` | Close preview pane | Closes the preview pane completely |

#### Global keybindings:

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ot` | Toggle auto-preview | Global toggle for auto-preview mode |
| `<leader>op` | Preview current item | Global preview current item command |
| `<leader>oc` | Show configuration | Display current preview configuration |
| `<leader>od` | Set debounce delay | Interactively set auto-preview delay |

### Commands

| Command | Description |
|---------|-------------|
| `:OilToggleAutoPreview` | Toggle auto-preview on cursor movement |
| `:OilPreviewCurrent` | Preview the current item under cursor |
| `:OilShowConfig` | Display current configuration settings |
| `:OilSetDebounceDelay <ms>` | Set debounce delay in milliseconds |

## Configuration

### Auto-Preview Settings

The system includes configurable options:

```lua
local config = {
  auto_preview_enabled = false,      -- Start with auto-preview disabled
  debounce_delay = 200,              -- 200ms delay before preview update
  max_file_size = 50 * 1024 * 1024,  -- 50MB limit for text files
  enable_directory_preview = true,    -- Enable directory previews
  enable_image_preview = true,        -- Enable image previews
  enable_text_preview = true,         -- Enable text file previews
}
```

### Adjusting Settings

1. **Debounce Delay**: Control how quickly previews update
   ```vim
   <leader>od
   " Enter new delay in milliseconds (50-1000)
   ```

2. **File Size Limits**: Modify in configuration file
   ```lua
   max_file_size = 100 * 1024 * 1024  -- 100MB limit
   ```

## Supported File Types

### Text Files (with syntax highlighting)
- Programming: `.lua`, `.py`, `.js`, `.ts`, `.go`, `.rs`, `.c`, `.cpp`, `.java`, etc.
- Markup: `.md`, `.html`, `.xml`, `.json`, `.yaml`, `.toml`
- Config: `.conf`, `.cfg`, `.ini`, `.gitignore`, `.vimrc`
- Documentation: `.txt`, `.org`, `.rst`, `.tex`

### Images
- Common formats: `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.bmp`
- Advanced: `.tiff`, `.svg`, `.ico`, `.heic`, `.heif`

### Directories
- Shows directory contents with permissions, size, and modification time
- Color-coded output for easy identification

### Special Files
- Files without extensions: `README`, `LICENSE`, `Makefile`, `Dockerfile`
- Large files: Handled gracefully with size limits

## Workflow Examples

### Example 1: Code Review
```bash
# Open project directory
cd ~/my-project
nvim

# In Neovim
:Oil

# Navigate to source files
# Press gP to enable auto-preview
# Use j/k to navigate - preview updates automatically
# Review files without opening them
```

### Example 2: Image Gallery
```bash
# Navigate to image directory
cd ~/Pictures
nvim

# In Neovim  
:Oil

# Use gp to preview individual images
# Navigate through images with preview pane open
```

### Example 3: Configuration Editing
```bash
# Open config directory
cd ~/.config
nvim

# In Neovim
:Oil

# Enable auto-preview with gP
# Navigate config files to find the right one
# Preview shows content before opening
```

## Troubleshooting

### Common Issues

#### 1. Preview not working
**Symptoms**: No preview pane appears or commands fail

**Solutions**:
- Ensure you're running in WezTerm: `echo $WEZTERM_PANE`
- Check WezTerm CLI: `wezterm cli --help`
- Verify oil.nvim is loaded: `:Oil`

#### 2. Image preview not showing
**Symptoms**: Images not displayed in preview

**Solutions**:
- Ensure WezTerm supports imgcat: `wezterm imgcat --help`
- Check file format is supported
- Try with a different image file

#### 3. Auto-preview too fast/slow
**Symptoms**: Preview updates too quickly or slowly

**Solutions**:
- Adjust debounce delay: `<leader>od`
- Try values between 100-500ms for different responsiveness

#### 4. Large files cause issues
**Symptoms**: Preview hangs or errors with large files

**Solutions**:
- Files over 50MB are skipped automatically
- Adjust limit in configuration if needed
- Use manual preview for large files

#### 5. Pane management issues
**Symptoms**: Multiple panes or panes not closing

**Solutions**:
- Use `<leader>C` to force close preview panes
- Restart Neovim to clean up orphaned panes
- Check WezTerm pane list: `wezterm cli list`

### Debug Commands

```bash
# Check WezTerm status
wezterm cli list

# Test WezTerm CLI
wezterm cli get-text

# Check environment
echo $WEZTERM_PANE
echo $TTY

# Test preview system
lua /path/to/test_wezterm_preview.lua
```

## Advanced Usage

### Custom File Type Handling

The system automatically detects file types, but you can customize preview commands by modifying the `get_preview_command()` function in the WezTerm utilities.

### Integration with Other Plugins

The preview system works well with:
- **Telescope**: Use oil.nvim for directory browsing, Telescope for file searching
- **Neo-tree**: Alternative file explorer with different workflow
- **FZF**: Complement with fuzzy finding capabilities

### Performance Optimization

1. **Disable auto-preview for large directories**:
   - Use manual preview (`gp`) instead of auto-preview (`gP`)

2. **Adjust debounce delay**:
   - Increase delay for slower systems
   - Decrease for more responsive preview

3. **File size limits**:
   - Reduce for memory-constrained systems
   - Increase for powerful machines

## Tips and Best Practices

### Productivity Tips
1. **Start with manual preview** (`gp`) to understand the system
2. **Enable auto-preview** (`gP`) for rapid file browsing
3. **Use directory preview** to understand project structure
4. **Keep preview pane** open while working in multiple files

### Keyboard Efficiency
1. Learn the core keybindings: `gp`, `gP`, `<leader>P`, `<leader>C`
2. Use global commands for quick access: `<leader>ot`
3. Navigate with `j/k` in auto-preview mode for efficiency

### Workspace Management
1. **Split ratios**: Default 40% for preview is usually optimal
2. **Pane cleanup**: Auto-cleanup handles most cases, manual cleanup with `<leader>C`
3. **Multiple projects**: Each oil buffer gets its own preview pane

## Extending the System

### Adding New File Types

To add support for new file types, modify the `is_text_file()` function:

```lua
local text_extensions = {
  -- Add your extensions here
  "newext", "custom", "special"
}
```

### Custom Preview Commands

Modify `get_preview_command()` for custom preview behavior:

```lua
if ext == "custom" then
  return "custom-preview-command " .. escaped_path
end
```

### Integration Hooks

The system provides hooks for integration:
- `oil_image_preview` global variable for external access
- Configuration functions for dynamic updates
- Event-based cleanup for resource management

## Summary

The WezTerm Preview System provides a powerful and efficient way to preview files within the Neovim ecosystem. With proper setup and understanding of the keybindings, it significantly enhances file browsing and code review workflows.

Key benefits:
- ⚡ **Fast**: Immediate preview without opening files
- 🎨 **Visual**: Image and syntax-highlighted previews  
- 🔧 **Configurable**: Customizable behavior and appearance
- 🛡️ **Robust**: Comprehensive error handling and cleanup
- 🔗 **Integrated**: Seamless oil.nvim and WezTerm integration

For additional help or customization, refer to the configuration files in your dotfiles or the testing documentation.