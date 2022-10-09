local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
	ignore_install = { "" }, -- List of parsers to ignore installing
	autopairs = {
		enable = true,
	},
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "" }, -- list of language that will be disabled
		additional_vim_regex_highlighting = true,
	},
	rainbow = {
		enable = false,
		extended_mode = true,
		colors = { "#bb9af7", "#2ac3de", "#73daca", "#9ece6a", "#e0af68", "#ff9e64", "#f7768e" },
	},
	indent = { enable = true, disable = { "yaml" } },
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})

-- treesitter context
local context_ok, context = pcall(require, "treesitter-context")
if not context_ok then
	return
end

context.setup({
	enable = true,
	mode = "cursor",
	separator = "=",
})
