# Image Preview Fix Summary

## Problem Analysis
The Oil.nvim image preview was displaying raw image data instead of properly rendered images in WezTerm. After analyzing the reference implementation from ryoppippi's dotfiles, we identified the root cause and implemented the proper fix.

## Root Cause
The issue was in the `send_command` function in `/Users/takesupasankyu/.dotfiles/config/nvim/lua/utils/wezterm.lua`. The original implementation directly sent the `wezterm imgcat` command with a newline, which caused the shell to interpret and execute the command immediately, resulting in raw image data being dumped to the terminal.

**Original problematic code:**
```lua
local cmd = string.format(
  "%s cli send-text --pane-id %s --no-paste %s",
  WEZTERM_CMD,
  shell_escape(pane_id),
  shell_escape(command .. "\n")
)
```

## Solution
Updated the command sending method to use `echo` to pipe the command properly, matching the reference implementation. This ensures proper command execution within the WezTerm pane context.

**Fixed code:**
```lua
local cmd = string.format(
  "echo %s | %s cli send-text --no-paste --pane-id %s",
  shell_escape(command),
  WEZTERM_CMD,
  shell_escape(pane_id)
)
```

## Key Changes Made

### 1. Updated Command Sending Method
- File: `/Users/takesupasankyu/.dotfiles/config/nvim/lua/utils/wezterm.lua`
- Changed `send_command` function to use echo piping
- Ensures proper command execution context

### 2. Added Command State Tracking
- File: `/Users/takesupasankyu/.dotfiles/config/nvim/lua/plugins/image-preview.lua`
- Added `last_commands` table to track command types per pane
- Enables proper cleanup (e.g., sending 'q' to quit bat before showing new files)

### 3. Enhanced Cleanup Functions
- Added `send_quit_command` function to WezTerm utilities
- Updated cleanup autocmds to handle command state
- Improved pane management and resource cleanup

### 4. Better Error Handling
- Enhanced error handling throughout the preview pipeline
- Added proper command state management
- Improved cleanup on buffer deletion and Neovim exit

## Reference Implementation Analysis
The reference implementation from ryoppippi's dotfiles showed the correct pattern:

```lua
local sendCommandToWeztermPane = function(wezterm_pane_id, command)
  local cmd = {
    "echo",
    ("'%s'"):format(command),
    "|",
    "wezterm",
    "cli",
    "send-text",
    "--no-paste",
    ("--pane-id=%d"):format(wezterm_pane_id),
  }
  vim.fn.system(table.concat(cmd, " "))
end
```

## Testing
- Created test files in `/tmp/oil_test_files/`
- Added both text and image files for testing
- Verified command formatting with test script
- Confirmed proper echo piping implementation

## Expected Behavior
With these fixes:
1. Images should display properly using `wezterm imgcat` instead of showing raw data
2. Command state is properly tracked and cleaned up
3. Transitions between different file types (text, images, directories) work smoothly
4. Preview panes are properly managed and cleaned up

## Files Modified
1. `/Users/takesupasankyu/.dotfiles/config/nvim/lua/utils/wezterm.lua`
2. `/Users/takesupasankyu/.dotfiles/config/nvim/lua/plugins/image-preview.lua`

## Test Files Created
1. `/Users/takesupasankyu/.dotfiles/config/nvim/test_image_fix.lua`
2. `/tmp/oil_test_files/test.txt`
3. `/tmp/oil_test_files/test_image.png`

The fix addresses the core issue of command execution context and should resolve the raw image data display problem when using Oil.nvim with WezTerm image preview.