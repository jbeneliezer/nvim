return {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local null_ls = require("null-ls")
        local clang_format_args = {
            "--style=file:"
            .. vim.fn.stdpath("config")
            .. (OsCurrent == OS.WINDOWS and "\\.clang-format" or "/.clang-format"),
        }
        null_ls.setup({
            debug = false,
            sources = {
                -- formatters
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.clang_format.with({
                    args = clang_format_args,
                }),
                -- diagnostics
                null_ls.builtins.diagnostics.cppcheck.with({
                    -- args = { "--enable=warning,performance,portability,information,unusedFunction", "--template=gcc", "$FILENAME" },
                    args = {
                        "--enable=warning,performance,portability,information",
                        "--std=c99",
                        "--template=gcc",
                        -- "--project=compile_commands.json",
                        "$FILENAME",
                    },
                }),
                -- code actions
                null_ls.builtins.code_actions.gitsigns,
            },
        })
    end,
}
