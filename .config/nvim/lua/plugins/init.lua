local util = require "lspconfig.util"
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
        "stylua",
        "typescript-language-server",
        "biome",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        biome = {
          root_dir = function(fname)
            return util.root_pattern("biome.json", "biome.jsonc")(fname)
              or util.find_package_json_ancestor(fname)
              or util.find_node_modules_ancestor(fname)
              or util.find_git_ancestor(fname)
          end,
        },
      },
    },
    config = function()
      require "configs.lspconfig"
    end,
  },
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
