local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote" } }),
		formatting.black.with({ extra_args = { "--fast" } }),
		-- formatting.yapf,

		formatting.stylua,
		formatting.rustfmt,
		-- formatting.uncrustify,
		--[[ formatting.astyle.with({ extra_args = { "--indent=force-tab=4" } }), ]]

		diagnostics.flake8,
		diagnostics.cppcheck.with({
			extra_args = { "--enable=warning,style,performance,portability", "--template=gcc", "$FILENAME" },
		}),
		--[[ diagnostics.gccdiag.with({ ]]
		--[[ 	extra_args = { "--default-args", "-S -x $FILEEXT", "-i", "-fdiagnostics-color", "--", "$FILENAME" }, ]]
		--[[ }), ]]
	},
})
