return {
	"nvim-treesitter/nvim-treesitter",
	event = "VimEnter",
	build = function()
		require("nvim-treesitter.install").update({ with_sync = true })
	end,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "rust", "lua", "vim", "vimdoc", "query", "python" },
			auto_install = true,
			highlight = { enable = true },
		})
	end,
}
