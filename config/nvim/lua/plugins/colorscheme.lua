return {
  -- VSCode Dark+ theme for NeoVim
  {
    "Mofiqul/vscode.nvim",
    priority = 1000, -- Load colorscheme first
    config = function()
      local vscode = require('vscode')
      
      -- Configure VSCode theme
      vscode.setup({
        -- Theme style (dark, light, or auto)
        style = 'dark',
        
        -- Enable transparent background
        transparent = false,
        
        -- Enable italic keywords
        italic_comments = true,
        
        -- Disable nvim-tree background color
        disable_nvimtree_bg = true,
        
        -- Override colors
        color_overrides = {
          -- You can override specific colors here if needed
        },
        
        -- Override highlight groups
        group_overrides = {
          -- Enhanced Go syntax highlighting
          ['@function.go'] = { fg = '#DCDCAA' },                    -- Function names
          ['@function.method.go'] = { fg = '#DCDCAA' },             -- Method names
          ['@type.go'] = { fg = '#4EC9B0' },                        -- Types
          ['@type.builtin.go'] = { fg = '#569CD6' },                -- Built-in types
          ['@variable.go'] = { fg = '#9CDCFE' },                    -- Variables
          ['@constant.go'] = { fg = '#4FC1FF' },                    -- Constants
          ['@string.go'] = { fg = '#CE9178' },                      -- Strings
          ['@comment.go'] = { fg = '#6A9955', italic = true },      -- Comments
          ['@keyword.go'] = { fg = '#569CD6' },                     -- Keywords
          ['@keyword.function.go'] = { fg = '#569CD6' },            -- func keyword
          ['@keyword.return.go'] = { fg = '#569CD6' },              -- return keyword
          
          -- Enhanced TypeScript syntax highlighting
          ['@function.typescript'] = { fg = '#DCDCAA' },            -- Function names
          ['@function.method.typescript'] = { fg = '#DCDCAA' },     -- Method names
          ['@type.typescript'] = { fg = '#4EC9B0' },                -- Types
          ['@type.builtin.typescript'] = { fg = '#569CD6' },        -- Built-in types
          ['@variable.typescript'] = { fg = '#9CDCFE' },            -- Variables
          ['@constant.typescript'] = { fg = '#4FC1FF' },            -- Constants
          ['@string.typescript'] = { fg = '#CE9178' },              -- Strings
          ['@comment.typescript'] = { fg = '#6A9955', italic = true }, -- Comments
          ['@keyword.typescript'] = { fg = '#569CD6' },             -- Keywords
          ['@keyword.function.typescript'] = { fg = '#569CD6' },    -- function keyword
          ['@keyword.return.typescript'] = { fg = '#569CD6' },      -- return keyword
          ['@constructor.typescript'] = { fg = '#4EC9B0' },         -- Constructors
          
          -- TSX specific
          ['@tag.tsx'] = { fg = '#569CD6' },                        -- JSX tags
          ['@tag.attribute.tsx'] = { fg = '#9CDCFE' },              -- JSX attributes
          ['@tag.delimiter.tsx'] = { fg = '#808080' },              -- JSX delimiters
          
          -- General syntax improvements
          ['@operator'] = { fg = '#D4D4D4' },                       -- Operators
          ['@punctuation.bracket'] = { fg = '#FFD700' },            -- Brackets (gold)
          ['@punctuation.delimiter'] = { fg = '#D4D4D4' },          -- Delimiters
          ['@number'] = { fg = '#B5CEA8' },                         -- Numbers
          ['@boolean'] = { fg = '#569CD6' },                        -- Booleans
          ['@property'] = { fg = '#9CDCFE' },                       -- Object properties
          ['@field'] = { fg = '#9CDCFE' },                          -- Struct fields
          
          -- LSP semantic token highlighting
          ['@lsp.type.function'] = { fg = '#DCDCAA' },              -- LSP functions
          ['@lsp.type.method'] = { fg = '#DCDCAA' },                -- LSP methods
          ['@lsp.type.variable'] = { fg = '#9CDCFE' },              -- LSP variables
          ['@lsp.type.parameter'] = { fg = '#9CDCFE' },             -- LSP parameters
          ['@lsp.type.property'] = { fg = '#9CDCFE' },              -- LSP properties
          ['@lsp.type.type'] = { fg = '#4EC9B0' },                  -- LSP types
          ['@lsp.type.class'] = { fg = '#4EC9B0' },                 -- LSP classes
          ['@lsp.type.interface'] = { fg = '#B8D7A3' },             -- LSP interfaces
          ['@lsp.type.enum'] = { fg = '#4EC9B0' },                  -- LSP enums
          ['@lsp.type.keyword'] = { fg = '#569CD6' },               -- LSP keywords
          ['@lsp.type.namespace'] = { fg = '#4EC9B0' },             -- LSP namespaces
          ['@lsp.mod.deprecated'] = { strikethrough = true },       -- Deprecated items
          ['@lsp.mod.readonly'] = { italic = true },                -- Readonly items
        }
      })
      
      -- Apply the colorscheme
      vim.cmd('colorscheme vscode')
      
      -- Additional terminal color configuration
      if vim.fn.has('termguicolors') == 1 then
        vim.opt.termguicolors = true
      end
      
      -- Set cursor line highlighting
      vim.opt.cursorline = true
      
      -- Enhanced search highlighting
      vim.api.nvim_set_hl(0, 'Search', { bg = '#613315', fg = '#FFFFFF' })
      vim.api.nvim_set_hl(0, 'IncSearch', { bg = '#FF8C00', fg = '#000000' })
      
      -- Enhanced visual selection
      vim.api.nvim_set_hl(0, 'Visual', { bg = '#264F78' })
      
      -- Line numbers
      vim.api.nvim_set_hl(0, 'LineNr', { fg = '#858585' })
      vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#FFFFFF', bold = true })
    end,
  },
  
  -- Alternative modern colorschemes (commented out, uncomment to try)
  -- {
  --   "folke/tokyonight.nvim",
  --   priority = 1000,
  --   config = function()
  --     require("tokyonight").setup({
  --       style = "night",
  --       transparent = false,
  --       terminal_colors = true,
  --       styles = {
  --         comments = { italic = true },
  --         keywords = { italic = true },
  --         functions = {},
  --         variables = {},
  --       },
  --     })
  --     vim.cmd("colorscheme tokyonight")
  --   end,
  -- },
  
  -- {
  --   "EdenEast/nightfox.nvim",
  --   priority = 1000,
  --   config = function()
  --     require('nightfox').setup({
  --       options = {
  --         compile_path = vim.fn.stdpath("cache") .. "/nightfox",
  --         compile_file_suffix = "_compiled",
  --         transparent = false,
  --         terminal_colors = true,
  --         dim_inactive = false,
  --         module_default = true,
  --         styles = {
  --           comments = "italic",
  --           conditionals = "NONE",
  --           constants = "NONE",
  --           functions = "NONE",
  --           keywords = "NONE",
  --           numbers = "NONE",
  --           operators = "NONE",
  --           strings = "NONE",
  --           types = "NONE",
  --           variables = "NONE",
  --         },
  --       }
  --     })
  --     vim.cmd("colorscheme carbonfox")
  --   end,
  -- },
}