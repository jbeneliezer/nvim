vim.api.nvim_create_augroup("CustomHighlights", { clear = true })
vim.api.nvim_create_augroup("TermKeymaps", { clear = true })
vim.api.nvim_create_augroup("PythonKeymaps", { clear = true })
vim.api.nvim_create_augroup("DiffviewKeymaps", { clear = true })
vim.api.nvim_create_augroup("LspKeymaps", { clear = true })

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

vim.api.nvim_create_autocmd("FileType", {
    desc = "Set Neotest Keymaps",
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "python" then
            require("settings.keymaps").set_neotest_keymaps()
        end
    end,
    group = "PythonKeymaps",
})

vim.api.nvim_create_autocmd("User", {
    desc = "Set Molten Keymaps",
    pattern = "MoltenInitPost",
    callback = function()
        require("settings.keymaps").set_molten_keymaps()
    end,
    group = "PythonKeymaps",
})

vim.api.nvim_create_autocmd("User", {
    desc = "Delete Molten Keymaps",
    pattern = "MoltenDeinitPre",
    callback = function()
        require("settings.keymaps").del_molten_keymaps()
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
    desc = "Set Diffview Close Keymaps",
    pattern = "DiffviewViewOpened",
    callback = function()
        require("settings.keymaps").set_dv_close_keymaps()
    end,
    group = "DiffviewKeymaps",
})

vim.api.nvim_create_autocmd("User", {
    desc = "Set Diffview Open Keymaps",
    pattern = "DiffviewViewClosed",
    callback = function()
        require("settings.keymaps").set_dv_open_keymaps()
    end,
    group = "DiffviewKeymaps",
})

local darken = function(color, pct)
    local r = math.floor(color / (2 ^ 16)) % 0x100
    local g = math.floor(color / (2 ^ 8)) % 0x100
    local b = math.floor(color) % 0x100
    r = math.floor(math.min((r * pct), 0xFF))
    g = math.floor(math.min((g * pct), 0xFF))
    b = math.floor(math.min((b * pct), 0xFF))
    local c = r * (2 ^ 16) + g * (2 ^ 8) + b
    return c
end

vim.api.nvim_create_autocmd("User", {
    desc = "Set Diffview Highlights",
    pattern = "DiffviewViewOpened",
    callback = function()
        local pct = 1 / 8

        local green = 0xb8bb26
        local aqua = 0x8ec07c
        local red = 0xfb4934
        local yellow = 0xfabd2f

        local ns = vim.api.nvim_get_hl_ns({})
        local hl_add = vim.api.nvim_get_hl(ns, { name = "DiffAdd", link = false }).fg
            or vim.api.nvim_get_hl(ns, { name = "String", link = false }).fg
            or green
        local hl_change = vim.api.nvim_get_hl(ns, { name = "DiffChange", link = false }).fg
            or vim.api.nvim_get_hl(ns, { name = "DiagnosticSignHint", link = false }).fg
            or aqua
        local hl_del = vim.api.nvim_get_hl(ns, { name = "DiffDelete", link = false }).fg
            or vim.api.nvim_get_hl(ns, { name = "DiagnosticSignError", link = false }).fg
            or red
        local hl_text = vim.api.nvim_get_hl(ns, { name = "DiffText", link = false }).fg
            or vim.api.nvim_get_hl(ns, { name = "DiagnosticSignWarn", link = false }).fg
            or yellow

        vim.api.nvim_set_hl(ns, "DiffAdd", { bg = darken(hl_add, pct) })
        vim.api.nvim_set_hl(ns, "DiffChange", { bg = darken(hl_change, pct) })
        vim.api.nvim_set_hl(ns, "DiffDelete", { bg = darken(hl_del, pct) })
        vim.api.nvim_set_hl(ns, "DiffviewDiffAddAsDelete", { bg = darken(hl_del, pct) })
        vim.api.nvim_set_hl(ns, "DiffText", { bg = darken(hl_text, pct) })
    end,
    group = "CustomHighlights",
})

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Disable hover for ruff",
    group = "LspKeymaps",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client ~= nil and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Set LSP Keymaps",
    group = "LspKeymaps",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client ~= nil and client.name == "rust-analyzer" then
            require("settings.keymaps").set_rust_keymaps(client, args.buf)
        else
            require("settings.keymaps").set_lsp_keymaps(client, args.buf)
        end
    end,
})
