return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- format on save
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end
  },
  {
    "github/copilot.vim",
    event = "InsertEnter"
  }
}

