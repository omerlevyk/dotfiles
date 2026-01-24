return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- make sure it loads first
    config = function()
      vim.o.background = "dark"
      vim.cmd("colorscheme gruvbox")
    end,
  },
}
