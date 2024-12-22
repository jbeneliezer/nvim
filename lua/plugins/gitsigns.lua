return {
    "lewis6991/gitsigns.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    event = "BufEnter",
    opts = {
        on_attach = function(bufnr)
            require("settings.keymaps").set_git_keymaps(bufnr)
        end,
    },
}
