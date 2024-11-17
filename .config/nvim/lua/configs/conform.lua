local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
    typescript = {
      "biome",
      timeout = 3000,
      args = { "format", "--stdin", "--stdin-filepath", "$FILENAME" },
      cwd = function(params)
        return vim.fn.fnamemodify(params.bufname, ":p:h") -- Set working directory to the file's directory
      end,
    },
    typescriptreact = {
      "biome",
      timeout = 3000,
      args = { "format", "--stdin", "--stdin-filepath", "$FILENAME" },
      cwd = function(params)
        return vim.fn.fnamemodify(params.bufname, ":p:h") -- Set working directory to the file's directory
      end,
    },
    javascript = {
      "biome",
      timeout = 3000,
      args = { "format", "--stdin", "--stdin-filepath", "$FILENAME" },
      cwd = function(params)
        return vim.fn.fnamemodify(params.bufname, ":p:h") -- Set working directory to the file's directory
      end,
    },
    javascriptreact = {
      "biome",
      timeout = 3000,
      args = { "format", "--stdin", "--stdin-filepath", "$FILENAME" },
      cwd = function(params)
        return vim.fn.fnamemodify(params.bufname, ":p:h") -- Set working directory to the file's directory
      end,
    },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
