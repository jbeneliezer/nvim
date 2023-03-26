OS = function()
	return vim.loop.os_uname().sysname
end

require("settings.options")

-- get lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local lazy_opts = {
	ui = {
		border = "rounded",
	},
}

require("lazy").setup(require("plugins"), lazy_opts)

require("settings.keymaps")
require("settings.autocmds")
