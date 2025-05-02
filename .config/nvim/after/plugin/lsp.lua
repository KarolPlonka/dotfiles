-- LSP Setup without lsp-zero

-- Setup Mason for LSP server management
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({
        on_attach = function(client, bufnr)
          -- Define keybindings for LSP functions
          local opts = { noremap=true, silent=true, buffer=bufnr }
          
          -- Go to definition
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          -- Go to declaration
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          -- Show implementation
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          -- Show type definition
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
          -- Show references
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          -- Rename symbol
          vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
          -- Code actions
          vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
          vim.keymap.set('x', '<F4>', vim.lsp.buf.code_action, opts)
          -- Show hover information
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          -- Show signature help
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          -- Format code
          vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
          -- Diagnostics navigation
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
          -- Show diagnostics in hover window
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
          -- Show diagnostics in location list
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
          -- Show workspace symbols
          vim.keymap.set('n', '<space>ws', vim.lsp.buf.workspace_symbol, opts)
        end,
        -- You can add additional capabilities here if needed
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })
    end,
  }
})

-- Configure phpactor specifically

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
