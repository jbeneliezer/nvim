return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
    },
    opts = {
        controls = {
            element = "console",
            enabled = true,
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = "",
            },
        },
        layouts = {
            {
                elements = {
                    { id = "scopes", size = 0.34 },
                    { id = "breakpoints", size = 0.33 },
                    { id = "watches", size = 0.33 },
                },
                size = 12,
                position = "bottom",
            },
            {
                elements = {
                    { id = "console", size = 0.95 },
                },
                size = 85,
                position = "right",
            },
        },
    },
}