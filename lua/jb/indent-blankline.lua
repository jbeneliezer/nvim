local status_ok, indent = pcall(require, "indent_blankline")
if not status_ok then
	return
end

indent.setup({
	show_current_context = true,
	show_current_context_start = true,
})

vim.api.nvim_create_autocmd({ "ColorScheme" }, {
	desc = "remove underline from context start",
	command = "highlight IndentBlanklineContextStart guisp=#00FF00 gui=nocombine",
	group = vim.api.nvim_create_augroup("RemoveUnderline", { clear = true }),
})
