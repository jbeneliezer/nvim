return {
    {
        "ellisonleao/gruvbox.nvim",
    },
    {
        "folke/tokyonight.nvim",
    },
    {
        "Everblush/nvim",
        name = "everblush",
    },
    {
        "EdenEast/nightfox.nvim",
    },
    {
        "arturgoms/moonbow.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme moonbow")
        end,
    },
    {
        "rose-pine/neovim",
    },
    {
        "AlexvZyl/nordic.nvim",
    },
    {
        "Shatur/neovim-ayu",
    },
}