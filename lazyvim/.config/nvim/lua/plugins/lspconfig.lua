return {
  "neovim/nvim-lspconfig",
  event = "LazyFile",
  dependencies = {
    "mason.nvim",
    { "williamboman/mason-lspconfig.nvim", config = function() end },
  },
  opts = {
    servers = {
      graphql = {
        cmd = { "graphql-lsp", "server", "-m", "stream" },
        filetypes = { "graphql", "gql" },
      },
      yamlls = {
        filetypes = { "yaml", "yml" },
        settings = {
          yaml = {
            format = { enable = true },
            validate = true,
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      },
      jsonls = {
        filetypes = { "json", "jsonc" },
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      },
    },
  },
}
