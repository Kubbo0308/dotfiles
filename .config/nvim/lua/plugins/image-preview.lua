-- Enhanced Oil.nvim File Preview Plugin
-- Features:
-- - Smart auto-preview on cursor movement with debouncing
-- - WezTerm pane integration for images, text files, and directories
-- - Configurable file type detection and preview limits
-- - Automatic cleanup of preview panes
-- - Multiple keybindings for manual and automatic preview control
--
-- Auto-preview can be toggled with <leader>ot or gP in oil buffers
-- Preview current item with <leader>op or gp in oil buffers
-- View/modify configuration with <leader>oc and <leader>od

return {
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { mode = "n", "<leader>o", "<cmd>Oil<cr>", desc = "Open Oil file manager" },
      { mode = "n", "<leader>O", "<cmd>Oil --float<cr>", desc = "Open Oil in floating window" },
    },
    config = function()
      local oil = require("oil")
      
      -- Import WezTerm utilities
      local wezterm = require('utils.wezterm')
      
      -- Image preview utilities
      local image_preview = {}
      
      -- Store preview pane information for each buffer
      local preview_panes = {}
      
      -- Store the last command sent to each pane (for proper cleanup)
      local last_commands = {}
      
      -- Configuration for auto-preview
      local config = {
        auto_preview_enabled = true, -- Enable by default for automatic behavior
        debounce_delay = 150, -- milliseconds (faster response)
        max_file_size = 50 * 1024 * 1024, -- 50MB limit for text files
        enable_directory_preview = true,
        enable_image_preview = true,
        enable_text_preview = true,
        auto_create_pane = true, -- Automatically create preview pane on cursor movement
      }
      
      -- Debounce timer for cursor movement
      local debounce_timer = nil
      local last_cursor_entry = nil
      
      -- Check if file is an image
      function image_preview.is_image(filename)
        local ext = vim.fn.fnamemodify(filename, ":e"):lower()
        local image_extensions = { "png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "svg", "ico", "heic", "heif" }
        for _, image_ext in ipairs(image_extensions) do
          if ext == image_ext then
            return true
          end
        end
        return false
      end
      
      -- Check if file is a text file that can be previewed
      function image_preview.is_text_file(filename)
        local ext = vim.fn.fnamemodify(filename, ":e"):lower()
        local text_extensions = {
          "txt", "md", "lua", "py", "js", "ts", "json", "yaml", "yml", "toml", "cfg", "conf",
          "sh", "bash", "zsh", "fish", "vim", "vimrc", "html", "css", "scss", "sass", "xml",
          "go", "rs", "c", "cpp", "h", "hpp", "java", "kt", "php", "rb", "pl", "swift", "dart",
          "r", "sql", "dockerfile", "makefile", "cmake", "ini", "gitignore", "gitconfig",
          "log", "tex", "bib", "csv", "tsv", "diff", "patch", "org", "rst", "adoc"
        }
        
        -- Check by extension
        for _, text_ext in ipairs(text_extensions) do
          if ext == text_ext then
            return true
          end
        end
        
        -- Check common files without extensions
        local basename = vim.fn.fnamemodify(filename, ":t"):lower()
        local common_text_files = {
          "readme", "license", "changelog", "todo", "authors", "contributors", "copying",
          "install", "news", "thanks", "makefile", "dockerfile", "jenkinsfile", "vagrantfile"
        }
        
        for _, common_file in ipairs(common_text_files) do
          if basename == common_file then
            return true
          end
        end
        
        return false
      end
      
      -- Get file size in bytes
      function image_preview.get_file_size(filepath)
        local stat = vim.loop.fs_stat(filepath)
        return stat and stat.size or 0
      end
      
      -- Check if file can be previewed
      function image_preview.can_preview_file(filepath, filename)
        if not filepath or not filename then
          return false, "No file provided"
        end
        
        -- Check if file exists
        if vim.fn.filereadable(filepath) == 0 then
          return false, "File is not readable"
        end
        
        -- Check file size for text files
        if image_preview.is_text_file(filename) then
          local size = image_preview.get_file_size(filepath)
          if size > config.max_file_size then
            return false, "File too large for preview (" .. math.floor(size / 1024 / 1024) .. "MB)"
          end
        end
        
        return true, nil
      end
      
      -- Preview image using WezTerm imgcat (legacy method)
      function image_preview.preview_image(filepath)
        if not filepath then return end
        
        -- Check if WezTerm is available
        if vim.fn.executable("wezterm") == 0 then
          vim.notify("WezTerm is not available for image preview", vim.log.levels.WARN)
          return
        end
        
        -- Display image with imgcat
        local cmd = string.format("wezterm imgcat --width 50%% %s", vim.fn.shellescape(filepath))
        vim.fn.system(cmd)
      end
      
      -- Create or get preview pane for current buffer
      function image_preview.get_or_create_preview_pane()
        local bufnr = vim.api.nvim_get_current_buf()
        
        -- Check if we already have a preview pane for this buffer
        local existing_pane = preview_panes[bufnr]
        if existing_pane and wezterm.pane_exists(existing_pane) then
          return existing_pane
        end
        
        -- Create new preview pane
        local pane_id, err = wezterm.create_preview_pane("right", "40%")
        if not pane_id then
          vim.notify("Failed to create preview pane: " .. (err or "unknown error"), vim.log.levels.ERROR)
          return nil
        end
        
        -- Store the pane ID for this buffer
        preview_panes[bufnr] = pane_id
        
        -- Get current pane ID to return focus later
        local current_pane, _ = wezterm.get_current_pane_id()
        
        -- Return focus to Neovim pane
        if current_pane then
          vim.defer_fn(function()
            wezterm.focus_pane(current_pane)
          end, 100)
        end
        
        return pane_id
      end
      
      -- Preview file in WezTerm pane
      function image_preview.preview_file_in_pane(filepath)
        if not filepath then
          vim.notify("No file path provided", vim.log.levels.WARN)
          return
        end
        
        -- Check if WezTerm is available
        if not wezterm.is_wezterm_available() then
          vim.notify("WezTerm CLI is not available", vim.log.levels.WARN)
          return
        end
        
        -- Get or create preview pane
        local pane_id = image_preview.get_or_create_preview_pane()
        if not pane_id then
          return
        end
        
        -- Handle cleanup for previous commands (similar to reference implementation)
        local last_cmd = last_commands[pane_id]
        if last_cmd == "bat" then
          -- Send quit command to close bat before showing new file
          wezterm.send_quit_command(pane_id)
          last_commands[pane_id] = nil
        end
        
        -- Preview the file
        local success, err = wezterm.preview_file(pane_id, filepath)
        if not success then
          vim.notify("Failed to preview file: " .. (err or "unknown error"), vim.log.levels.ERROR)
        else
          -- Track the command type for proper cleanup
          local file_type = wezterm.get_file_type(filepath)
          if file_type == "image" then
            last_commands[pane_id] = "wezterm imgcat"
          elseif file_type == "directory" then
            last_commands[pane_id] = "ls"
          else
            last_commands[pane_id] = "bat"
          end
        end
      end
      
      -- Close preview pane for current buffer
      function image_preview.close_preview_pane()
        local bufnr = vim.api.nvim_get_current_buf()
        local pane_id = preview_panes[bufnr]
        
        if pane_id then
          local success, err = wezterm.close_pane(pane_id)
          if not success then
            vim.notify("Failed to close preview pane: " .. (err or "unknown error"), vim.log.levels.WARN)
          end
          
          -- Remove from our tracking
          preview_panes[bufnr] = nil
          last_commands[pane_id] = nil
        end
      end
      
      -- Clear preview pane for current buffer
      function image_preview.clear_preview_pane()
        local bufnr = vim.api.nvim_get_current_buf()
        local pane_id = preview_panes[bufnr]
        
        if pane_id and wezterm.pane_exists(pane_id) then
          local success, err = wezterm.clear_pane(pane_id)
          if not success then
            vim.notify("Failed to clear preview pane: " .. (err or "unknown error"), vim.log.levels.WARN)
          end
          -- Clear the command state
          last_commands[pane_id] = nil
        end
      end
      
      -- Clear terminal (optional, for better preview experience)
      function image_preview.clear_preview()
        vim.cmd("redraw!")
      end
      
      -- Enhanced auto-preview with debouncing and smart file type detection
      function image_preview.auto_preview()
        -- Cancel previous debounce timer
        if debounce_timer then
          vim.fn.timer_stop(debounce_timer)
          debounce_timer = nil
        end
        
        -- Get current entry
        local entry = oil.get_cursor_entry()
        if not entry then
          return
        end
        
        -- Skip if same entry as last time (avoid redundant updates)
        if last_cursor_entry and 
           last_cursor_entry.name == entry.name and 
           last_cursor_entry.type == entry.type then
          return
        end
        
        -- Update last cursor entry
        last_cursor_entry = entry
        
        -- Check if we have a preview pane for this buffer
        local bufnr = vim.api.nvim_get_current_buf()
        local pane_id = preview_panes[bufnr]
        
        -- Auto-create preview pane if it doesn't exist and auto_create_pane is enabled
        if (not pane_id or not wezterm.pane_exists(pane_id)) and config.auto_create_pane then
          -- Create preview pane automatically
          pane_id = image_preview.get_or_create_preview_pane()
          if not pane_id then
            return
          end
        elseif not pane_id or not wezterm.pane_exists(pane_id) then
          -- No preview pane exists and auto-create is disabled
          return
        end
        
        -- Debounce the preview update
        debounce_timer = vim.fn.timer_start(config.debounce_delay, function()
          image_preview.update_preview_for_entry(entry)
          debounce_timer = nil
        end)
      end
      
      -- Update preview for a specific entry
      function image_preview.update_preview_for_entry(entry)
        if not entry then
          return
        end
        
        local current_dir = oil.get_current_dir()
        local filepath = current_dir .. entry.name
        
        -- Handle different entry types
        if entry.type == "file" then
          -- Check if file can be previewed
          local can_preview, error_msg = image_preview.can_preview_file(filepath, entry.name)
          if not can_preview then
            image_preview.show_preview_message(error_msg or "Cannot preview file")
            return
          end
          
          -- Preview based on file type
          if config.enable_image_preview and image_preview.is_image(entry.name) then
            image_preview.preview_file_in_pane(filepath)
          elseif config.enable_text_preview and image_preview.is_text_file(entry.name) then
            image_preview.preview_file_in_pane(filepath)
          else
            -- Try to preview anyway, let wezterm utilities handle it
            image_preview.preview_file_in_pane(filepath)
          end
        elseif entry.type == "directory" and config.enable_directory_preview then
          image_preview.preview_file_in_pane(filepath)
        else
          -- Clear preview for unsupported types
          image_preview.show_preview_message("No preview available for this item")
        end
      end
      
      -- Show a message in the preview pane
      function image_preview.show_preview_message(message)
        local bufnr = vim.api.nvim_get_current_buf()
        local pane_id = preview_panes[bufnr]
        
        if pane_id and wezterm.pane_exists(pane_id) then
          -- Clear the pane first
          wezterm.clear_pane(pane_id)
          
          -- Send an echo command with the message
          local cmd = string.format("echo '%s'", message:gsub("'", "'\'''"))
          wezterm.send_command(pane_id, cmd)
        end
      end
      
      -- Enhanced preview file function with better error handling
      function image_preview.preview_file_in_pane_enhanced(filepath)
        if not filepath then
          vim.notify("No file path provided", vim.log.levels.WARN)
          return
        end
        
        -- Check if WezTerm is available
        if not wezterm.is_wezterm_available() then
          vim.notify("WezTerm CLI is not available", vim.log.levels.WARN)
          return
        end
        
        -- Get or create preview pane
        local pane_id = image_preview.get_or_create_preview_pane()
        if not pane_id then
          return
        end
        
        -- Preview the file with enhanced error handling
        local success, err = wezterm.preview_file(pane_id, filepath)
        if not success then
          -- Show error message in preview pane instead of notification
          image_preview.show_preview_message("Error: " .. (err or "Failed to preview file"))
        end
      end
      
      -- Alias for backward compatibility
      image_preview.preview_file_in_pane = image_preview.preview_file_in_pane_enhanced
      
      oil.setup({
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = "nvic",
        },
        delete_to_trash = true,
        skip_confirm_for_simple_edits = false,
        prompt_save_on_select_new_entry = true,
        cleanup_delay_ms = 2000,
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
          -- Custom image preview keybindings
          ["gP"] = {
            desc = "Toggle auto-preview on cursor movement",
            callback = function()
              image_preview.toggle_auto_preview()
            end,
          },
          ["<leader>p"] = {
            desc = "Preview image (legacy)",
            callback = function()
              local entry = oil.get_cursor_entry()
              if entry and entry.type == "file" then
                local path = oil.get_current_dir() .. entry.name
                if image_preview.is_image(entry.name) then
                  image_preview.preview_image(path)
                else
                  vim.notify("Not an image file", vim.log.levels.INFO)
                end
              end
            end,
          },
          ["<leader>P"] = {
            desc = "Clear preview pane",
            callback = function()
              image_preview.clear_preview_pane()
            end,
          },
          ["<leader>C"] = {
            desc = "Close preview pane",
            callback = function()
              image_preview.close_preview_pane()
            end,
          },
        },
        use_default_keymaps = true,
        view_options = {
          show_hidden = false,
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, ".")
          end,
          is_always_hidden = function(name, bufnr)
            return false
          end,
        },
        float = {
          padding = 2,
          max_width = 0,
          max_height = 0,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
        },
        preview = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = 0.9,
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
        },
      })
      
      -- Configuration functions
      function image_preview.toggle_auto_preview()
        config.auto_preview_enabled = not config.auto_preview_enabled
        if config.auto_preview_enabled then
          vim.notify("Oil auto-preview enabled", vim.log.levels.INFO)
        else
          vim.notify("Oil auto-preview disabled", vim.log.levels.INFO)
          -- Cancel any pending debounce timer
          if debounce_timer then
            vim.fn.timer_stop(debounce_timer)
            debounce_timer = nil
          end
        end
      end
      
      function image_preview.set_debounce_delay(delay)
        config.debounce_delay = math.max(50, math.min(1000, delay)) -- Clamp between 50ms and 1000ms
        vim.notify("Oil auto-preview debounce delay set to " .. config.debounce_delay .. "ms", vim.log.levels.INFO)
      end
      
      function image_preview.get_config()
        return vim.deepcopy(config)
      end
      
      function image_preview.update_config(updates)
        for key, value in pairs(updates) do
          if config[key] ~= nil then
            config[key] = value
          end
        end
        vim.notify("Oil auto-preview configuration updated", vim.log.levels.INFO)
      end
      
      -- Enhanced commands
      vim.api.nvim_create_user_command("OilToggleAutoPreview", function()
        image_preview.toggle_auto_preview()
      end, { desc = "Toggle Oil auto-preview on cursor movement" })
      
      vim.api.nvim_create_user_command("OilSetDebounceDelay", function(opts)
        local delay = tonumber(opts.args)
        if delay then
          image_preview.set_debounce_delay(delay)
        else
          vim.notify("Please provide a numeric delay in milliseconds", vim.log.levels.ERROR)
        end
      end, { nargs = 1, desc = "Set Oil auto-preview debounce delay in milliseconds" })
      
      vim.api.nvim_create_user_command("OilShowConfig", function()
        vim.notify("Oil auto-preview config: " .. vim.inspect(config), vim.log.levels.INFO)
      end, { desc = "Show Oil auto-preview configuration" })
      
      vim.api.nvim_create_user_command("OilPreviewCurrent", function()
        local entry = oil.get_cursor_entry()
        if entry then
          image_preview.update_preview_for_entry(entry)
        else
          vim.notify("No item under cursor", vim.log.levels.WARN)
        end
      end, { desc = "Preview current item under cursor" })
      
      -- Enhanced auto-preview autocmds
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        pattern = "oil://*",
        callback = function()
          if config.auto_preview_enabled then
            image_preview.auto_preview()
          end
        end,
        desc = "Auto-preview files on cursor movement in Oil"
      })
      
      -- Clear cursor tracking when leaving oil buffers
      vim.api.nvim_create_autocmd("BufLeave", {
        pattern = "oil://*",
        callback = function()
          -- Cancel any pending debounce timer
          if debounce_timer then
            vim.fn.timer_stop(debounce_timer)
            debounce_timer = nil
          end
          -- Clear last cursor entry
          last_cursor_entry = nil
        end,
        desc = "Clean up auto-preview state when leaving Oil buffer"
      })
      
      -- Reset cursor tracking when entering oil buffers and trigger initial preview
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "oil://*",
        callback = function()
          -- Clear last cursor entry to force initial preview
          last_cursor_entry = nil
          
          -- Trigger auto-preview after a short delay to ensure oil is fully loaded
          if config.auto_preview_enabled then
            vim.defer_fn(function()
              image_preview.auto_preview()
            end, 50) -- Small delay to ensure oil buffer is ready
          end
        end,
        desc = "Reset auto-preview state and trigger initial preview when entering Oil buffer"
      })
      
      -- Cleanup autocmd - close preview panes when oil buffers are closed
      vim.api.nvim_create_autocmd("BufDelete", {
        pattern = "oil://*",
        callback = function(event)
          local bufnr = event.buf
          local pane_id = preview_panes[bufnr]
          
          if pane_id then
            -- Close the preview pane
            local success, err = wezterm.close_pane(pane_id)
            if not success then
              vim.notify("Failed to close preview pane during cleanup: " .. (err or "unknown error"), vim.log.levels.WARN)
            end
            
            -- Remove from our tracking
            preview_panes[bufnr] = nil
            last_commands[pane_id] = nil
          end
        end,
      })
      
      -- Additional cleanup for when Neovim exits
      vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
          -- Close all tracked preview panes
          for bufnr, pane_id in pairs(preview_panes) do
            if pane_id then
              wezterm.close_pane(pane_id)
            end
          end
          preview_panes = {}
          last_commands = {}
        end,
      })
      
      -- Add keybindings for auto-preview functionality
      vim.keymap.set("n", "<leader>ot", "<cmd>OilToggleAutoPreview<cr>", { desc = "Toggle Oil auto-preview" })
      vim.keymap.set("n", "<leader>op", "<cmd>OilPreviewCurrent<cr>", { desc = "Preview current item" })
      vim.keymap.set("n", "<leader>oc", "<cmd>OilShowConfig<cr>", { desc = "Show Oil auto-preview config" })
      vim.keymap.set("n", "<leader>od", function()
        vim.ui.input({ prompt = "Enter debounce delay (ms): ", default = tostring(config.debounce_delay) }, function(input)
          if input then
            vim.cmd("OilSetDebounceDelay " .. input)
          end
        end)
      end, { desc = "Set Oil auto-preview debounce delay" })
      
      -- Store the image_preview module for external access
      _G.oil_image_preview = image_preview
    end,
  },
}