return {
  -- Far.vim for VSCode-like search and replace
  {
    "brooth/far.vim",
    cmd = { "Far", "Farp", "F", "Farr", "Fardo" },
    keys = {
      { "<leader>sf", "<cmd>Far<cr>", desc = "Search in files (Far.vim)" },
      { "<leader>sr", "<cmd>Farr<cr>", desc = "Search and replace in files" },
      { "<C-s>", "<cmd>Far<cr>", desc = "Search in files", mode = { "n", "v" } },
      { "<C-g>", "<cmd>Farr<cr>", desc = "Search and replace", mode = { "n", "v" } },
    },
    config = function()
      -- Use ripgrep as the backend
      vim.g["far#source"] = "rgnvim"
      
      -- Enable undo functionality
      vim.g["far#enable_undo"] = 2
      
      -- Set window layout (current, tab, top, left, right)
      vim.g["far#window_layout"] = "tab"
      
      -- Set window width/height
      vim.g["far#window_width"] = 0.85
      vim.g["far#window_height"] = 0.85
      
      -- Auto expand directories
      vim.g["far#auto_expand"] = 1
      
      -- Highlight search results
      vim.g["far#highlight_match"] = 1
      
      -- Use preview window
      vim.g["far#preview_window_layout"] = "right"
      vim.g["far#preview_window_width"] = 0.4
      
      -- Default file mask (can be overridden)
      vim.g["far#file_mask_favorites"] = {
        "**/*.js",
        "**/*.ts",
        "**/*.jsx",
        "**/*.tsx",
        "**/*.lua",
        "**/*.py",
        "**/*.go",
        "**/*.rs",
        "**/*.c",
        "**/*.cpp",
        "**/*.h",
        "**/*.hpp",
        "**/*.md",
        "**/*.txt",
        "**/*.json",
        "**/*.yaml",
        "**/*.yml",
        "**/*.toml",
        "**/*.vim",
        "**/*.sh",
        "**/*.zsh",
        "**/*.bash",
      }
      
      -- Ignore patterns
      vim.g["far#ignore_files"] = {
        "*.git/*",
        "*/node_modules/*",
        "*/target/*",
        "*/dist/*",
        "*/build/*",
        "*.lock",
        "package-lock.json",
        "yarn.lock",
        "*.log",
        "*.tmp",
        "*.temp",
      }
      
      -- Ripgrep arguments
      vim.g["far#rg_args"] = "--hidden --smart-case --no-heading --color=never --line-number --column"
      
      -- Key mappings within Far buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "far",
        callback = function()
          local opts = { buffer = true, silent = true }
          
          -- Navigation
          vim.keymap.set("n", "<CR>", "<Plug>(far-jump-to-source)", opts)
          vim.keymap.set("n", "o", "<Plug>(far-jump-to-source)", opts)
          vim.keymap.set("n", "O", "<Plug>(far-jump-to-source-split)", opts)
          vim.keymap.set("n", "v", "<Plug>(far-jump-to-source-vsplit)", opts)
          vim.keymap.set("n", "t", "<Plug>(far-jump-to-source-tab)", opts)
          
          -- Selection
          vim.keymap.set("n", "x", "<Plug>(far-exclude-item)", opts)
          vim.keymap.set("n", "i", "<Plug>(far-include-item)", opts)
          vim.keymap.set("n", "X", "<Plug>(far-exclude-file)", opts)
          vim.keymap.set("n", "I", "<Plug>(far-include-file)", opts)
          vim.keymap.set("n", "a", "<Plug>(far-include-all)", opts)
          vim.keymap.set("n", "A", "<Plug>(far-exclude-all)", opts)
          
          -- Actions
          vim.keymap.set("n", "s", "<Plug>(far-do-replace)", opts)
          vim.keymap.set("n", "u", "<Plug>(far-undo)", opts)
          vim.keymap.set("n", "U", "<Plug>(far-undo-all)", opts)
          vim.keymap.set("n", "r", "<Plug>(far-do-replace-confirm)", opts)
          
          -- Folding
          vim.keymap.set("n", "zo", "<Plug>(far-expand-item)", opts)
          vim.keymap.set("n", "zc", "<Plug>(far-collapse-item)", opts)
          vim.keymap.set("n", "zM", "<Plug>(far-collapse-all)", opts)
          vim.keymap.set("n", "zR", "<Plug>(far-expand-all)", opts)
          
          -- Preview
          vim.keymap.set("n", "p", "<Plug>(far-preview)", opts)
          vim.keymap.set("n", "P", "<Plug>(far-preview-scroll-up)", opts)
          vim.keymap.set("n", "<C-d>", "<Plug>(far-preview-scroll-down)", opts)
          vim.keymap.set("n", "<C-u>", "<Plug>(far-preview-scroll-up)", opts)
          
          -- Quit
          vim.keymap.set("n", "q", "<cmd>q<cr>", opts)
          vim.keymap.set("n", "<Esc>", "<cmd>q<cr>", opts)
        end,
      })
      
      -- Custom commands for common workflows
      vim.api.nvim_create_user_command("SearchFiles", function(opts)
        vim.cmd("Far " .. opts.args)
      end, { nargs = 1, desc = "Search for pattern in files" })
      
      vim.api.nvim_create_user_command("SearchReplace", function(opts)
        local args = vim.split(opts.args, " ", { plain = true })
        if #args >= 2 then
          vim.cmd("Farr " .. args[1] .. " " .. args[2] .. " " .. (args[3] or "**/*"))
        else
          vim.notify("Usage: SearchReplace <pattern> <replacement> [file_mask]", vim.log.levels.ERROR)
        end
      end, { nargs = "+", desc = "Search and replace pattern in files" })
      
      -- Auto-commands for better UX
      vim.api.nvim_create_autocmd("User", {
        pattern = "FarStartSearch",
        callback = function()
          vim.notify("Starting search...", vim.log.levels.INFO)
        end,
      })
      
      vim.api.nvim_create_autocmd("User", {
        pattern = "FarStopSearch",
        callback = function()
          vim.notify("Search completed", vim.log.levels.INFO)
        end,
      })
    end,
  },
  
  -- Enhanced ripgrep integration
  {
    "jremmen/vim-ripgrep",
    cmd = { "Rg", "RgRoot" },
    keys = {
      { "<leader>rg", "<cmd>Rg<cr>", desc = "Ripgrep search" },
      { "<leader>rw", "<cmd>Rg <C-r><C-w><cr>", desc = "Ripgrep word under cursor" },
    },
    config = function()
      -- Configure ripgrep command
      vim.g.rg_command = "rg --vimgrep --no-heading --smart-case --hidden"
      
      -- Use quickfix window
      vim.g.rg_format = "%f:%l:%c:%m"
      
      -- Highlight search results
      vim.g.rg_highlight = 1
      
      -- Root directory detection
      vim.g.rg_root_types = { ".git", ".hg", ".svn", "package.json", "Cargo.toml", "go.mod" }
    end,
  },
}