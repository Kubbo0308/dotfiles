return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function ()
    vim.opt.termguicolors = true
    require("bufferline").setup{
      options = {
        pick = {
          alphabet = "1234567890"
        }
      }
    }
  end
}
