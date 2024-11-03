require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { desc =  "Toggle Breakpoin"})
map("n", "<leader>dus", function()
  local widget = require('dap.ui.widgets');
  local sidebar = widget.sidebar(widget.scopes);
  sidebar.open();
end, { desc = "Open debugging sidebar"})
map("n", "<leader>rcu", function()
  require("crates").upgrade_all_crates()
end, { desc = "Update crates"})
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
