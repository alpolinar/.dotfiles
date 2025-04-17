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
        "typescript-language-server",
        "yaml-language-server",
        "css-lsp",
        "html-lsp",
        "rust-analyzer",
        "tailwindcss-language-server",
        "hyprls",
        -- "graphql-language-service-cli",
      },
    },
  },
}
