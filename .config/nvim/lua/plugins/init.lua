local util = require "lspconfig.util"
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "html-lsp",
        "css-lsp",
        "rust-analyzer",
        "stylua",
        "typescript-language-server",
        "biome",
        "graphql-language-server-cli",
        "tailwindcss-language-server",
        "eslint-lsp",
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
        graphql = {
          filetypes = { "graphql", "gql" }, -- Add more if needed
          cmd = { "graphql-lsp", "server", "--method=stdio" },
          settings = {
            graphql = {
              schema = "**/*.schema.{graphql,gql}", -- Adjust based on your project structure
              documents = "./src/**/*.{graphql,gql}",
              format = {
                tabWidth = 4,
                useTabs = false,
              },
            },
          },
        },
      },
    },
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "html",
        "css",
        "graphql",
        "javascript",
        "typescript",
        "tsx",
        "rust",
      },
    },
  },
}
