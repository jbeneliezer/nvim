local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

require("jb.lsp.lsp-installer")
require("jb.lsp.handlers").setup()
require("jb.lsp.null-ls")
