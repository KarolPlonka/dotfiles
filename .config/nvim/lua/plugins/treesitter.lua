return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      require("nvim-treesitter").install({
        "python", "lua", "vim", "vimdoc", "query",
        "typescript", "javascript", "json", "html", "css", "scss", "php",
        "markdown", "markdown_inline", "yaml",
        "terraform", "hcl",
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "python", "lua", "javascript", "typescript",
          "html", "css", "scss", "php", "json", "yaml",
          "terraform", "hcl",
        },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
