vim.api.nvim_create_augroup("CustomHighlights", { clear = true })
vim.api.nvim_create_augroup("TermKeymaps", { clear = true })
vim.api.nvim_create_augroup("PythonKeymaps", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "Colorscheme" }, {
    desc = "link Pmenu to Normal",
    callback = function()
        vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })
        vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    end,
    group = "CustomHighlights",
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "set colorcolumn for python",
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "python" then
            vim.wo.colorcolumn = "120"
        else
            vim.wo.colorcolumn = "80"
        end
    end,
    group = "CustomHighlights",
})

vim.api.nvim_create_autocmd("TermOpen", {
    desc = "set keymaps for terminal",
    pattern = "term://*",
    callback = function()
        require("settings.keymaps").set_term_keymaps()
    end,
    group = "TermKeymaps",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("help_window_right", {}),
    pattern = { "*.txt" },
    callback = function()
        if vim.o.filetype == "help" then
            vim.cmd.wincmd("L")
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    desc = "Set IPython Keymaps",
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "python" then
            require("settings.keymaps").set_ipy_keymaps()
        end
    end,
    group = "PythonKeymaps",
})

vim.api.nvim_create_autocmd("User", {
    desc = "Set Molten Highlights",
    pattern = "MoltenInitPost",
    callback = function()
        vim.api.nvim_set_hl(0, "MoltenOutputBorder", { link = "DiagnosticHint" })
        vim.api.nvim_set_hl(0, "MoltenOutputBorderFail", { link = "DiagnosticError" })
        vim.api.nvim_set_hl(0, "MoltenOutputBorderSuccess", { link = "String" })
    end,
    group = "CustomHighlights",
})

vim.api.nvim_create_autocmd("User", {
    desc = "Set Molten Keymaps",
    pattern = "MoltenInitPost",
    callback = function()
        require("settings.keymaps").set_molten_keymaps()
    end,
    group = "PythonKeymaps",
})