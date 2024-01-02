return {
	"jose-elias-alvarez/null-ls.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			debug = false,
			sources = {
				null_ls.builtins.formatting.stylua,
				-- null_ls.builtins.formatting.rustfmt,
                null_ls.builtins.formatting.isort,
				null_ls.builtins.formatting.black.with({
					extra_args = { "--line-length", "120" },
				}),
				-- null_ls.builtins.formatting.docformatter.with({
				-- 	extra_args = { "-i", "-s", "sphinx", "--black" },
				-- }),
				null_ls.builtins.formatting.clang_format.with({
					extra_args = { "--style={BasedOnStyle: llvm, IndentWidth: 4, AccessModifierOffset: -4}" },
				}),
				null_ls.builtins.diagnostics.ruff.with({
					extra_args = { "--line-length", "120", "--ignore", "F403", "--ignore", "F405" },
				}),
				null_ls.builtins.diagnostics.cppcheck.with({
					extra_args = { "--enable=warning,performance,portability", "$FILENAME" },
				}),
			},
			on_attach = function(client, bufnr)
				-- if client.supports_method("textDocument/formatting") then
				-- vim.api.nvim_create_autocmd("BufWritePre", {
				-- 	buffer = bufnr,
				-- 	callback = function()
				-- 		vim.lsp.buf.format({ bufnr = bufnr })
				-- 	end,
				-- })
				-- end
			end,
		})
	end,
}