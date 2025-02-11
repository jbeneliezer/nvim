return {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
        vim.g.molten_image_provider = "none"
        vim.g.molten_auto_image_popup = true
        vim.g.molten_auto_open_output = false
        vim.g.molten_output_win_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
        vim.g.molten_output_win_cover_gutter = false
        vim.g.molten_output_show_more = true
        vim.g.molten_output_win_max_height = 20
        vim.g.molten_enter_output_behavior = "open_and_enter"
        vim.g.molten_use_border_highlights = true
        vim.g.molten_virt_text_output = true
        vim.g.molten_virt_text_max_lines = 20
    end,
}
