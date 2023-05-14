vim.api.nvim_create_augroup("CustomHighlights", { clear = true })

vim.api.nvim_create_autocmd("Colorscheme", {
	desc = "remove underline from context start",
	command = "hi IndentBlanklineContextStart guisp=#000000 gui=nocombine",
	group = "CustomHighlights",
})

vim.api.nvim_create_autocmd({ "VimEnter", "Colorscheme" }, {
	desc = "link Pmenu to Normal",
	callback = function()
		vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })
		vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
	end,
	group = "CustomHighlights",
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "set colorcolumn for python",
	pattern = "*",
	callback = function()
        if vim.bo.filetype == "python" then
            vim.wo.colorcolumn = "120"
        else
            vim.wo.colorcolumn = "80"
        end
	end,
	group = "CustomHighlights",
})