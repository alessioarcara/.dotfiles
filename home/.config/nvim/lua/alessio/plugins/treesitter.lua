-- `main` branch: requires the tree-sitter CLI and a C compiler to build parsers
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "bash", "c", "javascript", "json", "lua", "luadoc", "markdown",
      "markdown_inline", "python", "query", "rust", "toml", "tsx",
      "typescript", "vim", "vimdoc", "yaml",
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("alessio_treesitter", { clear = true }),
      callback = function(args)
        if not pcall(vim.treesitter.start, args.buf) then
          return
        end
        if args.match ~= "python" then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
