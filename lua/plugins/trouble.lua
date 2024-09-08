return {
	"folke/trouble.nvim",
	event = "BufEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		height = 15,
		action_keys = {
			hover = "I",
		},
		auto_close = true,
        focus = true,
        warn_no_results = false,
	},
}