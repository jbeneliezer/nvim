return {
    "lewis6991/gitsigns.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    event = "BufEnter",
    opts = {
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local default_opts = { noremap = true, silent = true, buffer = bufnr }
            local keymap = function(mode, lhs, rhs, opts, description)
                local local_opts = opts or default_opts
                local_opts["desc"] = description or "which_key_ignore"
                vim.keymap.set(mode, lhs, rhs, local_opts)
            end

            local next_hunk = function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    gs.nav_hunk("next")
                end
            end
            local prev_hunk = function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    gs.nav_hunk("prev")
                end
            end

            local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

            -- Navigation
            local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(next_hunk, prev_hunk)
            keymap("n", "]h", next_hunk_repeat)
            keymap("n", "[h", prev_hunk_repeat)

            -- Text object
            keymap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")

            -- Git
            keymap("n", "<leader>gb", require("telescope.builtin").git_branches, default_opts, "Find Branch")
            keymap("n", "<leader>gc", require("telescope.builtin").git_commits, default_opts, "Find Commit")
            keymap({ "n", "v" }, "<leader>gd", gs.diffthis, default_opts, "Diff")
            keymap("n", "<leader>gD", function()
                gs.diffthis("~")
            end, default_opts, "Diff with Head")
            keymap({ "n", "v" }, "<leader>gj", gs.next_hunk, default_opts, "Next Hunk")
            keymap({ "n", "v" }, "<leader>gk", gs.prev_hunk, default_opts, "Prev Hunk")
            keymap({ "n", "v" }, "<leader>gp", gs.preview_hunk, default_opts, "Preview Hunk")
            keymap({ "n", "v" }, "<leader>gr", gs.reset_hunk, default_opts, "Reset Hunk")
            keymap("n", "<leader>gR", gs.reset_buffer, default_opts, "Reset Buffer")
            keymap({ "n", "v" }, "<leader>gt", gs.blame_line, default_opts, "Blame")
            keymap({ "n", "v" }, "<leader>gs", gs.stage_hunk, default_opts, "Stage Hunk")
            keymap("n", "<leader>gS", gs.stage_buffer, default_opts, "Stage Buffer")
        end,
    },
}
