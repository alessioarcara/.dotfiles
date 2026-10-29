return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>pf", function() require("telescope.builtin").find_files() end },
    -- git_files errors outside a repo, fall back to find_files
    {
      "<C-p>",
      function()
        if not pcall(require("telescope.builtin").git_files) then
          require("telescope.builtin").find_files()
        end
      end,
    },
    { "<leader>ps", function() require("telescope.builtin").live_grep() end },
  },
  config = function()
    require("telescope").setup({})
    require("telescope").load_extension("fzf")
  end,
}
