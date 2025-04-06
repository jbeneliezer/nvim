return {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
        require("auto-session").setup({
            auto_restore = true,
            auto_save = true,
            session_lens = {
                previewer = true,
                theme_conf = {
                    border = true,
                    layout_strategy = "horizontal",
                    sorting_strategy = "descending",
                    layout_config = {
                        height = 0.9,
                        preview_cutoff = 120,
                        prompt_position = "bottom",
                        width = 0.8,
                    },
                },
            },
        })
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,
}
