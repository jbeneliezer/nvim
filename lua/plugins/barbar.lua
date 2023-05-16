return {
    "romgrk/barbar.nvim",
    dependencies = {
        "lewis6991/gitsigns.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    init = function()
        vim.g.barbar_auto_setup = false
    end,
    opts = {
        animation = false,
        highlight_alternate = true,
        highlight_inactive_file_icons = true,
        icons = {
            buffer_index = true,
            button = "",
            alternate = {},
            current = {},
            inactive = {},
            visible = {},
        },
        minimum_padding = 0,
    },
}
