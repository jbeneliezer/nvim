return {
	"lukas-reineke/indent-blankline.nvim",
	config = function()
		require("indent_blankline").setup({
			show_current_context = true,
			show_current_context_start = true,
		})

		vim.cmd("hi IndentBlanklineContextStart guisp=#000000 gui=nocombine")

		-- vim.api.nvim_create_autocmd({ "Colorscheme" }, {
		-- 	desc = "remove underline from context start",
		-- 	command = "hi IndentBlanklineContextStart guisp=#000000 gui=nocombine",
		-- })
	end,
}
