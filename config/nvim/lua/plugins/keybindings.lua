return {
  -- Which-key for showing keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      local wk = require("which-key")
      
      wk.setup({
        preset = "modern",
        delay = 300,
        expand = 1,
        notify = true,
        triggers = {
          { "<auto>", mode = "nxsot" },
        },
        spec = {
          { "<leader>f", group = "File" },
          { "<leader>g", group = "Git" },
          { "<leader>gh", group = "Git Hunks" },
          { "<leader>l", group = "LSP" },
          { "<leader>t", group = "Test/Terminal" },
          { "<leader>w", group = "Window" },
          { "<leader>b", group = "Buffer" },
          { "<leader>s", group = "Search" },
          { "<leader>d", group = "Debug" },
          { "<leader>o", group = "Oil File Manager" },
          { "<leader>p", desc = "Preview image (nvim-tree/oil)" },
          { "<leader>P", desc = "Clear preview (oil only)" },
        },
        icons = {
          breadcrumb = "»",
          separator = "➜",
          group = "+",
          ellipsis = "…",
          mappings = true,
          rules = {},
          colors = true,
          keys = {
            Up = " ",
            Down = " ",
            Left = " ",
            Right = " ",
            C = "󰘴 ",
            M = "󰘵 ",
            D = "󰘳 ",
            S = "󰘶 ",
            CR = "󰌑 ",
            Esc = "󱊷 ",
            ScrollWheelDown = "󱕐 ",
            ScrollWheelUp = "󱕑 ",
            NL = "󰌑 ",
            BS = "󰁮",
            Space = "󱁐 ",
            Tab = "󰌒 ",
            F1 = "󱊫",
            F2 = "󱊬",
            F3 = "󱊭",
            F4 = "󱊮",
            F5 = "󱊯",
            F6 = "󱊰",
            F7 = "󱊱",
            F8 = "󱊲",
            F9 = "󱊳",
            F10 = "󱊴",
            F11 = "󱊵",
            F12 = "󱊶",
          },
        },
        show_help = true,
        show_keys = true,
        disable = {
          buftypes = {},
          filetypes = {},
        },
        debug = false,
      })

      -- Additional general keybindings
      local opts = { noremap = true, silent = true }
      
      -- Better window navigation
      vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
      vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
      vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
      vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

      -- Resize windows with arrows
      vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
      vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
      vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
      vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

      -- Navigate buffers
      vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts)
      vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts)

      -- Move text up and down
      vim.keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
      vim.keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)
      vim.keymap.set("v", "p", '"_dP', opts)

      -- Visual Block --
      vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
      vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)
      vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
      vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

      -- Better paste
      vim.keymap.set("v", "p", '"_dP', opts)

      -- Clear highlights
      vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

      -- Close buffer
      vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close buffer" })

      -- Save and quit
      vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
      vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
      vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })

      -- Open nvim config quickly
      vim.keymap.set("n", "<leader>fc", "<cmd>e ~/.config/nvim/init.lua<CR>", { desc = "Open nvim config" })
    end,
  },
}