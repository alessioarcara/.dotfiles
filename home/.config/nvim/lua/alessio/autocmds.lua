local group = vim.api.nvim_create_augroup("alessio", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "tex", "markdown", "quarto", "gitcommit", "text" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "tex",
  callback = function()
    vim.opt_local.textwidth = 78
    vim.opt_local.formatoptions:append("t")
  end,
})
