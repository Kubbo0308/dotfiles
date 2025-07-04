return {
  -- Test runner for JavaScript/TypeScript
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    cmd = { "Neotest" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest")({
            jestCommand = "npm test --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
          require("neotest-vitest")({
            filter_dir = function(name, rel_path, root)
              return name ~= "node_modules"
            end,
          }),
        },
        discovery = {
          enabled = false,
        },
        running = {
          concurrent = true,
        },
        summary = {
          open = "botright vsplit | vertical resize 50"
        },
      })

      -- Set up keybindings after neotest is loaded
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<leader>tt", function() require("neotest").run.run() end, vim.tbl_extend("force", opts, { desc = "Run test" }))
      vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, vim.tbl_extend("force", opts, { desc = "Run test file" }))
      vim.keymap.set("n", "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, vim.tbl_extend("force", opts, { desc = "Debug test" }))
      vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, vim.tbl_extend("force", opts, { desc = "Toggle test summary" }))
      vim.keymap.set("n", "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, vim.tbl_extend("force", opts, { desc = "Show test output" }))
      vim.keymap.set("n", "<leader>tO", function() require("neotest").output_panel.toggle() end, vim.tbl_extend("force", opts, { desc = "Toggle test output panel" }))
      vim.keymap.set("n", "<leader>tS", function() require("neotest").run.stop() end, vim.tbl_extend("force", opts, { desc = "Stop test" }))
    end,
  },

  -- Package.json helper
  {
    "vuki656/package-info.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    ft = "json",
    config = function()
      require("package-info").setup({
        colors = {
          up_to_date = "#3C4048",
          outdated = "#d19a66",
        },
        icons = {
          enable = true,
          style = {
            up_to_date = "|  ",
            outdated = "|  ",
          },
        },
        autostart = true,
        hide_up_to_date = false,
        hide_unstable_versions = false,
        package_manager = "npm"
      })
    end,
  },

  -- TypeScript utilities (modern replacement for archived typescript.nvim)
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      require("typescript-tools").setup({
        on_attach = function(client, bufnr)
          -- Key mappings for TypeScript utilities
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "<leader>to", "<cmd>TSToolsOrganizeImports<cr>", vim.tbl_extend("force", opts, { desc = "Organize imports" }))
          vim.keymap.set("n", "<leader>tR", "<cmd>TSToolsRenameFile<cr>", vim.tbl_extend("force", opts, { desc = "Rename file" }))
          vim.keymap.set("n", "<leader>ti", "<cmd>TSToolsAddMissingImports<cr>", vim.tbl_extend("force", opts, { desc = "Add missing imports" }))
          vim.keymap.set("n", "<leader>tF", "<cmd>TSToolsFixAll<cr>", vim.tbl_extend("force", opts, { desc = "Fix all" }))
          vim.keymap.set("n", "<leader>tu", "<cmd>TSToolsRemoveUnused<cr>", vim.tbl_extend("force", opts, { desc = "Remove unused imports" }))
          vim.keymap.set("n", "<leader>td", "<cmd>TSToolsGoToSourceDefinition<cr>", vim.tbl_extend("force", opts, { desc = "Go to source definition" }))
          vim.keymap.set("n", "<leader>tr", "<cmd>TSToolsFileReferences<cr>", vim.tbl_extend("force", opts, { desc = "File references" }))
        end,
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          expose_as_code_action = {},
          tsserver_path = nil,
          tsserver_plugins = {},
          tsserver_max_memory = "auto",
          tsserver_format_options = {},
          tsserver_file_preferences = {},
          tsserver_locale = "en",
          complete_function_calls = false,
          include_completions_with_insert_text = true,
          code_lens = "off",
          disable_member_code_lens = true,
          jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
          }
        },
      })
    end,
  },

  -- Eslint integration
  {
    "MunifTanjim/eslint.nvim",
    dependencies = "neovim/nvim-lspconfig",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
    config = function()
      require("eslint").setup({
        bin = "eslint", -- or `eslint_d`
        code_actions = {
          enable = true,
          apply_on_save = {
            enable = true,
            types = { "directive", "problem", "suggestion", "layout" },
          },
          disable_rule_comment = {
            enable = true,
            location = "separate_line", -- or `same_line`
          },
        },
        diagnostics = {
          enable = true,
          report_unused_disable_directives = false,
          run_on = "type", -- or `save`
        },
      })
    end,
  },

  -- Enhanced JavaScript/TypeScript syntax and features
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "xml" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Tailwind CSS support
  {
    "luckasRanarison/tailwind-tools.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    config = function()
      require("tailwind-tools").setup({
        document_color = {
          enabled = true,
          kind = "inline",
          inline_symbol = "●",
          debounce = 200,
        },
        conceal = {
          enabled = false,
          symbol = "…",
        },
      })
    end,
  },

  -- REST client for API testing
  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "http",
    config = function()
      require("rest-nvim").setup({
        result_split_horizontal = false,
        result_split_in_place = false,
        skip_ssl_verification = false,
        encode_url = true,
        highlight = {
          enabled = true,
          timeout = 150,
        },
        result = {
          show_url = true,
          show_curl_command = false,
          show_http_info = true,
          show_headers = true,
          formatters = {
            json = "jq",
            html = function(body)
              return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
            end
          },
        },
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "http",
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "<leader>rr", "<Plug>RestNvim", vim.tbl_extend("force", opts, { desc = "Run request" }))
          vim.keymap.set("n", "<leader>rp", "<Plug>RestNvimPreview", vim.tbl_extend("force", opts, { desc = "Preview request" }))
          vim.keymap.set("n", "<leader>rl", "<Plug>RestNvimLast", vim.tbl_extend("force", opts, { desc = "Run last request" }))
        end,
      })
    end,
  },
}