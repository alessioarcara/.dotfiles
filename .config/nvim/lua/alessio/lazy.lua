local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    -- fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        dependencies = { {'nvim-lua/plenary.nvim'} }
    },
    -- theme 
    'folke/tokyonight.nvim',
    -- efficient parser for syntax tree
    "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    -- lsp
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
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
    },
    'simrat39/rust-tools.nvim',
    {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    },
    "christoomey/vim-tmux-navigator", -- tmux & split window navigation
    "tpope/vim-fugitive",
    "ThePrimeagen/vim-be-good",
    -- tabs
    'nvim-tree/nvim-web-devicons',
    {'romgrk/barbar.nvim', dependencies = 'nvim-web-devicons'},
    -- latex
    'lervag/vimtex',
    -- quarto
    'quarto-dev/quarto-nvim',
    'jmbuhr/otter.nvim',
}

require("lazy").setup(plugins, {})
