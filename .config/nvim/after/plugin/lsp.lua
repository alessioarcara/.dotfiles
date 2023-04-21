local lsp = require("lsp-zero")
local lspconfig = require('lspconfig')

lsp.preset("recommended")

lspconfig.tsserver.setup({})

lsp.ensure_installed({
    'tsserver',
    'rust_analyzer',
})

lspconfig.lua_ls.setup {
   settings = {
     Lua = {
       runtime = {
         version = 'LuaJIT',
       },
       diagnostics = {
         globals = {'vim'},
       },
       workspace = {
         library = vim.api.nvim_get_runtime_file("", true),
       },
       telemetry = {
         enable = false,
       },
     },
   },
 }

lsp.on_attach(function(_, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
