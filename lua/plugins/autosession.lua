return {
    "rmagatti/auto-session",
    event = "VimEnter",
    config = function()
        require("auto-session").setup({
            auto_restore = true,
            auto_save = true,
            session_lens = {
                previewer = true,
                theme_conf = {
                    border = true,
                },
            },
        })
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,
}
