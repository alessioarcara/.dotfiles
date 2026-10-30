return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },
  -- tmux & split window navigation with <C-h/j/k/l>
  { "christoomey/vim-tmux-navigator", lazy = false },
  {
    "romgrk/barbar.nvim",
    version = "^1.0.0",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = false,
    init = function() vim.g.barbar_auto_setup = false end,
    -- shift the tabs right of the nvim-tree sidebar
    opts = { sidebar_filetypes = { NvimTree = true } },
    keys = {
      { "<A-,>", "<Cmd>BufferPrevious<CR>" },
      { "<A-.>", "<Cmd>BufferNext<CR>" },
      { "<A-<>", "<Cmd>BufferMovePrevious<CR>" },
      { "<A->>", "<Cmd>BufferMoveNext<CR>" },
      { "<A-1>", "<Cmd>BufferGoto 1<CR>" },
      { "<A-2>", "<Cmd>BufferGoto 2<CR>" },
      { "<A-3>", "<Cmd>BufferGoto 3<CR>" },
      { "<A-4>", "<Cmd>BufferGoto 4<CR>" },
      { "<A-5>", "<Cmd>BufferGoto 5<CR>" },
      { "<A-c>", "<Cmd>BufferClose<CR>" },
      { "<A-p>", "<Cmd>BufferPick<CR>" },
    },
  },
}
