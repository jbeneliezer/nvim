local opts = { noremap = true, silent = true }
--[[ local term_opts = { silent = true } ]]

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

keymap("n", "*", "", opts)
keymap("v", "*", "", opts)

keymap("n", "<c-n>", "J", opts)
keymap("v", "<c-n>", "J", opts)

keymap("n", "<s-j>", "<c-d>zz", opts)
keymap("n", "<s-k>", "<c-u>zz", opts)
keymap("v", "<s-j>", "<c-d>zz", opts)
keymap("v", "<s-k>", "<c-u>zz", opts)

-- Better window navigation
keymap("n", "<c-h>", "<c-w>h", opts)
keymap("n", "<c-j>", "<c-w>j", opts)
keymap("n", "<c-k>", "<c-w>k", opts)
keymap("n", "<c-l>", "<c-w>l", opts)

-- Resize with arrows
keymap("n", "<c-Up>", "<cmd>resize -2<cr>", opts)
keymap("n", "<c-Down>", "<cmd>resize +2<cr>", opts)
keymap("n", "<c-Left>", "<cmd>vertical resize -2<cr>", opts)
keymap("n", "<c-Right>", "<cmd>vertical resize +2<cr>", opts)

-- Navigate buffers
keymap("n", "<s-l>", "<cmd>bnext<cr>", opts)
keymap("n", "<s-h>", "<cmd>bprevious<cr>", opts)
--[[ keymap("n", "<leader>c", "<cmd>Bdelete!<cr>", opts) ]]

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Paste in visual mode
keymap("v", "p", '"_dP', opts)

-- Toggleterm
keymap("n", "<nl>", "<cmd>ToggleTerm<cr>", opts)
keymap("t", "<nl>", "<cmd>ToggleTerm<cr>", opts)

-- Git
keymap("n", "<c-g>", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", opts)

-- T
keymap("n", "<c-f>", "<cmd>!sh tt<cr>", opts)

-- Dap
--[[ keymap("n", "<leader>t", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts) ]]
--[[ keymap("n", "<F8>", "<cmd>lua require'dap'.continue()<cr>", opts) ]]
--[[ keymap("n", "<F9>", "<cmd>lua require'dap'.step_into()<cr>", opts) ]]
--[[ keymap("n", "<F10>", "<cmd>lua require'dap'.step_over()<cr>", opts) ]]
--[[ keymap("n", "<F11>", "<cmd>lua require'dap'.step_out()<cr>", opts) ]]
--[[ keymap("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts) ]]
--[[ keymap("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", opts) ]]
--[[ keymap("n", "<c-d>", "<cmd>lua require'dapui'.toggle()<cr>", opts) ]]
--[[ keymap("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts) ]]
