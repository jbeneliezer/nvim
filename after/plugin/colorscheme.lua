local status_ok, _ = pcall(require, "tokyonight")
if not status_ok then
	return
end

vim.cmd("colorscheme tokyonight-night")
