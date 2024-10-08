return {
	"jackMort/ChatGPT.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	lazy = true,
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

		local wk = require("which-key")
		wk.register({
			["?"] = {
				name = "ChatGPT",
				["?"] = { require("chatgpt").openChat, "Open Chat" },
				a = { require("chatgpt").selectAwesomePrompt, "Select Prompt" },
				e = { require("chatgpt").edit_with_instructions, "Edit with Instructions" },
			},
		}, { mode = { "n", "v" }, prefix = "<leader>" })
	end,
}