return {
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        opleader = { line = "<C-_>" },
        toggler = { line = "<C-_>" },
      })
      vim.keymap.set("n", "<leader>cc", function()
        require("Comment.api").toggle.linewise.current()
      end, { desc = "Toggle comment" })
      vim.keymap.set("v", "<leader>cc", function()
        local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        vim.api.nvim_feedkeys(esc, "nx", false)
        require("Comment.api").toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment (visual)" })
    end,
  },
}
