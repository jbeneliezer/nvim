require("settings.options")

-- get lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local lazy_opts = {
    ui = {
        border = "rounded",
    },
    rocks = { enabled = false },
}

require("lazy").setup("plugins", lazy_opts)

require("settings.keymaps")
require("settings.autocmds")
