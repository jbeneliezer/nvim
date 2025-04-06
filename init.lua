---@enum os
OS = { LINUX = {}, WINDOWS = {} }

---@type os
OsCurrent = nil
if vim.uv.os_uname().sysname == "Windows_NT" then
    OsCurrent = OS.WINDOWS
elseif vim.uv.os_uname().sysname == "Linux" then
    OsCurrent = OS.LINUX
end

---@module "settings.options"
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
    install = { colorscheme = { "retrobox" } },
    ui = {
        border = "rounded",
    },
    custom_keys = {
        ["K"] = {
            function(_)
                vim.cmd.normal("<c-u>zz")
            end,
            desc = "<c-u>zz",
        },
    },
    diff = { cmd = "diffview.nvim" },
    rocks = { enabled = false },
    change_detection = {
        notify = false,
    },
}

require("lazy").setup("plugins", lazy_opts)

---@module "settings.keymaps"
require("settings.keymaps").set_basic_keymaps()
---@module "settings.autocmds"
require("settings.autocmds")
