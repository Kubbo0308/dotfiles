return {
  -- Go development tools
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        goimport = "gopls", -- goimport command, can be gopls[default] or goimport or gofumports
        gofmt = "gofumports", -- gofmt cmd,
        max_line_len = 120, -- max line length in golines format, Target maximum line length for golines
        tag_transform = false, -- can be transform option("snakecase", "camelcase", etc) check gomodifytags for details and more options
        tag_options = "json=omitempty", -- sets options sent to gomodifytags, i.e gomodifytags -add-options json=omitempty
        gotests_template = "", -- sets gotests -template parameter (check gotests for details)
        gotests_template_dir = "", -- sets gotests -template_dir parameter (check gotests for details)
        comment_placeholder = "   ", -- comment_placeholder your cool placeholder e.g. ﳑ       
        icons = { breakpoint = "🧘", currentpos = "🏃" }, -- setup to `false` to disable icons setup
        verbose = false, -- output loginf in messages
        lsp_cfg = false, -- true: use non-default gopls setup specified in go/lsp.lua
        lsp_gofumpt = true, -- true: set default gofmt in gopls format to gofumpt
        lsp_on_attach = nil, -- nil: use on_attach function defined in go/lsp.lua,
        dap_debug = true, -- set to false to disable dap
        dap_debug_keymap = true, -- true: use keymap for debugger defined in go/dap.lua
        dap_debug_gui = {}, -- bool|table put your dap-ui setup here set to false to disable
        dap_debug_vt = { enabled_commands = true, all_frames = true }, -- bool|table put your dap-virtual-text setup here set to false to disable

        dap_port = 38697, -- can be set to a number, if set to -1 go.nvim will pickup a random port
        dap_timeout = 15, --  see dap option initialize_timeout_sec = 15,
        dap_retries = 20, -- see dap option max_retries
        build_tags = "tag1,tag2", -- set default build tags
        textobjects = true, -- enable default text objects through treesittter-text-objects
        test_runner = "go", -- one of {`go`, `richgo`, `dlv`, `ginkgo`, `gotestsum`}
        verbose_tests = true, -- set to add verbose flag to tests
        run_in_floaterm = false, -- set to true to run in a float window. :GoTermClose closes the floatterm
        floaterm = { -- position
          posititon = "auto", -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
          width = 0.45, -- width of float window if not auto
          height = 0.98, -- height of float window if not auto
        },
        trouble = false, -- true: use trouble to open quickfix
        test_efm = false, -- errorfomat for quickfix, default mix mode, set to true will be efm only
        luasnip = true, -- enable included luasnip snippets. B
        on_jobstart = function(cmd) _=cmd end, -- callback for stdout
        on_stdout = function(err, data) _, _ = err, data end, -- callback when job started
        on_stderr = function(err, data)  _, _ = err, data end, -- callback for stderr
        on_exit = function(code, signal, output)  _, _, _ = code, signal, output end, -- callback for jobexit, output : string
      })

      -- Run gofmt + goimport on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
         require('go.format').goimport()
        end,
        group = format_sync_grp,
      })

      -- Key mappings for Go
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          local opts = { buffer = true, silent = true }
          
          -- Test commands
          vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<cr>", vim.tbl_extend("force", opts, { desc = "Go test" }))
          vim.keymap.set("n", "<leader>gT", "<cmd>GoTestFile<cr>", vim.tbl_extend("force", opts, { desc = "Go test file" }))
          vim.keymap.set("n", "<leader>gf", "<cmd>GoTestFunc<cr>", vim.tbl_extend("force", opts, { desc = "Go test function" }))
          vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<cr>", vim.tbl_extend("force", opts, { desc = "Go coverage" }))
          
          -- Build and run
          vim.keymap.set("n", "<leader>gb", "<cmd>GoBuild<cr>", vim.tbl_extend("force", opts, { desc = "Go build" }))
          vim.keymap.set("n", "<leader>gr", "<cmd>GoRun<cr>", vim.tbl_extend("force", opts, { desc = "Go run" }))
          
          -- Debug
          vim.keymap.set("n", "<leader>gd", "<cmd>GoDebug<cr>", vim.tbl_extend("force", opts, { desc = "Go debug" }))
          vim.keymap.set("n", "<leader>gD", "<cmd>GoDebug -t<cr>", vim.tbl_extend("force", opts, { desc = "Go debug test" }))
          
          -- Tools
          vim.keymap.set("n", "<leader>gi", "<cmd>GoImport<cr>", vim.tbl_extend("force", opts, { desc = "Go import" }))
          vim.keymap.set("n", "<leader>gI", "<cmd>GoImportAdd<cr>", vim.tbl_extend("force", opts, { desc = "Go import add" }))
          vim.keymap.set("n", "<leader>ge", "<cmd>GoIfErr<cr>", vim.tbl_extend("force", opts, { desc = "Go if err" }))
          vim.keymap.set("n", "<leader>gF", "<cmd>GoFillStruct<cr>", vim.tbl_extend("force", opts, { desc = "Go fill struct" }))
          vim.keymap.set("n", "<leader>gS", "<cmd>GoFillSwitch<cr>", vim.tbl_extend("force", opts, { desc = "Go fill switch" }))
          
          -- Tags
          vim.keymap.set("n", "<leader>gta", "<cmd>GoAddTag<cr>", vim.tbl_extend("force", opts, { desc = "Go add tag" }))
          vim.keymap.set("n", "<leader>gtr", "<cmd>GoRmTag<cr>", vim.tbl_extend("force", opts, { desc = "Go remove tag" }))
          
          -- Alternate file
          vim.keymap.set("n", "<leader>gA", "<cmd>GoAlt<cr>", vim.tbl_extend("force", opts, { desc = "Go alternate file" }))
          vim.keymap.set("n", "<leader>gV", "<cmd>GoAltV<cr>", vim.tbl_extend("force", opts, { desc = "Go alternate file (vertical)" }))
          vim.keymap.set("n", "<leader>gH", "<cmd>GoAltS<cr>", vim.tbl_extend("force", opts, { desc = "Go alternate file (horizontal)" }))
        end,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },

  -- Enhanced Go syntax highlighting
  {
    "fatih/vim-go",
    build = ":GoUpdateBinaries",
    ft = "go",
    config = function()
      -- Disable vim-go LSP features (we use nvim-lspconfig)
      vim.g.go_def_mode = "gopls"
      vim.g.go_info_mode = "gopls"
      vim.g.go_rename_command = "gopls"
      
      -- Enable syntax highlighting
      vim.g.go_highlight_types = 1
      vim.g.go_highlight_fields = 1
      vim.g.go_highlight_functions = 1
      vim.g.go_highlight_function_calls = 1
      vim.g.go_highlight_extra_types = 1
      vim.g.go_highlight_operators = 1
      vim.g.go_highlight_format_strings = 1
      vim.g.go_highlight_variable_declarations = 1
      vim.g.go_highlight_variable_assignments = 1
      
      -- Disable features we handle elsewhere
      vim.g.go_code_completion_enabled = 0
      vim.g.go_fmt_autosave = 0
      vim.g.go_imports_autosave = 0
      vim.g.go_mod_fmt_autosave = 0
    end,
  },
}