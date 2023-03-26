vim.api.nvim_create_augroup("CustomHighlights", { clear = true })

vim.api.nvim_create_autocmd({ "Colorscheme" }, {
	desc = "remove underline from context start",
	command = "hi IndentBlanklineContextStart guisp=#000000 gui=nocombine",
	group = "CustomHighlights",
})

vim.api.nvim_create_autocmd({ "Colorscheme" }, {
	desc = "link Pmenu to Normal",
	callback = function()
		vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })
	end,
	group = "CustomHighlights",
})
