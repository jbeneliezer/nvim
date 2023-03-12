return {
	"jose-elias-alvarez/null-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.autopep8,
				null_ls.builtins.formatting.rustfmt,
				null_ls.builtins.formatting.clang_format.with({
					extra_args = { "--style={BasedOnStyle: llvm, IndentWidth: 4" },
				}),
				null_ls.builtins.diagnostics.flake8,
				null_ls.builtins.diagnostics.cppcheck.with({
					extra_args = { "--enable=warning,performance,portability", "$FILENAME" },
				}),
			},
		})
	end,
}