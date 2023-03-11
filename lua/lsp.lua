local M = {}


local lsp_highlight_document = function(client)
	-- Set autocommands conditional on server_capabilities
	if client.server_capabilities.document_highlight then
		local highlight_document = vim.api.nvim_create_augroup("HighlightDocument", { clear = true })
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = 0,
			callback = function()
				vim.lsp.buf.document_highlight()
			end,
			group = highlight_document,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer = 0,
			callback = function()
				vim.lsp.buf.clear_references()
			end,
			group = highlight_document,
		})
	end
end


local lsp_keymaps = function(bufnr)
	local default_opts = { noremap = true, silent = true, buffer = bufnr }
	local keymap = function(mode, lhs, rhs, opts, description)
		local local_opts = opts
		local_opts["desc"] = description or "which_key_ignore"
		vim.keymap.set(mode, lhs, rhs, local_opts)
		-- end
	end
	keymap("n", "gD", vim.lsp.buf.declaration, default_opts, "goto declaration")
	keymap("n", "gd", vim.lsp.buf.definition, default_opts, "goto definition")
	keymap("n", "gi", vim.lsp.buf.implementation, default_opts, "goto implementation")
	keymap("n", "<leader>lr", vim.lsp.buf.rename, default_opts, "rename")
	keymap("n", "gr", vim.lsp.buf.references, default_opts, "goto references")
	-- keymap("n", "gl", vim.diagnostic.default_open_float, default_opts)
	keymap("n", "<leader>lf", function() vim.lsp.buf.format { async = true } end, default_opts, "format")
	keymap("n", "[d", vim.diagnostic.goto_prev, default_opts, "previous diagnostic")
	keymap("n", "]d", vim.diagnostic.goto_next, default_opts, "next diagnostic")
	keymap("n", "gN", vim.diagnostic.goto_prev, default_opts, "previous diagnostic")
	keymap("n", "gn", vim.diagnostic.goto_next, default_opts, "next diagnostic")
	vim.keymap.set("n", "<leader>lt", "<Plug>(toggle-lsp-diag-vtext)",
	{ noremap = false, silent = true, buffer = bufnr, desc = "toggle vtext" })
	vim.keymap.set("n", "<leader>lu", "<Plug>(toggle-lsp-diag-underline)",
	{ noremap = false, silent = true, buffer = bufnr, desc = "toggle underline" })
	-- keymap("n", "<leader>lq", vim.diagnostic.setloclist, opts, )
end


local on_attach = function(client, bufnr)
	lsp_keymaps(bufnr)
	lsp_highlight_document(client)
end


local apply_settings = function()
	local lspconfig = require("lspconfig")
	lspconfig["lua_ls"].setup({
		on_attach = on_attach,
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = 'LuaJIT',
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { 'vim' },
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
	})
	lspconfig["clangd"].setup({
		on_attach = on_attach,
	})
	lspconfig["bashls"].setup({
		on_attach = on_attach,
	})
	lspconfig["rust_analyzer"].setup({
		on_attach = on_attach,
	})
end


M.setup = function()
	-- local lspconfig = require("lspconfig")
	-- local lsp_defaults = lspconfig.util.default_config

	-- lsp_defaults.capabilites = vim.tbl_deep_extend(
	-- 	"force",
	-- 	lsp_defaults.capabilites,
	-- 	require("cmp_nvim_lsp").default_capabilities()
	-- )
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn",  text = "" },
		{ name = "DiagnosticSignHint",  text = "" },
		{ name = "DiagnosticSignInfo",  text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		virtual_text = true,
		signs = {
			active = signs,
		},
		update_in_insert = true,
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

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})

	apply_settings()
end


return M
