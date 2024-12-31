return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false, -- This plugin is already lazy
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
          end,
          settings = {
            -- rust-analyzer settings
            ['rust-analyzer'] = {
              checkOnSave = {
                command = "clippy",
              },
              -- Enable all inlay hints
              inlayHints = { locationLinks = false },
            },
          },
        },
      }
    end
  }
}
