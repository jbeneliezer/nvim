local options = {
	backup = false,
	background = "dark",
	cmdheight = 1,
	completeopt = { "menuone", "noselect" },
	conceallevel = 0,
	colorcolumn = "80",
	fileencoding = "utf-8",
	incsearch = true,
	hlsearch = false,
	ignorecase = true,
	laststatus = 0,
	mouse = "a",
	pumheight = 10,
	showmode = false,
	showtabline = 2,
	smartcase = true,
	smartindent = true,
	splitbelow = true,
	splitright = true,
	swapfile = false,
	termguicolors = true,
	timeoutlen = 0,
	undodir = vim.fn.stdpath("config") .. "/.undo",
	undofile = true,
	updatetime = 300,
	writebackup = false,
	expandtab = false,
	shiftwidth = 2,
	tabstop = 2,
	cursorline = true,
	cursorcolumn = true,
	number = true,
	relativenumber = true,
	numberwidth = 4,
	signcolumn = "yes",
	wrap = false,
	scrolloff = 8,
	sidescrolloff = 8,
	ruler = false,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.opt.shortmess:append("c")
vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])

-- clipboard
vim.opt.clipboard:append("unnamedplus")
