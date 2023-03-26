local default_opts = { noremap = true, silent = true }
local keymap = function(mode, lhs, rhs, opts, description)
	local local_opts = opts
	local_opts["desc"] = description or "which_key_ignore"
	vim.keymap.set(mode, lhs, rhs, local_opts)
	-- end
end

local toggle_source = function(source)
	local cmp = require("cmp")
	local toggle = false
	local sources = cmp.get_config().sources

	for i = #sources, 1, -1 do
		if sources[i].name == source then
			table.remove(sources, i)
			toggle = true
		end
	end

	if not toggle then
		table.insert(sources, { name = source })
	end

	cmp.setup.buffer({
		sources = sources,
	})
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
keymap({ "n", "t" }, "<c-t>", "<cmd>ToggleTerm<cr>", default_opts)

-- LF
keymap({ "n", "v" }, "<c-e>", require("lf").start, default_opts)

-- lazygit
local lazygit = require("toggleterm.terminal").Terminal:new({
	cmd = "lazygit",
	hidden = true,
	op_open = function(_)
		vim.cmd("startinsert!")
	end,
})

keymap({ "n", "v", "t" }, "<c-g>", function()
	lazygit:toggle()
end, default_opts)

-- Todo-comments
keymap("n", "]t", function()
	require("todo-comments").jump_next()
end, default_opts)

keymap("n", "[t", function()
	require("todo-comments").jump_prev()
end, default_opts)

local ok, wk = pcall(require, "which-key")
if not ok then
	return
end

local wk_opts = { prefix = "<leader>" }
local wk_vopts = { mode = "v", prefix = "<leader>" }
local wk_topts = { mode = "t", prefix = "<leader>" }

local mappings = {
	C = {
		function()
			toggle_source("copilot")
		end,
		"Toggle Copilot",
	},
	c = { "<cmd>bdelete<cr>", "Close" },
	e = { "<cmd>Lex 25<cr>", "Explorer" },
	j = { "<cmd>m .+1<cr>==", "which_key_ignore" },
	k = { "<cmd>m .-2<cr>==", "which_key_ignore" },
	m = { require("grapple").toggle, "Toggle Tag" },
	o = { "<cmd>ToggleOnly<cr>", "fullscreen" },
	q = { "<cmd>q<cr>", "Quit" },
	t = { require("trouble").toggle, "Trouble" },
	w = { "<cmd>w<cr>", "Save" },
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
	f = {
		name = "Telescope",
		a = { require("telescope.builtin").autocommands, "Autocommands" },
		c = { require("telescope.builtin").commands, "Commands" },
		C = {
			function()
				require("telescope.builtin").colorscheme({ enable_preview = true })
			end,
			"Colorscheme",
		},
		f = { require("telescope.builtin").find_files, "Find Files" },
		r = { require("telescope.builtin").oldfiles, "Find Recent" },
		g = { require("telescope.builtin").live_grep, "Live Grep" },
		h = { require("telescope.builtin").help_tags, "Help Tags" },
		H = { require("telescope.builtin").highlights, "Highlights" },
		k = { require("telescope.builtin").keymaps, "Keymaps" },
		p = { require("telescope").extensions.project.project, "Project" },
	},
	g = {
		name = "Git",
		b = { require("telescope.builtin").git_branches, "Find Branch" },
		c = { require("telescope.builtin").git_commits, "Find Commit" },
		d = { require("gitsigns").diffthis, "Diff", mode = { "n", "v" } },
		D = {
			function()
				require("gitsigns").diffthis("~")
			end,
			"Diff with Head",
		},
		j = { require("gitsigns").next_hunk, "Next Hunk", mode = { "n", "v" } },
		k = { require("gitsigns").prev_hunk, "Prev Hunk", mode = { "n", "v" } },
		p = { require("gitsigns").preview_hunk, "Preview Hunk", mode = { "n", "v" } },
		r = { require("gitsigns").reset_hunk, "Reset Hunk", mode = { "n", "v" } },
		R = { require("gitsigns").reset_buffer, "Reset Buffer", mode = { "n", "v" } },
		t = { require("gitsigns").blame_line, "Blame", mode = { "n", "v" } },
		s = { require("gitsigns").stage_hunk, "Stage Hunk", mode = { "n", "v" } },
		S = { require("gitsigns").stage_buffer, "Stage Buffer", mode = { "n", "v" } },
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
