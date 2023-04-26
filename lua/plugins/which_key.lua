return {
    "folke/which-key.nvim",
    config = function()
        require("which-key").setup({
            plugins = {
                presets = {
                    operators = false,
                    text_objects = false,
                    g = false,
                },
            },
            window = {
                border = "rounded",
            },
        })

        require("which-key").register({
            d = { name = "Dap" },
            f = { name = "Telescope" },
            g = { name = "Git" },
        }, { prefix = "<leader>" })
    end,
}
