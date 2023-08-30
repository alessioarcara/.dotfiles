vim.g.vimtex_view_method = 'sioyek'	-- set VimTeX default pdf viewer

vim.g.vimtex_fold_enabled = 1 		-- enable VimTeX folding

vim.opt.conceallevel = 2		-- set conceal level to 2 (see :h conceallevel)

vim.g.vimtex_syntax_conceal = {		-- enable or disable specific conceals
    accents = 1,
    ligatures = 1,
    cites = 1,
    fancy = 1,
    spacing = 0,			-- default: 1
    greek = 1,
    math_bounds = 1,
    math_delimiters = 1,
    math_fracs = 1,
    math_super_sub = 1,
    math_symbols = 1,
    sections = 0,
    styles = 1,
}
