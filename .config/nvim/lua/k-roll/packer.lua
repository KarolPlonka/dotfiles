-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  
  -- Telescope for fuzzy finding
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-live-grep-args.nvim'},
    },
  }
  
  -- THEMES
  use "rebelot/kanagawa.nvim"
  use 'rose-pine/neovim'
  use 'shaunsingh/nord.nvim'
  use 'AlexvZyl/nordic.nvim'
  use "EdenEast/nightfox.nvim"
  use {'ojroques/nvim-hardline'}
  
  -- Treesitter for better syntax highlighting
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  
  -- UndoTree
  use('mbbill/undotree')
  
  -- Mason for LSP server management
  use 'williamboman/mason.nvim'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason-lspconfig.nvim'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  
  -- Comments
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }
  
  -- Plenary (dependency for several plugins)
  use "nvim-lua/plenary.nvim"
  
  -- Harpoon for quick file navigation
  use {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { {"nvim-lua/plenary.nvim"} }
  }
end)
