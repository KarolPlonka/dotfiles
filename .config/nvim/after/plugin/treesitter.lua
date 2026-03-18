-- Setup nvim-treesitter (optional, works with defaults)
require'nvim-treesitter'.setup {
  install_dir = vim.fn.stdpath('data') .. '/site'
}

-- Install parsers
require'nvim-treesitter'.install {
  'python', 'lua', 'vim', 'vimdoc', 'query',
  'typescript', 'javascript', 'json', 'html', 'css', 'scss', 'php',
  'markdown', 'markdown_inline'
}

-- Enable highlighting for Python (and other languages)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'lua', 'javascript', 'typescript', 'html', 'css', 'scss', 'php', 'json' },
  callback = function() 
    vim.treesitter.start() 
  end,
})
