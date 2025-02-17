return {
    "folke/which-key.nvim",
    event = "BufEnter",
    opts = {
        delay = 0,
        filter = function(mapping)
            return mapping.desc and mapping.desc ~= ""
        end,
        plugins = {
            presets = {
                operators = false,
                text_objects = false,
                g = false,
            },
        },
        win = {
            border = "rounded",
        },
        spec = {
            { "<leader>b", group = "Breakpoints" },
            { "<leader>d", group = "Dap" },
            { "<leader>ds", group = "Step" },
            { "<leader>f", group = "Telescope" },
            { "<leader>g", group = "Git" },
            { "<leader>l", group = "Lsp" },
            { "<leader>m", group = "Molten/Neogen" },
            { "<leader>n", group = "Neotest" },
            { "<leader>t", group = "Trouble" },
        },
        icons = { mappings = false },
        sort = { "order", "group", "alphanum", "mod" },
    },
}
