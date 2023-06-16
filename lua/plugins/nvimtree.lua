return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        view = {
            width = 35,
        },
        actions = {
            open_file = {
                quit_on_open = true,
            },
        },
    },
}
