require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { 'c', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vim', 'vimdoc' },

    sync_install = false,
    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = {
        enable = true,
        disable = { "latex" },
        additional_vim_regex_highlighting = { "latex" }
    },
    indent = { enable = true, disable = {'python'} },
    autopairs = { enable = true }
}
