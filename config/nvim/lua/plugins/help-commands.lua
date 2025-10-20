-- Help Commands Plugin
-- Provides easy access to custom command documentation within Neovim

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      -- Add help keybindings to which-key
      opts.spec = opts.spec or {}
      table.insert(opts.spec, { "<leader>?", group = "Help" })
    end,
  },

  -- Custom help command configuration
  {
    name = "help-commands",
    dir = vim.fn.stdpath("config"),
    config = function()
      -- Path to the COMMANDS.md file
      local commands_file = vim.fn.stdpath("config") .. "/COMMANDS.md"

      -- Function to open COMMANDS.md in a new buffer
      local function open_commands_help()
        -- Check if file exists
        if vim.fn.filereadable(commands_file) == 0 then
          vim.notify("COMMANDS.md not found at: " .. commands_file, vim.log.levels.ERROR)
          return
        end

        -- Open in a new vertical split
        vim.cmd("vsplit " .. commands_file)

        -- Set buffer options for better reading experience
        vim.bo.filetype = "markdown"
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.swapfile = false
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.signcolumn = "no"
        vim.wo.wrap = true
        vim.wo.linebreak = true

        -- Make it read-only
        vim.bo.modifiable = false
        vim.bo.readonly = true

        -- Add a keymap to close the help
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true, desc = "Close help" })
      end

      -- Function to open COMMANDS.md in floating window
      local function open_commands_help_float()
        -- Check if file exists
        if vim.fn.filereadable(commands_file) == 0 then
          vim.notify("COMMANDS.md not found at: " .. commands_file, vim.log.levels.ERROR)
          return
        end

        -- Read file content
        local content = vim.fn.readfile(commands_file)

        -- Calculate window size
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.8)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        -- Create buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

        -- Set buffer options
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
        vim.api.nvim_buf_set_option(buf, "modifiable", false)

        -- Create floating window
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
          title = " Neovim Commands Help ",
          title_pos = "center",
        })

        -- Set window options
        vim.api.nvim_win_set_option(win, "wrap", true)
        vim.api.nvim_win_set_option(win, "linebreak", true)
        vim.api.nvim_win_set_option(win, "number", false)
        vim.api.nvim_win_set_option(win, "relativenumber", false)
        vim.api.nvim_win_set_option(win, "signcolumn", "no")

        -- Add keymap to close the floating window
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "Close help" })
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "Close help" })
      end

      -- Function to search commands
      local function search_commands(query)
        -- Check if file exists
        if vim.fn.filereadable(commands_file) == 0 then
          vim.notify("COMMANDS.md not found at: " .. commands_file, vim.log.levels.ERROR)
          return
        end

        -- Use Telescope if available, otherwise use basic grep
        local has_telescope, telescope = pcall(require, "telescope.builtin")

        if has_telescope then
          telescope.live_grep({
            search_dirs = { commands_file },
            prompt_title = "Search Commands",
            default_text = query or "",
          })
        else
          -- Fallback to vimgrep
          vim.cmd("vimgrep /" .. (query or "") .. "/j " .. commands_file)
          vim.cmd("copen")
        end
      end

      -- Function to show command categories
      local function show_command_categories()
        local categories = {
          "基本操作",
          "ファイル管理",
          "Git操作",
          "LSP",
          "言語別操作",
          "ターミナル",
          "UI・表示",
          "補完・スニペット",
          "ヘルプ・情報",
          "プラグイン管理",
        }

        vim.ui.select(categories, {
          prompt = "コマンドカテゴリを選択:",
          format_item = function(item)
            return "📚 " .. item
          end,
        }, function(choice)
          if choice then
            search_commands(choice)
          end
        end)
      end

      -- Create user commands
      vim.api.nvim_create_user_command("CommandsHelp", function()
        open_commands_help_float()
      end, { desc = "Open commands help in floating window" })

      vim.api.nvim_create_user_command("CommandsHelpSplit", function()
        open_commands_help()
      end, { desc = "Open commands help in split" })

      vim.api.nvim_create_user_command("CommandsSearch", function(opts)
        search_commands(opts.args)
      end, { nargs = "?", desc = "Search commands" })

      vim.api.nvim_create_user_command("CommandsCategories", function()
        show_command_categories()
      end, { desc = "Show command categories" })

      -- Create keybindings
      vim.keymap.set("n", "<leader>?h", "<cmd>CommandsHelp<cr>", { desc = "Commands help (float)" })
      vim.keymap.set("n", "<leader>?s", "<cmd>CommandsHelpSplit<cr>", { desc = "Commands help (split)" })
      vim.keymap.set("n", "<leader>?f", "<cmd>CommandsSearch<cr>", { desc = "Search commands" })
      vim.keymap.set("n", "<leader>?c", "<cmd>CommandsCategories<cr>", { desc = "Command categories" })

      -- Alternative keybindings
      vim.keymap.set("n", "<leader>hc", "<cmd>CommandsHelp<cr>", { desc = "Commands help" })
      vim.keymap.set("n", "<leader>hs", "<cmd>CommandsSearch<cr>", { desc = "Search commands" })

      -- Notify user that help commands are loaded
      vim.notify("Commands help loaded! Use <leader>?h to open help", vim.log.levels.INFO)
    end,
  },
}
