vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz",
  { desc = "scroll down and then center the cursorline" })

vim.keymap.set("n", "<C-u>", "<C-u>zz",
  { desc = "scroll up and then center the cursorline" })

vim.keymap.set({ "n", "x" }, "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")
