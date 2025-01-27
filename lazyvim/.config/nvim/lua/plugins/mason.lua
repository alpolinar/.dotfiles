return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "biome",
        "graphql-language-service-cli",
        "typescript-language-server",
        "yaml-language-server",
        "css-lsp",
        "html-lsp",
        "rust-analyzer",
      },
    },
  },
}
