return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "lewis6991/async.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
      vim.keymap.set({ "n", "x" }, "<leader>rv", function() return require("refactoring").extract_var() end, { expr = true, desc = "Extract variable" })
      vim.keymap.set({ "n", "x" }, "<leader>rf", function() return require("refactoring").extract_func() end, { expr = true, desc = "Extract function" })
      vim.keymap.set({ "n", "x" }, "<leader>ri", function() return require("refactoring").inline_var() end, { expr = true, desc = "Inline variable" })
    end,
  },
}
