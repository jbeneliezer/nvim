local M = {}

local servers = {
	lua_ls = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--completion-style=bundled",
			"--enable-config",
		},
		single_file_support = true,
	},
	bashls = {},
	rust_analyzer = {},
	pylsp = {},
}

local signs = {
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn",  text = "" },
	{ name = "DiagnosticSignHint",  text = "" },
	{ name = "DiagnosticSignInfo",  text = "" },
}

local diag_config = {
	virtual_text = true,
	signs = {
		active = signs,
	},
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
}

local lsp_format = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			return client.name ~= "clangd"
		end,
		bufnr = bufnr,
	})
end

local on_attach = function(_, bufnr)
	local default_opts = { noremap = true, silent = true, buffer = bufnr }
	local keymap = function(mode, lhs, rhs, opts, description)
		local local_opts = opts
		local_opts["desc"] = description or "which_key_ignore"
		vim.keymap.set(mode, lhs, rhs, local_opts)
		-- end
	end

	keymap({ "n", "v" }, "gD", vim.lsp.buf.declaration, default_opts, "goto declaration")
	keymap({ "n", "v" }, "gd", vim.lsp.buf.definition, default_opts, "goto definition")
	keymap({ "n", "v" }, "gi", vim.lsp.buf.implementation, default_opts, "goto implementation")
	keymap({ "n", "v" }, "gr", vim.lsp.buf.references, default_opts, "goto references")
	keymap({ "n", "v" }, "[d", vim.diagnostic.goto_prev, default_opts, "previous diagnostic")
	keymap({ "n", "v" }, "]d", vim.diagnostic.goto_next, default_opts, "next diagnostic")
	keymap({ "n", "v" }, "gN", vim.diagnostic.goto_prev, default_opts, "previous diagnostic")
	keymap({ "n", "v" }, "gn", vim.diagnostic.goto_next, default_opts, "next diagnostic")

	local wk = require("which-key")
	wk.register({
		l = {
			name = "Lsp",
			i = { "<cmd>LspInfo<cr>", "Info" },
			-- r = { vim.lsp.buf.rename, "Rename" },
			r = { require("telescope.builtin").lsp_references, "References" },
			f = {
				function()
					lsp_format(bufnr)
				end,
				"Format",
			},
			t = { "<Plug>(toggle-lsp-diag-vtext)", "Toggle Vtext", noremap = false },
			u = { "<Plug>(toggle-lsp-diag-underline)", "Toggle Underline", noremap = false },
		},
	}, { prefix = "<leader>", mode = { "n", "v" }, buffer = bufnr })
end

M.mason = {
	"williamboman/mason.nvim",
	opts = {
		ui = { border = "rounded" },
	},
}

M.mason_lspconfig = {
	"williamboman/mason-lspconfig.nvim",
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
		})

		local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
		lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(lsp_capabilities)

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				require("lspconfig")[server_name].setup({
					capabilities = lsp_capabilities,
					on_attach = on_attach,
					settings = servers[server_name],
				})
			end,
		})
	end,
}

M.toggle_lsp = {
	"WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
	config = function()
		require("toggle_lsp_diagnostics").init(vim.diagnostic.config())
	end,
}

M.rust_tools = {
	"simrat39/rust-tools.nvim",
	opts = {
		server = {
			on_attach = on_attach,
		},
	},
}

M.lspconfig = {
	"neovim/nvim-lspconfig",
	config = function()
		for _, sign in ipairs(signs) do
			vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
		end

		vim.diagnostic.config(diag_config)

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
		})

		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			border = "rounded",
		})
	end,
}

return M
