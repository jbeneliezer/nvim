return {
	"jackMort/ChatGPT.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	lazy = true,
	-- cond = true,
	cond = function(_)
		return os.getenv("OPENAI_API_KEY") ~= nil
	end,
	config = function()
		require("chatgpt").setup({
			keymaps = {
				close = { "<c-c>" },
				submit = "<c-Enter>",
				yank_last = "<C-y>",
				yank_last_code = "<C-m>",
				scroll_up = "K",
				scroll_down = "J",
				toggle_settings = "<C-/>",
				new_session = "<C-n>",
				cycle_windows = "<Tab>",
				-- in the Sessions pane
				select_session = "<Space>",
				rename_session = "r",
				delete_session = "d",
			},
		})
	end,
}
