return {
    "folke/which-key.nvim",
    event = "BufEnter",
    opts = {
        delay = 0,
        filter = function(mapping)
            return mapping.desc and mapping.desc ~= ""
        end,
        defer = function(ctx)
            if vim.list_contains({ "c", "d", "y" }, ctx.operator) then
                return true
            end
            return vim.list_contains({ "v", "V", "<C-V>", "x", "o" }, ctx.mode)
        end,
        plugins = {
            presets = {
                operators = false,
                motions = false,
                g = false,
            },
        },
        win = {
            border = "rounded",
        },
        keys = { scroll_down = "<c-j>", scroll_up = "<c-k>" },
        spec = {
            { "<leader>b",  group = "Breakpoints" },
            { "<leader>d",  group = "Dap" },
            { "<leader>ds", group = "Step" },
            { "<leader>f",  group = "Telescope" },
            { "<leader>g",  group = "Git" },
            { "<leader>l",  group = "Lsp" },
            { "<leader>m",  group = "Neogen" },
            { "<leader>n",  group = "Neotest" },
            { "<leader>t",  group = "Trouble" },
        },
        icons = { mappings = false },
        sort = { "order", "group", "alphanum", "mod" },
    },
}