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
    mousemodel = "extend",
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
    expandtab = true,
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
    fileformat = "unix",
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

vim.opt.shortmess:append("acI")
vim.opt.whichwrap:append("<,>,[,]")
vim.opt.iskeyword:append("-")

-- clipboard
vim.opt.clipboard:append("unnamedplus")

-- leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- python3_provider
vim.g.python3_host_prog = vim.fn.stdpath("config")
    .. (OsCurrent == OS.WINDOWS and "\\.venv\\Scripts\\python.exe" or "/.venv/bin/python")
-- vim.g.loaded_python3_provider=0

-- neovide
if vim.g.neovide then
    vim.g.neovide_position_animation_length = 0
    vim.g.neovide_scroll_animation_length = 0
    vim.g.neovide_scroll_animation_far_lines = 0
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = false
end
