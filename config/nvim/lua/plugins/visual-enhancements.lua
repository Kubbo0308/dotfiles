return {
  -- Rainbow parentheses for better bracket visibility
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')
      
      require('rainbow-delimiters.setup').setup({
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
          javascript = 'rainbow-delimiters',
          typescript = 'rainbow-delimiters',
          tsx = 'rainbow-delimiters',
          go = 'rainbow-delimiters',
        },
        priority = {
          [''] = 110,
          lua = 210,
          javascript = 220,
          typescript = 220,
          tsx = 220,
          go = 220,
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      })
      
      -- Custom colors for VSCode theme
      vim.api.nvim_set_hl(0, 'RainbowDelimiterRed', { fg = '#FF6B6B' })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterYellow', { fg = '#FFD93D' })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterBlue', { fg = '#6BCF7F' })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterOrange', { fg = '#FF8E53' })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterGreen', { fg = '#4ECDC4' })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterViolet', { fg = '#C44569' })
      vim.api.nvim_set_hl(0, 'RainbowDelimiterCyan', { fg = '#0ABDE3' })
    end,
  },
  
  -- Indent guides for better code structure visibility
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
          smart_indent_cap = true,
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
          injected_languages = false,
          highlight = { "Function", "Label" },
          priority = 500,
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
            "NvimTree",
          },
          buftypes = {
            "terminal",
            "nofile",
          },
        },
      })
      
      -- Custom indent guide colors
      vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3B4048" })
      vim.api.nvim_set_hl(0, "IblScope", { fg = "#569CD6" })
    end,
  },
  
  -- Color previews for hex codes and color names
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPre",
    config = function()
      require('colorizer').setup({
        '*', -- Apply to all filetypes
        css = { rgb_fn = true, }, -- Enable parsing rgb(...) functions in css.
        html = { names = false, }, -- Disable parsing "names" like Blue or Gray
        javascript = { names = false, },
        typescript = { names = false, },
        go = { names = false, },
      }, {
        RGB      = true,         -- #RGB hex codes
        RRGGBB   = true,         -- #RRGGBB hex codes
        names    = false,        -- "Name" codes like Blue
        RRGGBBAA = false,        -- #RRGGBBAA hex codes
        rgb_fn   = false,        -- CSS rgb() and rgba() functions
        hsl_fn   = false,        -- CSS hsl() and hsla() functions
        css      = false,        -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn   = false,        -- Enable all CSS *functions*: rgb_fn, hsl_fn
        mode     = 'background', -- Set the display mode.
      })
    end,
  },
  
  -- Better statusline for visual feedback
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'vscode',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = false,
              path = 1, -- Show relative path
              symbols = {
                modified = '[+]',
                readonly = '[RO]',
                unnamed = '[No Name]',
                newfile = '[New]',
              }
            }
          },
          lualine_x = {
            {
              'encoding',
              fmt = string.upper,
            },
            'fileformat',
            {
              'filetype',
              colored = true,
              icon_only = false,
              icon = { align = 'right' },
            }
          },
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {
          'nvim-tree',
          'quickfix',
          'fugitive',
        }
      })
    end,
  },
  
  -- Enhanced cursor line and column highlighting
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require('illuminate').configure({
        -- providers: provider used to get references in the buffer, ordered by priority
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
        -- delay: delay in milliseconds
        delay = 100,
        -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
        filetypes_denylist = {
          'dirvish',
          'fugitive',
          'NvimTree',
          'lazy',
          'mason',
        },
        -- filetypes_allowlist: filetypes to illuminate, this is overridden by filetypes_denylist
        filetypes_allowlist = {},
        -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
        modes_denylist = {},
        -- modes_allowlist: modes to illuminate, this is overridden by modes_denylist
        modes_allowlist = {},
        -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
        providers_regex_syntax_denylist = {},
        -- providers_regex_syntax_allowlist: syntax to illuminate, this is overridden by providers_regex_syntax_denylist
        providers_regex_syntax_allowlist = {},
        -- under_cursor: whether or not to illuminate under the cursor
        under_cursor = true,
        -- large_file_cutoff: number of lines at which to use large_file_config
        large_file_cutoff = nil,
        -- large_file_config: config to use for large files (based on large_file_cutoff).
        large_file_config = nil,
        -- min_count_to_highlight: minimum number of matches required to perform highlighting
        min_count_to_highlight = 1,
      })
      
      -- Custom highlighting colors
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3E4451" })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3E4451" })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3E4451" })
    end,
  },
  
  -- Better match highlighting
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_timeout = 300
      vim.g.matchup_matchparen_insert_timeout = 60
      
      -- Treesitter integration
      require'nvim-treesitter.configs'.setup {
        matchup = {
          enable = true,
        },
      }
    end,
  },
}