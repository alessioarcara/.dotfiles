require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { 'c', 'lua', 'python', 'rust', 'tsx', 'typescript', 'help', 'vim' },

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = { enable = true },
    indent = { enable = true, disable = {'python'} },
    autopairs = { enable = true }
}
