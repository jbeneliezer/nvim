local default_opts = { noremap = true, silent = true }
--[[ local term_opts = { silent = true } ]]
local keymap = function(mode, lhs, rhs, opts, description)
	local local_opts = opts
	local_opts["desc"] = description or "which_key_ignore"
	vim.keymap.set(mode, lhs, rhs, local_opts)
	-- end
end

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "<c-n>", "J", default_opts)
keymap("v", "<c-n>", "J", default_opts)

keymap("n", "<s-j>", "<c-d>zz", default_opts)
keymap("n", "<s-k>", "<c-u>zz", default_opts)
keymap("v", "<s-j>", "<c-d>zz", default_opts)
keymap("v", "<s-k>", "<c-u>zz", default_opts)

-- Windows
keymap("n", "<c-h>", "<c-w>h", default_opts)
keymap("n", "<c-j>", "<c-w>j", default_opts)
keymap("n", "<c-k>", "<c-w>k", default_opts)
keymap("n", "<c-l>", "<c-w>l", default_opts)

-- Resize with arrows
keymap("n", "<c-Up>", "<cmd>resize -2<cr>", default_opts)
keymap("n", "<c-Down>", "<cmd>resize +2<cr>", default_opts)
keymap("n", "<c-Left>", "<cmd>vertical resize -2<cr>", default_opts)
keymap("n", "<c-Right>", "<cmd>vertical resize +2<cr>", default_opts)

-- Navigate buffers
keymap("n", "<s-l>", "<cmd>BufferLineCycleNext<cr>", default_opts)
keymap("n", "<s-h>", "<cmd>BufferLineCyclePrev<cr>", default_opts)
keymap("n", "<leader>c", "<cmd>bdelete<cr>", default_opts)

-- Stay in indent mode
keymap("v", "<", "<gv", default_opts)
keymap("v", ">", ">gv", default_opts)

-- Paste in visual mode
keymap("v", "p", '"_dP', default_opts)

-- Toggleterm
keymap({ "n", "t" }, "<c-t>", "<cmd>ToggleTerm<cr>", default_opts, "terminal")

local joshuto = require("toggleterm.terminal").Terminal:new({ cmd = "joshuto", dir = vim.fn.getcwd(), hidden = false })
function _JOSHUTO_TOGGLE()
	joshuto:toggle()
end

keymap({ "n", "t" }, "<c-e>", "<cmd>lua _JOSHUTO_TOGGLE()<cr>", default_opts, "explorer")

local ok, wk = pcall(require, "which-key")
if not ok then
	return
end

local wk_opts = { prefix = "<leader>" }
local wk_vopts = { mode = "v", prefix = "<leader>" }
local wk_topts = { mode = "t", prefix = "<leader>" }

local mappings = {
	o = { "<cmd>ToggleOnly<cr>", "fullscreen" },
	e = { "<cmd>Lex 25<cr>", "Explorer" },
	w = { "<cmd>w<cr>", "Save" },
	q = { "<cmd>q<cr>", "Quit" },
	c = { "<cmd>bdelete<cr>", "Close" },
	j = { "<cmd>m .+1<cr>==", "which_key_ignore" },
	k = { "<cmd>m .-2<cr>==", "which_key_ignore" },
	m = { require("grapple").toggle, "Toggle Tag" },
	t = { require("dap").toggle_breakpoint, "Breakpoint" },
	["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment", noremap = false },
	["1"] = {
		function()
			require("bufferline").go_to_buffer(1, true)
		end,
		"which_key_ignore",
	},
	["2"] = {
		function()
			require("bufferline").go_to_buffer(2, true)
		end,
		"which_key_ignore",
	},
	["3"] = {
		function()
			require("bufferline").go_to_buffer(3, true)
		end,
		"which_key_ignore",
	},
	["4"] = {
		function()
			require("bufferline").go_to_buffer(4, true)
		end,
		"which_key_ignore",
	},
	["5"] = {
		function()
			require("bufferline").go_to_buffer(5, true)
		end,
		"which_key_ignore",
	},
	["6"] = {
		function()
			require("bufferline").go_to_buffer(6, true)
		end,
		"which_key_ignore",
	},
	["7"] = {
		function()
			require("bufferline").go_to_buffer(7, true)
		end,
		"which_key_ignore",
	},
	["8"] = {
		function()
			require("bufferline").go_to_buffer(8, true)
		end,
		"which_key_ignore",
	},
	["9"] = {
		function()
			require("bufferline").go_to_buffer(9, true)
		end,
		"which_key_ignore",
	},
	L = { "<cmd>BufferLineMoveNext<cr>", "which_key_ignore" },
	H = { "<cmd>BufferLineMovePrev<cr>", "which_key_ignore" },
	f = {
		name = "Telescope",
		f = { require("telescope.builtin").find_files, "Find Files" },
		r = { require("telescope.builtin").oldfiles, "Find Recent" },
		g = { require("telescope.builtin").live_grep, "Live Grep" },
		b = { require("telescope.builtin").git_branches, "Find Branch" },
		c = { require("telescope.builtin").git_commits, "Find Commit" },
		h = { require("telescope.builtin").help_tags, "Help Tags" },
		H = { require("telescope.builtin").highlights, "Highlights" },
		k = { require("telescope.builtin").keymaps, "Keymaps" },
		p = { require("telescope").extensions.project.project, "Project" },
	},
	d = {
		name = "Dap",
		a = {
			function()
				require("dapui").elements.watches.add(vim.fn.input("Expression: "))
			end,
			"Add Watch",
		},
		u = { require("dapui").toggle, "UI" },
		t = { require("dap").toggle_breakpoint, "Breakpoint" },
		c = { require("dap").continue, "Continue" },
		r = { require("dap").run_last, "Run Last" },
		R = { require("dap").repl.toggle, "Repl" },
		p = { require("dap").pause, "Pause" },
		q = { require("dap").terminate, "Quit" },
		s = {
			name = "Step",
			i = { require("dap").step_into, "Into" },
			o = { require("dap").step_over, "Over" },
			u = { require("dap").step_out, "Out" },
		},
	},
}

local vmappings = {
	j = { "<cmd>m '>+1<cr>gv=gv" },
	k = { "<cmd>m '<-2<cr>gv=gv" },
	["/"] = { "<Plug>(comment_toggle_linewise_visual)gv", "Comment", noremap = false },
}

local tmappings = {}

wk.register(mappings, wk_opts)
wk.register(vmappings, wk_vopts)
wk.register(tmappings, wk_topts)
