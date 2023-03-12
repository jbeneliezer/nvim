return {
	"akinsho/bufferline.nvim",
	tag = "v3.5.0",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("bufferline").setup({
			options = {
				numbers = "ordinal",
				indicator = { style = "none" },
				diagnostics = "nvim_lsp",
				show_buffer_close_icons = false,
				show_close_icon = false,
				separator_style = { "", "" },
			},
		})
	end,
}