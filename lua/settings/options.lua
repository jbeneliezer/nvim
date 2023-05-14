local options = {
    backup = false,
    background = "dark",
    cmdheight = 1,
    completeopt = { "menu", "menuone", "noselect" },
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
    timeoutlen = 100,
    undodir = vim.fn.stdpath("config") .. "/.undo",
    undofile = true,
    updatetime = 300,
    writebackup = false,
    expandtab = false,
    shiftwidth = 4,
    tabstop = 4,
    cursorline = true,
    number = true,
    relativenumber = true,
    numberwidth = 4,
    signcolumn = "yes:2",
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
vim.cmd("set iskeyword+=-")

-- clipboard
vim.opt.clipboard:append("unnamedplus")

-- Powershell
if vim.loop.os_uname().sysname == "Windows_NT" then
    vim.opt.shell = "powershell"
    vim.opt.shellcmdflag = "-NoLogo -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = "-RedirectStandardOutput %s; -NoNewWindow -Wait"
    vim.opt.shellpipe = "2>&1 | OutFile -Encoding UTF8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
end

-- leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "