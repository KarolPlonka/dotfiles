return {
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = {
        preset = "none",
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<Enter>"] = { "accept", "fallback" },
        ["<C-d>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "fallback" },
        ["<C-e>"] = { "cancel", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
      completion = { documentation = { auto_show = true } },
    },
  },
}
