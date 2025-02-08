local function get_python()
    local venv = vim.fn.getenv("VIRTUAL_ENV")
    if venv ~= vim.NIL then
        if OsCurrent == Os.WINDOWS and vim.fn.executable(venv .. "/Scripts/python") then
            return venv .. "/Scripts/python"
        elseif OsCurrent == Os.LINUX and vim.fn.executable(venv .. "/bin/python") then
            return venv .. "/bin/python"
        else
            return "python"
        end
    else
        return "python"
    end
end

return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        { "nvim-neotest/neotest-python", lazy = false },
    },
    ft = "py",
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-python")({
                    dap = {
                        justMyCode = false,
                        console = "integratedTerminal",
                    },
                    args = { "--log-level", "DEBUG", "--quiet" },
                    runner = "pytest",
                    python = get_python,
                }),
            },
        })
    end,
}
