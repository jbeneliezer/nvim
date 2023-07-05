return {
	"lukas-reineke/indent-blankline.nvim",
	event = "BufEnter",
	config = function()
		require("indent_blankline").setup({
			show_current_context = true,
			show_current_context_start = true,
		})

		vim.cmd("hi IndentBlanklineContextStart guisp=#000000 gui=nocombine")
	end,
}
