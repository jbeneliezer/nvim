return {
    "rmagatti/auto-session",
    config = function()
        require("auto-session").setup({
            auto_save_enabled = true,
            auto_restore_enabled = true,
            session_lens = {
                theme_conf = { border = true },
                previewer = true,
            },
        })
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,
}