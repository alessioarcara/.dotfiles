-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    -- fuzzy finder
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    -- theme 
    use 'folke/tokyonight.nvim'
    -- efficient parser for syntax tree
    use("nvim-treesitter/nvim-treesitter", {run = ":TSUpdate"})
    -- lsp
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {'williamboman/mason.nvim'},           -- Optional
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},         -- Required
            {'hrsh7th/cmp-nvim-lsp'},     -- Required
            {'hrsh7th/cmp-buffer'},       -- Optional
            {'hrsh7th/cmp-path'},         -- Optional
            {'saadparwaiz1/cmp_luasnip'}, -- Optional
            {'hrsh7th/cmp-nvim-lua'},     -- Optional

            -- Snippets
            {'L3MON4D3/LuaSnip'},             -- Required
            {'rafamadriz/friendly-snippets'}, -- Optional
        }
    }
    use 'simrat39/rust-tools.nvim'
    use {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    }
    use("christoomey/vim-tmux-navigator") -- tmux & split window navigation
    use("tpope/vim-fugitive")
    use("ThePrimeagen/vim-be-good")
    -- tabs
    use('nvim-tree/nvim-web-devicons')
    use {'romgrk/barbar.nvim', requires = 'nvim-web-devicons'}
    -- latex
    use 'lervag/vimtex'
    -- quarto
    use 'quarto-dev/quarto-nvim'
    use 'jmbuhr/otter.nvim'
end)
