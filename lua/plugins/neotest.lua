--- Finds the right python interpreter for the DAP configuration.
--- @return string
local function get_python()
    local venv = vim.fn.getenv("VIRTUAL_ENV")
    if venv ~= vim.NIL then
        local p = venv .. (OsCurrent == OS.WINDOWS and "\\Scripts\\python.exe" or "/bin/python")
        if vim.fn.executable(p) then
            return p
        elseif vim.fn.executable("python3") then
            return "python3"
        else
            return "python"
        end
    elseif vim.fn.executable("python3") then
        return "python3"
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
        "nvim-neotest/neotest-python",
        "rouge8/neotest-rust",
    },
    ft = { "python", "rust" },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-python")({
                    dap = {
                        justMyCode = false,
                        console = "integratedTerminal",
                    },
                    args = { "--log-level", "DEBUG", "--quiet", "--capture", "no" },
                    runner = "pytest",
                    python = get_python,
                }),
                require("neotest-rust")({ args = { "--no-capture" }, dap_adapter = "lldb" }),
            },
            discovery = {
                enabled = false,
                concurrent = 1,
            }
        })
    end,
}
