return {
  -- LSP Configuration - Minimal working version without mason-lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Mason for LSP management (without mason-lspconfig)
      "williamboman/mason.nvim",
      
      -- Additional lua configuration
      "folke/neodev.nvim",
    },
    config = function()
      -- Set up neodev first
      require("neodev").setup()
      
      -- Set up Mason
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
      
      -- LSP settings
      local lspconfig = require("lspconfig")
      
      -- Enhanced capabilities with cmp support
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- Function to organize Go imports
      local function go_org_imports(wait_ms)
        wait_ms = wait_ms or 1000
        local params = vim.lsp.util.make_range_params()
        params.context = {only = {"source.organizeImports"}}
        
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
        if not result then return end
        
        for cid, res in pairs(result) do
          if res.result then
            for _, r in pairs(res.result) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
        end
      end

      -- LSP attach function
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        
        -- LSP keybindings
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        
        -- Go-specific keybindings (only for Go files)
        if vim.bo[bufnr].filetype == "go" then
          vim.keymap.set("n", "<leader>go", function() go_org_imports() end, 
            vim.tbl_extend("force", opts, { desc = "Organize Go imports" }))
          vim.keymap.set("n", "<leader>gf", function() vim.lsp.buf.format({ timeout_ms = 2000 }) end,
            vim.tbl_extend("force", opts, { desc = "Format Go file" }))
        end
      end

      -- TypeScript/JavaScript LSP (using ts_ls - new name after tsserver deprecation)
      -- This assumes you have typescript-language-server installed globally
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          typescript = {
            preferences = {
              disableSuggestions = false,
            }
          }
        }
      })

      -- Go LSP (using gopls) with enhanced auto-import functionality
      lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          gopls = {
            -- Auto-import settings
            completeUnimported = true,        -- Enable completion for unimported packages
            usePlaceholders = true,           -- Enable placeholders in completions
            
            -- Analysis settings
            analyses = {
              unusedparams = true,            -- Find unused parameters
              shadow = true,                  -- Find variable shadowing
              unusedwrite = true,             -- Find unused writes
              useany = true,                  -- Find use of interface{} instead of any
            },
            
            -- Formatting and static analysis
            staticcheck = true,               -- Enable staticcheck integration
            gofumpt = true,                   -- Use gofumpt for formatting
            
            -- Hint settings
            hints = {
              compositeLiteralFields = true,  -- Show field names in composite literals
              constantValues = true,          -- Show constant values
              parameterNames = true,          -- Show parameter names in function calls
            },
            
            -- Code lens settings
            codelenses = {
              gc_details = false,             -- Don't show GC details
              generate = true,                -- Show generate commands
              regenerate_cgo = true,          -- Show regenerate cgo commands
              test = true,                    -- Show test commands
              tidy = true,                    -- Show tidy commands
              upgrade_dependency = true,      -- Show upgrade dependency commands
              vendor = true,                  -- Show vendor commands
            },
          },
        },
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = false,
      })
      
      -- Auto-format and organize imports on save for Go files
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          -- Organize imports first
          go_org_imports(1000)
          -- Then format the file
          vim.lsp.buf.format({ timeout_ms = 2000 })
        end,
        desc = "Auto-format and organize imports for Go files on save"
      })

      -- Sign column icons
      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        version = "v2.*",
      },
      "saadparwaiz1/cmp_luasnip",

      -- Adds LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",

      -- Adds a number of user-friendly snippets
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = "menu,menuone,noinsert"
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },
}