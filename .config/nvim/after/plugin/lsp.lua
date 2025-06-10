-- LSP Setup without lsp-zero

-- Setup Mason for LSP server management
require('mason').setup({})
-- require('mason-lspconfig').setup({ ensure_installed = {}, })

-- Setup nvim-cmp for autocompletion
local cmp = require('cmp')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- Navigate between completion items
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    
    -- Confirm item
    ['<Enter>'] = cmp.mapping.confirm({ select = true }),
    
    -- Scroll documentation
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    
    -- Complete
    ['<C-space>'] = cmp.mapping.complete(),
    
    -- Abort
    ['<C-e>'] = cmp.mapping.abort(),
  }),
  
  -- Configure sources for autocompletion
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }),
  
  -- You can add formatting here if needed
  -- formatting = {...}
})

vim.diagnostic.config({
  virtual_text = {
    prefix = '●',  -- Customize this symbol as you like (●, ■, ✗, etc.)
    spacing = 2,   -- Space between the diagnostic and the code
  },
  signs = true,         -- Show signs in the gutter
  underline = true,     -- Underline problematic code
  update_in_insert = false, -- Don't show diagnostics while typing (optional)
  severity_sort = true, -- Sort diagnostics by severity
})

vim.o.winborder = "rounded"

vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, bufopts)


local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  -- You can add more keybindings here, for example:
  -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
end

vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
--
lspconfig = require("lspconfig")
local python_root_files = {
  '.venv', -- virtual environment directory
  'WORKSPACE', -- added for Bazel; items below are from default config
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
}
lspconfig["pyright"].setup {
    on_attach = on_attach,
    root_dir = lspconfig.util.root_pattern(unpack(python_root_files))
}
