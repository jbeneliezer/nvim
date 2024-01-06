return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    -- config = function()
    -- 	require("ibl").setup()
    -- 	vim.cmd("hi IndentBlanklineContextStart guisp=#000000 gui=nocombine")
    -- end,
    opts = {
        scope = {
            show_start = false,
            show_end = false
        }
    }
}