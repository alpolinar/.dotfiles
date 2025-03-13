return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      typescript = function(bufnr)
        if require("conform").get_formatter_info("biome", bufnr).available then
          return { "biome" }
        else
          return { "vtsls" }
        end
      end,
      typescriptreact = function(bufnr)
        if require("conform").get_formatter_info("biome", bufnr).available then
          return { "biome" }
        else
          return { "vtsls" }
        end
      end,
      javascript = function(bufnr)
        if require("conform").get_formatter_info("biome", bufnr).available then
          return { "biome" }
        else
          return { "vtsls" }
        end
      end,
      javascriptreact = function(bufnr)
        if require("conform").get_formatter_info("biome", bufnr).available then
          return { "biome" }
        else
          return { "vtsls" }
        end
      end,
      graphql = { "biome" },
    },
  },
}
