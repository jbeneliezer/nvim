return {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            debug = false,
            sources = {
                -- formatters
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.black.with({ extra_args = { "--line-length", "120" } }),
                null_ls.builtins.formatting.isort.with({ extra_args = { "--line-length", "120", "--multi-line", "3" } }),
                null_ls.builtins.formatting.clang_format.with({
                    -- extra_args = {
                    --     "--style={BasedOnStyle: llvm, IndentWidth: 4, AccessModifierOffset: -4, AllowShortIfStatementsOnASingleLine: true, AllowShortLoopsOnASingleLine: true, AllowShortCaseLabelsOnASingleLine: true, BinPackArguments: false, BinPackParametersStyle: OnePerLine, BreakBeforeBinaryOperators: NonAssignment}",
                    -- },
                }),
                -- diagnostics
                null_ls.builtins.diagnostics.cppcheck.with({
                    extra_args = { "--enable=warning,performance,portability", "$FILENAME" },
                }),
                -- null_ls.builtins.diagnostics.ruff.with({
                -- 	extra_args = { "--line-length", "120", "--ignore", "F403", "--ignore", "F405" },
                -- }),
                -- code actions
                null_ls.builtins.code_actions.gitsigns,
            },
            -- on_attach = function(client, bufnr)
            -- if client.supports_method("textDocument/formatting") then
            -- vim.api.nvim_create_autocmd("BufWritePre", {
            -- 	buffer = bufnr,
            -- 	callback = function()
            -- 		vim.lsp.buf.format({ bufnr = bufnr })
            -- 	end,
            -- })
            -- end
            -- end,
        })
    end,
}
