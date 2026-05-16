return {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        "gbrlsnchs/telescope-lsp-handlers.nvim",
        "debugloop/telescope-undo.nvim",
        "natecraddock/telescope-zf-native.nvim",
        "Marskey/telescope-sg",
    },
    config = function()
        local actions = require("telescope.actions")
        local open_with_trouble = function(bufnr)
            require("trouble.sources.telescope").open(bufnr)
        end
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = {
                    "nvim/.undo",
                    "%.svn$",
                    "%.git$",
                    "%.d$",
                    "%.o$",
                    "__pycache__",
                    "%.pyc$",
                    "%.egg%-info",
                    "%.?venv/.*[^%.p][^py][^yi]$",
                },
                prompt_prefix = " ",
                selection_caret = " ",
                path_display = { "truncate" },
                use_less = false,
                mappings = {
                    i = {
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-c>"] = actions.close,
                        ["<Down>"] = actions.move_selection_next,
                        ["<Up>"] = actions.move_selection_previous,
                        ["<CR>"] = actions.select_default,
                        ["<C-x>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,
                        ["<PageUp>"] = actions.results_scrolling_up,
                        ["<PageDown>"] = actions.results_scrolling_down,
                        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
                        ["<C-t>"] = open_with_trouble,
                        ["<C-h>"] = actions.move_to_top,
                        ["<C-l>"] = actions.move_to_bottom,
                    },
                    n = {
                        ["<esc>"] = actions.close,
                        ["q"] = actions.close,
                        ["<CR>"] = actions.select_default,
                        ["<C-x>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                        ["H"] = actions.move_to_top,
                        ["M"] = actions.move_to_middle,
                        ["L"] = actions.move_to_bottom,
                        ["<Down>"] = actions.move_selection_next,
                        ["<Up>"] = actions.move_selection_previous,
                        ["gg"] = actions.move_to_top,
                        ["G"] = actions.move_to_bottom,
                        ["K"] = actions.preview_scrolling_up,
                        ["J"] = actions.preview_scrolling_down,
                        ["<PageUp>"] = actions.results_scrolling_up,
                        ["<PageDown>"] = actions.results_scrolling_down,
                        ["?"] = actions.which_key,
                        ["<C-t>"] = open_with_trouble,
                    },
                },
            },
            extensions = {
                "ui-select",
                "lsp_handlers",
                "dap",
                undo = {
                    side_by_side = true,
                    layout_strategy = "vertical",
                    layout_config = {
                        preview_height = 0.8,
                    },
                },
                ["zf-native"] = {
                    file = {
                        enable = true,
                        highlight_results = true,
                        match_filename = true,
                        initial_sort = nil,
                        smart_case = true,
                    },
                    generic = {
                        enable = true,
                        highlight_results = true,
                        match_filename = false,
                        initial_sort = nil,
                        smart_case = true,
                    },
                },
                ast_grep = {
                    command = {
                        "sg",
                        "--json=stream",
                    },
                    grep_open_files = true,
                },
            },
        })
        require("telescope").load_extension("ui-select")
    end,
}
