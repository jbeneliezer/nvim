return {
    "nvim-tree/nvim-tree.lua",
	event = "BufEnter",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        view = {
            width = 35,
        },
		filesystem_watchers = {
			enable = true,
			debounce_delay = 50,
			ignore_dirs = {"venv"},
		},
        actions = {
            open_file = {
                quit_on_open = true,
            },
        },
    },
}
