local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Re-order to previous/next
map('n', '<C-b>', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', '<C-n>', '<Cmd>BufferMoveNext<CR>', opts)
-- Close buffer
map('n', '<C-c>', '<Cmd>BufferClose<CR>', opts)
-- Magic buffer-picking mode
map('n', '<C-s>', '<Cmd>BufferPick<CR>', opts)
-- Goto buffer in position...
map('n', '<C-q>', '<Cmd>BufferGoto 1<CR>', opts)
map('n', '<C-w>', '<Cmd>BufferGoto 2<CR>', opts)
map('n', '<C-e>', '<Cmd>BufferGoto 3<CR>', opts)
map('n', '<C-r>', '<Cmd>BufferGoto 4<CR>', opts)
