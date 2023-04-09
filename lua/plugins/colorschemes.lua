return {
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme gruvbox")
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		-- config = function()
		-- 	vim.cmd("colorscheme tokyonight-night")
		-- end,
	},
	{
		"Everblush/nvim",
		name = "everblush",
		lazy = false,
		priority = 1000,
		-- config = function()
		-- 	vim.cmd("colorscheme everblush")
		-- end,
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		-- config = function()
		-- 	vim.cmd("colorscheme nightfox")
		-- end,
	},
}
