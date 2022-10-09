return {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
			format = {
				enable = true,
				defaultConfig = {
					indent_style = "tab",
					indent_size = "2",
				},
			},
		},
	},
}
