return {
  "quarto-dev/quarto-nvim",
  ft = "quarto",
  dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
  opts = {},
  keys = {
    { "<leader>qp", function() require("quarto").quartoPreview() end, ft = "quarto" },
  },
}
