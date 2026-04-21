return {
  {
    "ojroques/nvim-hardline",
    config = function()
      require("hardline").setup({ theme = "oxocarbon" })
    end,
  },
  {
    "mbbill/undotree",
    keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle UndoTree" } },
  },
}
