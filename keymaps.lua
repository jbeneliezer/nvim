
local default_opts = { noremap = true, silent = true}
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


local ok, wk = pcall(require, "which-key")
if not ok then
	return
end

local wk_opts = { prefix = "<leader>" }
local wk_vopts = { mode = "v", prefix = "<leader>" }
local wk_topts = { mode = "t", prefix = "<leader>" }

local mappings = {
	o = {"<c-w>o", "fullscreen"},
	e = {"<cmd>Lex 25<cr>", "Explorer"},
	w = {"<cmd>w<cr>", "Save"},
	q = {"<cmd>q<cr>", "Quit"},
	c = {"<cmd>bdelete<cr>", "Close"},
	j = {"<cmd>m .+1<cr>==", "which_key_ignore"},
	k = {"<cmd>m .-2<cr>==", "which_key_ignore"},
	["/"] = {"gcc", "Comment"},
	f = {
		name = "Telescope",
		f = { "<cmd>Telescope find_files<cr>", "Find Files"},
		r = { "<cmd>Telescope oldfiles<cr>", "Find Files"},
		g = { "<cmd>Telescope live_grep<cr>", "Live Grep"},
		b = { "<cmd>Telescope buffers<cr>", "Find Buffer"},
		h = { "<cmd>Telescope help_tags<cr>", "Help Tags"},
		k = { "<cmd>Telescope keymaps<cr>", "Keymaps"},
	},
}

local vmappings = {
	j = {"<cmd>m '>+1<cr>gv=gv"},
	k = {"<cmd>m '<-2<cr>gv=gv"},
}

local tmappings = {

}

wk.register(mappings, wk_opts)
wk.register(vmappings, wk_vopts)
wk.register(tmappings, wk_topts)

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
keymap("n", "<leader>o", "<c-w>o", default_opts, "fullscreen")
keymap("n", "<leader>e", "<cmd>Lex 25<cr>", default_opts)
keymap("n", "<leader>w", "<cmd>w<cr>", default_opts)
keymap("n", "<leader>q", "<cmd>q<cr>", default_opts)

-- Resize with arrows
keymap("n", "<c-Up>", "<cmd>resize -2<cr>", default_opts)
keymap("n", "<c-Down>", "<cmd>resize +2<cr>", default_opts)
keymap("n", "<c-Left>", "<cmd>vertical resize -2<cr>", default_opts)
keymap("n", "<c-Right>", "<cmd>vertical resize +2<cr>", default_opts)

-- Navigate buffers
keymap("n", "<s-l>", "<cmd>bnext<cr>", default_opts)
keymap("n", "<s-h>", "<cmd>bprevious<cr>", default_opts)
keymap("n", "<leader>c", "<cmd>bdelete<cr>", default_opts)

-- Stay in indent mode
keymap("v", "<", "<gv", default_opts)
keymap("v", ">", ">gv", default_opts)

-- Paste in visual mode
keymap("v", "p", '"_dP', default_opts)

-- Moving lines
keymap("n", "<leader>j", "<cmd>m .+1<cr>==", default_opts)
keymap("n", "<leader>k", "<cmd>m .-2<cr>==", default_opts)
keymap("v", "<leader>j", "<cmd>m '>+1<cr>gv=gv", default_opts)
keymap("v", "<leader>k", "<cmd>m '<-2<cr>gv=gv", default_opts)

-- Telescope
local builtin = require('telescope.builtin')
keymap('n', '<leader>ff', builtin.find_files, default_opts, "find files")
keymap('n', '<leader>fr', builtin.oldfiles, default_opts, "find recent")
keymap('n', '<leader>fg', builtin.live_grep, default_opts, "live grep")
keymap('n', '<leader>fb', builtin.buffers, default_opts, "find buffer")
keymap('n', '<leader>fh', builtin.help_tags, default_opts, "help tags")
keymap('n', '<leader>fk', builtin.keymaps, default_opts, "keymaps")

-- Toggleterm
keymap({'n', 't'}, '<c-t>', '<cmd>ToggleTerm<cr>', default_opts, 'terminal')

local joshuto = require("toggleterm.terminal").Terminal:new({cmd = "joshuto", dir = vim.fn.getcwd(), hidden = false})
function _JOSHUTO_TOGGLE()
	joshuto:toggle()
end

keymap({'n', 't'}, '<c-e>', "<cmd>lua _JOSHUTO_TOGGLE()<cr>", default_opts, 'explorer')

