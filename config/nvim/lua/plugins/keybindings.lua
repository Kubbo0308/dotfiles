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
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
          presets = {
            operators = false,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        key_labels = {
          ["<space>"] = "SPC",
          ["<cr>"] = "RET",
          ["<tab>"] = "TAB",
        },
        icons = {
          breadcrumb = "»",
          separator = "➜",
          group = "+",
        },
        popup_mappings = {
          scroll_down = "<c-d>",
          scroll_up = "<c-u>",
        },
        window = {
          border = "rounded",
          position = "bottom",
          margin = { 1, 0, 1, 0 },
          padding = { 2, 2, 2, 2 },
          winblend = 0,
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          align = "left",
        },
        ignore_missing = true,
        hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
        show_help = true,
        triggers = "auto",
        triggers_blacklist = {
          i = { "j", "k" },
          v = { "j", "k" },
        },
      })

      -- Register key groups
      wk.register({
        ["<leader>f"] = { name = "+File" },
        ["<leader>g"] = { name = "+Git" },
        ["<leader>h"] = { name = "+Git Hunks" },
        ["<leader>l"] = { name = "+LSP" },
        ["<leader>t"] = { name = "+Test/Terminal" },
        ["<leader>w"] = { name = "+Window" },
        ["<leader>b"] = { name = "+Buffer" },
        ["<leader>s"] = { name = "+Search" },
        ["<leader>d"] = { name = "+Debug" },
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