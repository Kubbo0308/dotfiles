-- WezTerm Pane Management Utility Module
-- This module provides comprehensive pane management functionality for WezTerm integration
-- Author: Claude Code
-- Version: 1.0

local M = {}

-- Configuration constants
local WEZTERM_CMD = "wezterm"
local PREVIEW_PANE_SIZE = "30%"
local PREVIEW_SPLIT_DIRECTION = "right"

-- Error handling wrapper for shell commands
local function execute_shell_command(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return nil, "Failed to execute command: " .. cmd
  end
  
  local result = handle:read("*a")
  local success = handle:close()
  
  if not success then
    return nil, "Command failed: " .. cmd
  end
  
  return result:gsub("%s+$", ""), nil -- trim trailing whitespace
end

-- Escape shell arguments to prevent command injection
local function shell_escape(str)
  if not str then return "" end
  -- Escape single quotes and wrap in single quotes
  return "'" .. str:gsub("'", "'\\''") .. "'"
end

-- ============================================================================
-- PANE MANAGEMENT FUNCTIONS
-- ============================================================================

--- Get the current pane ID
-- @return string|nil pane_id The current pane ID, or nil if failed
-- @return string|nil error Error message if failed
function M.get_current_pane_id()
  -- First try to get from environment variable (most reliable)
  local env_pane_id = os.getenv("WEZTERM_PANE")
  if env_pane_id then
    return env_pane_id, nil
  end
  
  -- Fallback to CLI command
  local result, err = execute_shell_command(WEZTERM_CMD .. " cli list --format json")
  if err then
    return nil, "Failed to get current pane ID: " .. err
  end
  
  -- Simple JSON parsing to find active pane
  -- Look for the active pane in the current process
  local current_tty = os.getenv("TTY")
  if current_tty then
    local pane_id = result:match('"tty_name":"' .. current_tty:gsub("[%-%+%*%?%^%$%(%)%[%]%%]", "%%%1") .. '".-"pane_id":(%d+)')
    if pane_id then
      return pane_id, nil
    end
  end
  
  -- Look for active pane
  local pane_id = result:match('"is_active":true.-"pane_id":(%d+)')
  if not pane_id then
    pane_id = result:match('"pane_id":(%d+)') -- Get first pane as fallback
  end
  
  if not pane_id then
    return nil, "Could not find current pane ID in result"
  end
  
  return pane_id, nil
end

--- Create a preview pane by splitting the current pane
-- @param direction string Optional split direction ("right", "left", "up", "down")
-- @param size string Optional size percentage (e.g., "30%" or "30")
-- @return string|nil pane_id The new pane ID, or nil if failed
-- @return string|nil error Error message if failed
function M.create_preview_pane(direction, size)
  direction = direction or PREVIEW_SPLIT_DIRECTION
  size = size or PREVIEW_PANE_SIZE
  
  -- Convert size to number if it contains %
  local size_num = size
  if type(size) == "string" and size:match("%%") then
    size_num = size:gsub("%%", "")
  end
  
  -- Convert direction to the proper flag
  local direction_flag = "--" .. direction:lower()
  
  local cmd = string.format(
    "%s cli split-pane --percent %s %s",
    WEZTERM_CMD,
    shell_escape(size_num),
    direction_flag
  )
  
  local result, err = execute_shell_command(cmd)
  if err then
    return nil, "Failed to create preview pane: " .. err
  end
  
  -- Extract pane ID from the result
  -- The result should be just the pane ID number
  local pane_id = result:match("^%s*(%d+)%s*$")
  if not pane_id then
    return nil, "Could not parse new pane ID from result: " .. result
  end
  
  return pane_id, nil
end

--- Check if a pane exists
-- @param pane_id string The pane ID to check
-- @return boolean true if pane exists, false otherwise
function M.pane_exists(pane_id)
  if not pane_id then return false end
  
  local cmd = string.format("%s cli list --format json", WEZTERM_CMD)
  local result, err = execute_shell_command(cmd)
  if err then
    return false
  end
  
  -- Simple check if pane ID exists in the JSON output
  -- Handle both string and number pane IDs, account for JSON formatting
  local pane_id_str = tostring(pane_id)
  return result:find('"pane_id":%s*' .. pane_id_str) ~= nil
end

--- Close a specific pane
-- @param pane_id string The pane ID to close
-- @return boolean success True if pane was closed successfully
-- @return string|nil error Error message if failed
function M.close_pane(pane_id)
  if not pane_id then
    return false, "No pane ID provided"
  end
  
  if not M.pane_exists(pane_id) then
    return true, nil -- Pane already closed, consider it success
  end
  
  local cmd = string.format("%s cli kill-pane --pane-id %s", WEZTERM_CMD, shell_escape(pane_id))
  local _, err = execute_shell_command(cmd)
  if err then
    return false, "Failed to close pane: " .. err
  end
  
  return true, nil
end

--- Focus a specific pane
-- @param pane_id string The pane ID to focus
-- @return boolean success True if pane was focused successfully
-- @return string|nil error Error message if failed
function M.focus_pane(pane_id)
  if not pane_id then
    return false, "No pane ID provided"
  end
  
  if not M.pane_exists(pane_id) then
    return false, "Pane does not exist: " .. pane_id
  end
  
  local cmd = string.format("%s cli activate-pane --pane-id %s", WEZTERM_CMD, shell_escape(pane_id))
  local _, err = execute_shell_command(cmd)
  if err then
    return false, "Failed to focus pane: " .. err
  end
  
  return true, nil
end

-- ============================================================================
-- COMMAND EXECUTION FUNCTIONS
-- ============================================================================

--- Send a command to a specific pane
-- @param pane_id string The pane ID to send the command to
-- @param command string The command to send
-- @return boolean success True if command was sent successfully
-- @return string|nil error Error message if failed
function M.send_command(pane_id, command)
  if not pane_id then
    return false, "No pane ID provided"
  end
  
  if not command then
    return false, "No command provided"
  end
  
  if not M.pane_exists(pane_id) then
    return false, "Pane does not exist: " .. pane_id
  end
  
  -- Use echo to pipe the command properly, matching reference implementation
  local cmd = string.format(
    "echo %s | %s cli send-text --no-paste --pane-id %s",
    shell_escape(command),
    WEZTERM_CMD,
    shell_escape(pane_id)
  )
  
  local _, err = execute_shell_command(cmd)
  if err then
    return false, "Failed to send command: " .. err
  end
  
  return true, nil
end

--- Clear a specific pane
-- @param pane_id string The pane ID to clear
-- @return boolean success True if pane was cleared successfully
-- @return string|nil error Error message if failed
function M.clear_pane(pane_id)
  if not pane_id then
    return false, "No pane ID provided"
  end
  
  -- Send clear command to the pane
  return M.send_command(pane_id, "clear")
end

--- Send a quit command to a specific pane (useful for bat, less, etc.)
-- @param pane_id string The pane ID to send quit command to
-- @return boolean success True if command was sent successfully
-- @return string|nil error Error message if failed
function M.send_quit_command(pane_id)
  if not pane_id then
    return false, "No pane ID provided"
  end
  
  -- Send 'q' command to quit interactive programs like bat
  return M.send_command(pane_id, "q")
end

--- Preview a file in a specific pane
-- @param pane_id string The pane ID to preview the file in
-- @param filepath string The file path to preview
-- @return boolean success True if file was previewed successfully
-- @return string|nil error Error message if failed
function M.preview_file(pane_id, filepath)
  if not pane_id then
    return false, "No pane ID provided"
  end
  
  if not filepath then
    return false, "No file path provided"
  end
  
  if not M.pane_exists(pane_id) then
    return false, "Pane does not exist: " .. pane_id
  end
  
  -- Clear the pane first
  local success, err = M.clear_pane(pane_id)
  if not success then
    return false, "Failed to clear pane: " .. (err or "unknown error")
  end
  
  -- Get the appropriate preview command
  local preview_cmd = M.get_preview_command(filepath)
  if not preview_cmd then
    return false, "Unsupported file type for preview: " .. filepath
  end
  
  -- Send the preview command
  return M.send_command(pane_id, preview_cmd)
end

-- ============================================================================
-- FILE TYPE DETECTION FUNCTIONS
-- ============================================================================

--- Get the file type (directory, image, or other)
-- @param filepath string The file path to analyze
-- @return string file_type The detected file type ("directory", "image", "other")
function M.get_file_type(filepath)
  if not filepath then return "other" end
  
  -- Check if it's a directory
  local dir_check = execute_shell_command("test -d " .. shell_escape(filepath) .. " && echo 'directory'")
  if dir_check and dir_check:find("directory") then
    return "directory"
  end
  
  -- Check if it's an image by extension
  local extension = filepath:match("%.([^%.]+)$")
  if extension then
    extension = extension:lower()
    local image_extensions = {
      png = true, jpg = true, jpeg = true, gif = true,
      bmp = true, tiff = true, tif = true, webp = true,
      svg = true, ico = true, heic = true, heif = true
    }
    
    if image_extensions[extension] then
      return "image"
    end
  end
  
  return "other"
end

--- Get the appropriate preview command for a file
-- @param filepath string The file path to get preview command for
-- @return string|nil command The preview command, or nil if unsupported
function M.get_preview_command(filepath)
  if not filepath or filepath == "" then return nil end
  
  local file_type = M.get_file_type(filepath)
  local escaped_path = shell_escape(filepath)
  
  if file_type == "directory" then
    -- Use ls with color output for directories
    return "ls -la --color=always " .. escaped_path
  elseif file_type == "image" then
    -- Use wezterm imgcat for images - ensure proper command format
    return "wezterm imgcat " .. escaped_path
  else
    -- Use bat for other files (with fallback to cat)
    -- First try bat, then fallback to cat if bat is not available
    return string.format(
      "command -v bat >/dev/null 2>&1 && bat --color=always --style=numbers,changes %s || cat %s",
      escaped_path,
      escaped_path
    )
  end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

--- Get WezTerm version information
-- @return string|nil version The WezTerm version, or nil if failed
function M.get_wezterm_version()
  local result, err = execute_shell_command(WEZTERM_CMD .. " --version")
  if err then
    return nil
  end
  
  -- Extract version from output
  local version = result:match("wezterm ([%d%.%-a-zA-Z]+)")
  return version
end

--- Check if WezTerm CLI is available
-- @return boolean available True if WezTerm CLI is available
function M.is_wezterm_available()
  local result, _ = execute_shell_command("command -v " .. WEZTERM_CMD)
  return result ~= nil and result ~= ""
end

--- Get all panes information
-- @return table|nil panes Array of pane information, or nil if failed
function M.get_all_panes()
  local result, err = execute_shell_command(WEZTERM_CMD .. " cli list-panes --format json")
  if err then
    return nil
  end
  
  -- In a real implementation, you might want to parse JSON properly
  -- For now, we'll return the raw JSON string
  -- TODO: Add proper JSON parsing if needed
  return result
end

--- Create a new tab and return its information
-- @param name string Optional tab name
-- @return string|nil tab_id The new tab ID, or nil if failed
function M.create_new_tab(name)
  local cmd = WEZTERM_CMD .. " cli spawn"
  if name then
    cmd = cmd .. " --new-tab --tab-title " .. shell_escape(name)
  else
    cmd = cmd .. " --new-tab"
  end
  
  local result, err = execute_shell_command(cmd)
  if err then
    return nil
  end
  
  -- Extract tab ID from result
  local tab_id = result:match("tab%-id:(%d+)")
  return tab_id
end

-- ============================================================================
-- MODULE VALIDATION
-- ============================================================================

--- Validate that all required functionality is working
-- @return boolean success True if all validations pass
-- @return table results Detailed validation results
function M.validate_functionality()
  local results = {
    wezterm_available = M.is_wezterm_available(),
    can_get_pane_id = false,
    can_create_pane = false,
    can_send_command = false,
    overall_success = false
  }
  
  if not results.wezterm_available then
    results.error = "WezTerm CLI not available"
    return false, results
  end
  
  -- Test getting current pane ID
  local pane_id, err = M.get_current_pane_id()
  if pane_id then
    results.can_get_pane_id = true
  else
    results.get_pane_id_error = err
  end
  
  -- Test pane existence check
  if pane_id then
    results.can_check_pane_exists = M.pane_exists(pane_id)
  end
  
  -- Overall success if basic functionality works
  results.overall_success = results.wezterm_available and results.can_get_pane_id
  
  return results.overall_success, results
end

-- ============================================================================
-- EXAMPLE USAGE AND DOCUMENTATION
-- ============================================================================

--[[
EXAMPLE USAGE:

local wezterm = require('utils.wezterm')

-- Basic pane management
local current_pane = wezterm.get_current_pane_id()
local preview_pane = wezterm.create_preview_pane("right", "40%")

-- File preview
if preview_pane then
  wezterm.preview_file(preview_pane, "/path/to/file.txt")
end

-- Command execution
wezterm.send_command(preview_pane, "echo 'Hello World'")

-- Cleanup
wezterm.close_pane(preview_pane)

-- File type detection
local file_type = wezterm.get_file_type("/path/to/image.png") -- returns "image"
local preview_cmd = wezterm.get_preview_command("/path/to/dir") -- returns "ls -la --color=always '/path/to/dir'"

-- Validation
local success, results = wezterm.validate_functionality()
if not success then
  print("WezTerm functionality validation failed:", vim.inspect(results))
end
--]]

return M