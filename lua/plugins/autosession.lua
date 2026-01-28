return {
	"rmagatti/auto-session",
	lazy = false,
	config = function()
		require("auto-session").setup({
			auto_restore = true,
			auto_save = true,
			root_dir = vim.fn.stdpath("data") .. "/sessions/",
			session_lens = {
				picker_opts = {
					border = true,
					layout_config = {
						height = 0.9,
						preview_cutoff = 120,
						prompt_position = "bottom",
						width = 0.8,
					},
					layout_strategy = "horizontal",
					sorting_strategy = "descending",
				},
				previewer = true,
			},
		})
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
	end,
}
