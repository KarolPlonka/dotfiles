return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      require("mason").setup()

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
      vim.lsp.enable("pyright")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufopts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
          vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references() end, bufopts)
          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
        end,
      })

      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 2 },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}
