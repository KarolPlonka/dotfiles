return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa")
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },
  { "rose-pine/neovim", name = "rose-pine" },
  { "shaunsingh/nord.nvim" },
  { "AlexvZyl/nordic.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "scottmckendry/cyberdream.nvim" },
}
