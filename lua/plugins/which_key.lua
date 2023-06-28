return {
	"folke/which-key.nvim",
	config = function()
		require("which-key").setup({
			plugins = {
				presets = {
					operators = false,
					text_objects = false,
					g = false,
				},
			},
			window = {
				border = "rounded",
			},
		})

		require("which-key").register({
			b = { name = "Breakpoints" },
			d = {
				name = "Dap",
				{
					s = { name = "Step" },
				},
			},
			f = { name = "Telescope" },
			g = { name = "Git" },
			n = { name = "Neotest" },
			m = { name = "Neogen" },
		}, { prefix = "<leader>" })
	end,
}
