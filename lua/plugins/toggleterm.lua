return {
    "akinsho/toggleterm.nvim",
    event = "VimEnter",
    opts = {
        open_mapping = "<c-\\>",
        direction = "tab",
        autochdir = true,
        shell = function()
            return OsCurrent == OS.WINDOWS and "powershell -nologo" or vim.o.shell
        end,
        winbar = {
            enabled = true,
            name_formatter = function(term)
                return term.display_name .. " "
            end,
        },
    },
}