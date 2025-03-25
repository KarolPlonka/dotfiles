-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	'nvim-telescope/telescope.nvim', tag = '0.1.6',
	-- or                            , branch = '0.1.x',
	requires = {
        {'nvim-lua/plenary.nvim'},
        { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
  }

  -- THEMES
  use "rebelot/kanagawa.nvim"
  use 'rose-pine/neovim'
  use 'shaunsingh/nord.nvim'
  use 'AlexvZyl/nordic.nvim'
  use "EdenEast/nightfox.nvim"

  use {'ojroques/nvim-hardline'}

  -- rose-pine

  -- rose-pine

 --  use({
	-- 'rose-pine/neovim',
	-- as = 'rose-pine',
	-- config = function()
	-- 	vim.cmd('colorscheme rose-pine')
	-- end
 --  })

  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

  use('mbbill/undotree')

  use{
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v3.x',
	  requires = {
		  --- Uncomment the two plugins below if you want to manage the language servers from neovim
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},
		  
		  {'neovim/nvim-lspconfig'},
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'L3MON4D3/LuaSnip'},
  	}
  }
  use {
	  'numToStr/Comment.nvim',
	  config = function()
		  require('Comment').setup()
	  end
  }

  use "nvim-lua/plenary.nvim" -- don't forget to add this one if you don't have it yet!

  use {
	  "ThePrimeagen/harpoon",
	  branch = "harpoon2",
	  requires = { {"nvim-lua/plenary.nvim"} }
  }

end)
