return {
    {
        "ellisonleao/gruvbox.nvim",
        enabled = false,
    },
    {
        "folke/tokyonight.nvim",
        enabled = false,
    },
    {
        "Everblush/nvim",
        name = "everblush",
        enabled = false,
    },
    {
        "EdenEast/nightfox.nvim",
        enabled = false,
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
        enabled = false,
    },
    {
        "AlexvZyl/nordic.nvim",
        enabled = false,
    },
    {
        "neanias/everforest-nvim",
        enabled = false,
    },
    {
        "Mofiqul/vscode.nvim",
        enabled = false,
    },
}
