local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map('n', '<C-b>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<C-n>', '<Cmd>BufferNext<CR>', opts)
-- Re-order to previous/next
map('n', '<C-<>', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', '<C->>', '<Cmd>BufferMoveNext<CR>', opts)
-- Close buffer
map('n', '<C-c>', '<Cmd>BufferClose<CR>', opts)
-- Magic buffer-picking mode
map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)
-- Goto buffer in position...
map('n', '<C-q>', '<Cmd>BufferGoto 1<CR>', opts)
map('n', '<C-w>', '<Cmd>BufferGoto 2<CR>', opts)
map('n', '<C-e>', '<Cmd>BufferGoto 3<CR>', opts)
map('n', '<C-r>', '<Cmd>BufferGoto 4<CR>', opts)
