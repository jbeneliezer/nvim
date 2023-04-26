return {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    keys = {
        { "<leader>vs", "<cmd>:VenvSelect<cr>", desc = "VenvSelect" },
        { "<leader>vc", "<cmd>:VenvSelectCached<cr", desc = "VenvSelectCached" },
    },
    config = function()
        require("venv-selector").setup({
            dap_enabled = true,
        })
        local ok, wk = pcall(require, "which-key")
        if ok then
            wk.register({ v = { name = "Venv" } }, { prefix = "<leader>" })
        end
    end,
}
