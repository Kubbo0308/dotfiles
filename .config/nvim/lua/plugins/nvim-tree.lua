-- open File Tree when open
local function open_nvim_tree()
    require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {mode = "n", "<C-b>", "<cmd>NvimTreeToggle<CR>", desc = "NvimTreeをトグルする"},
    {mode = "n", "<C-m>", "<cmd>NvimTreeFocus<CR>", desc = "NvimTreeにフォーカス"},
  },
  config = function()
    -- Image preview function for nvim-tree
    local function preview_image()
      local api = require('nvim-tree.api')
      local node = api.tree.get_node_under_cursor()
      
      if node and node.type == "file" then
        local filename = node.name
        local ext = vim.fn.fnamemodify(filename, ":e"):lower()
        local image_extensions = { "png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "svg", "ico" }
        
        local is_image = false
        for _, image_ext in ipairs(image_extensions) do
          if ext == image_ext then
            is_image = true
            break
          end
        end
        
        if is_image then
          if vim.fn.executable("wezterm") == 1 then
            local cmd = string.format("wezterm imgcat --width 50%% %s", vim.fn.shellescape(node.absolute_path))
            vim.fn.system(cmd)
          else
            vim.notify("WezTerm is not available for image preview", vim.log.levels.WARN)
          end
        else
          vim.notify("Not an image file", vim.log.levels.INFO)
        end
      end
    end
    
    -- Define custom mappings
    local function on_attach(bufnr)
      local api = require('nvim-tree.api')
      
      -- default mappings
      api.config.mappings.default_on_attach(bufnr)
      
      -- custom mappings
      vim.keymap.set('n', '<leader>p', preview_image, { desc = 'Preview image', buffer = bufnr, noremap = true, silent = true, nowait = true })
    end
    
    require("nvim-tree").setup {
      on_attach = on_attach,
      git = {
        enable = true,
        ignore = true,
      },
      renderer = {
        highlight_git = true,
        highlight_opened_files = "none",
        root_folder_modifier = ":~",
        indent_markers = {
          enable = false,
          icons = {
            corner = "└ ",
            edge = "│ ",
            none = "  ",
          },
        },
        icons = {
          webdev_colors = true,
          git_placement = "before",
          padding = " ",
          symlink_arrow = " ➛ ",
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
    }
  end,
}
