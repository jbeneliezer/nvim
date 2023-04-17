return {
    "karb94/neoscroll.nvim",
    config = function()
        require("neoscroll").setup({
            easing_function = "sine",
        })

        local mappings = {
            ["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "100" } },
            ["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } },
            -- ["K"] = { "scroll", { "-vim.wo.scroll", "true", "100" } },
            -- ["J"] = { "scroll", { "vim.wo.scroll", "true", "100" } },
            ["<C-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "450" } },
            ["<C-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "450" } },
            -- ['<C-y>'] = {'scroll', {'-0.10', 'false', '100'}},
            -- ['<C-e>'] = {'scroll', { '0.10', 'false', '100'}},
            ["zt"] = { "zt", { "250" } },
            ["zz"] = { "zz", { "250" } },
            ["zb"] = { "zb", { "250" } },
        }
        require("neoscroll.config").set_mappings(mappings)
    end,
}
