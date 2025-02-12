-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local filetype_settings = {
  python = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  ruby = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  javascript = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  typescript = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  javascriptreact = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  typescriptreact = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  lua = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  go = { expandtab = false, shiftwidth = 4, tabstop = 4 },
  rust = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  cpp = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  c = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  java = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  html = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  css = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  yaml = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  json = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  jsonc = { expandtab = true, shiftwidth = 4, tabstop = 4 },
}

vim.api.nvim_create_augroup("AutoIndent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "AutoIndent",
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local settings = filetype_settings[ft]

    if settings then
      for option, value in pairs(settings) do
        vim.bo[option] = value
      end
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "fish",
  callback = function()
    vim.lsp.start({
      name = "fish-lsp",
      cmd = { "fish-lsp", "start" },
      cmd_env = { fish_lsp_show_client_popups = false },
    })
  end,
})
