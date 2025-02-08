-- For OS-specific configuration
Os = { LINUX = {}, WINDOWS = {} }
OsCurrent = nil
if vim.uv.os_uname().sysname == "Windows_NT" then
    OsCurrent = Os.WINDOWS
elseif vim.uv.os_uname().sysname == "Linux" then
    OsCurrent = Os.LINUX
end

require("settings.options")

-- Bootstrap lazy.nvim
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
    custom_keys = { K = false },
    diff = "diffview.nvim",
    ui = {
        border = "rounded",
    },
    rocks = { enabled = false },
    change_detection = {
        notify = false,
    },
}

require("lazy").setup("plugins", lazy_opts)

require("settings.keymaps").set_normal_keymaps()
require("settings.autocmds")