local plugins = {
    {
        "nvchad/ui",
        config = function()
            require "nvchad"
        end
    },

    {
        "nvchad/base46",
        lazy = true,
        build = function()
           require("base46").load_all_highlights()
        end
    },

    {
        "stevearc/conform.nvim",
        event = 'BufWritePre', -- uncomment for format on save
        opts = require "configs.conform",
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },
    {
        "williamboman/mason.nvim"
    }
}

return plugins
