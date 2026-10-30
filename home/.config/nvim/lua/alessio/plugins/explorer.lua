-- VS Code-like file tree on the left
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
  keys = {
    { "<leader>e", "<Cmd>NvimTreeToggle<CR>" },
    { "<leader>E", "<Cmd>NvimTreeFindFile<CR>" },
  },
  opts = {
    view = { side = "left", width = 32 },
    update_focused_file = { enable = true },
    renderer = { group_empty = true },
  },
}
