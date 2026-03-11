return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        tsserver = {
          enabled = false,
        },
        vtsls = {
          enabled = false,
        },
      },
      setup = {
        tsserver = function()
          return true
        end,
        vtsls = function()
          return true
        end,
      },
    },
  },
}
