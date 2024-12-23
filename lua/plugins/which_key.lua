return {
    "folke/which-key.nvim",
    event = "BufEnter",
    opts = {
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
            { "<leader>b",  group = "Breakpoints" },
            { "<leader>d",  group = "Dap" },
            { "<leader>ds", group = "Step" },
            { "<leader>f",  group = "Telescope" },
            { "<leader>g",  group = "Git" },
            { "<leader>l",  group = "Lsp" },
            { "<leader>m",  group = "Neogen" },
            { "<leader>n",  group = "Neotest" },
            { "<leader>t",  group = "ToggleTerm" },
            { "<leader>f_",  group = "Fzf-Lua" },
        },
        icons = { mappings = false },
    },
}