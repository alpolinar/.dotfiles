return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "biome",
        "typescript-language-server",
        "yaml-language-server",
        "css-lsp",
        "html-lsp",
        "rust-analyzer",
        "tailwindcss-language-server",
        "hyprls",
      },
    },
  },
}
