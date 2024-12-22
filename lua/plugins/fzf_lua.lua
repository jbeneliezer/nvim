return {
    "ibhagwan/fzf-lua",
    enabled = function()
        return FZF_LUA
    end,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        { "junegunn/fzf", build = "./install --bin" },
    },
    config = function()
        require("fzf-lua").setup()
    end,
}