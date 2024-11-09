return {
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function()
      local crates = require "crates"
      crates.setup {
        completion = {
          cmp = {
            enabled = true,
          },
        },
      }
      crates.show()
    end,
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --   },
  --   config = function()
  --     local cmp = require "cmp"
  --     cmp.setup {
  --       sources = {
  --         { name = "nvim_lsp" },
  --         { name = "crates" },
  --       },
  --       -- rest of your cmp config...
  --     }
  --   end,
  -- },
}
