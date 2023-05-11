return {
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "Everblush/nvim",
        name = "everblush",
        lazy = false,
        priority = 1000,
    },
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "arturgoms/moonbow.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme moonbow")
        end,
    },
}
