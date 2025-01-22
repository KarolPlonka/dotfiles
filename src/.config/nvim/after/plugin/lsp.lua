local lsp_zero = require('lsp-zero')
local lsp_config = require('lspconfig')
-- lsp_config.intelephense.setup({})

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})

lsp_config.phpactor.setup({
  root_dir = function()
    -- return vim.fn.expand('%:p:h')
    return '.'
  end,
  single_file_support = true,
})


local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()
cmp.setup({
  mapping = {
    -- Navigate between completion item
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
--    ['<Enter>'] = cmp_action.toggle_completion(),
    -- Confirm item
    ['<Enter>'] = cmp.mapping.confirm({select = true}),
    -- Show function signature
  }
})

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    preserve_mappings = false
  })
end)
