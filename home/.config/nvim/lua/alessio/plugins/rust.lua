return {
  "mrcjkb/rustaceanvim",
  version = "^9",
  lazy = false, -- the plugin is already lazy on rust files
  init = function()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = { allFeatures = true },
          },
        },
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<C-space>", function() vim.cmd.RustLsp({ "hover", "actions" }) end,
            { buffer = bufnr })
          vim.keymap.set("n", "<leader>a", function() vim.cmd.RustLsp("codeAction") end,
            { buffer = bufnr })
        end,
      },
    }
  end,
}
