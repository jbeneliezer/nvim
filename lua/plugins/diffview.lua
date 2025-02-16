return {
    "sindrets/diffview.nvim",
    event = "BufEnter",
    config = function()
        local util = require("settings.util")
        local actions = util.LZ.export_call("diffview.actions")
        local next_file, prev_file = util.repeatable_pair(actions.select_next_entry, actions.select_prev_entry)
        local next_conflict, prev_conflict = util.repeatable_pair(actions.next_conflict, actions.prev_conflict)
        local cc = actions.conflict_choose
        local cca = actions.conflict_choose_all

        local diffview_keymaps = {
            disable_defaults = true,
            view = {
                { "n",               "<leader>J",  next_file,              { desc = "Next File" } },
                { "n",               "<tab>",      next_file,              { desc = "Next File" } },
                { "n",               "<leader>K",  prev_file,              { desc = "Previous File" } },
                { "n",               "<s-tab>",    prev_file,              { desc = "Previous File" } },
                { "n",               "<leader>ge", actions.goto_file_edit, { desc = "Edit File" } },
                { "n",               "<leader>e",  actions.toggle_files,   { desc = "Toggle File Panel" } },
                { "n",               "gL",         actions.cycle_layout,   { desc = "Cycle Layout" } },
                { "n",               "<leader>j",  next_conflict,          { desc = "Previous Conflict" } },
                { "n",               "[x",         next_conflict,          { desc = "Previous Conflict" } },
                { "n",               "<leader>k",  prev_conflict,          { desc = "Next Conflict" } },
                { "n",               "]x",         prev_conflict,          { desc = "Next Conflict" } },
                { { "n", "v", "x" }, "<leader>o",  cc("ours"),             { desc = "Choose OURS" } },
                { { "n", "v", "x" }, "<leader>t",  cc("theirs"),           { desc = "Choose THEIRS" } },
                { { "n", "v", "x" }, "<leader>b",  cc("base"),             { desc = "Choose BASE" } },
                { { "n", "v", "x" }, "<leader>a",  cc("all"),              { desc = "Choose ALL" } },
                { { "n", "v", "x" }, "<leader>n",  cc("none"),             { desc = "Choose NONE" } },
                { { "n", "v", "x" }, "<leader>O",  cca("ours"),            { desc = "Choose OURS (File)" } },
                { { "n", "v", "x" }, "<leader>T",  cca("theirs"),          { desc = "Choose THEIRS (File)" } },
                { { "n", "v", "x" }, "<leader>B",  cca("base"),            { desc = "Choose BASE (File)" } },
                { { "n", "v", "x" }, "<leader>A",  cca("all"),             { desc = "Choose ALL (File)" } },
                { { "n", "v", "x" }, "<leader>N",  cca("none"),            { desc = "Choose NONE (File)" } },
            },
            diff1 = {
                -- Mappings in single window diff layouts
                { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Help" } },
            },
            diff2 = {
                -- Mappings in 2-way diff layouts
                { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Help" } },
            },
            diff3 = {
                -- Mappings in 3-way diff layouts
                { { "n", "v", "x" }, "<leader>o", actions.diffget("ours"),           { desc = "Choose OURS" } },
                { { "n", "v", "x" }, "<leader>t", actions.diffget("theirs"),         { desc = "Choose THEIRS" } },
                { "n",               "g?",        actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
            },
            diff4 = {
                -- Mappings in 4-way diff layouts
                { { "n", "v", "x" }, "<leader>o", actions.diffget("ours"),           { desc = "Choose OURS" } },
                { { "n", "v", "x" }, "<leader>t", actions.diffget("theirs"),         { desc = "Choose THEIRS" } },
                { { "n", "v", "x" }, "<leader>b", actions.diffget("base"),           { desc = "Choose BASE" } },
                { "n",               "g?",        actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
            },
            file_panel = {
                { "n",               "j",             next_file,                   { desc = "Next File" } },
                { "n",               "<down>",        next_file,                   { desc = "Next File" } },
                { "n",               "<tab>",         next_file,                   { desc = "Next File" } },
                { "n",               "k",             prev_file,                   { desc = "Previous File" } },
                { "n",               "<up>",          prev_file,                   { desc = "Previous File" } },
                { "n",               "<s-tab>",       prev_file,                   { desc = "Previous File" } },
                { "n",               "<cr>",          actions.select_entry,        { desc = "Open" } },
                { "n",               "<2-LeftMouse>", actions.select_entry,        { desc = "Open" } },
                { "n",               "-",             actions.toggle_stage_entry,  { desc = "Toggle Stage" } },
                { "n",               "s",             actions.toggle_stage_entry,  { desc = "Toggle Stage" } },
                { "n",               "S",             actions.stage_all,           { desc = "Stage All" } },
                { "n",               "U",             actions.unstage_all,         { desc = "Unstage All" } },
                { "n",               "X",             actions.restore_entry,       { desc = "Restore" } },
                { "n",               "L",             actions.open_commit_log,     { desc = "Show Log" } },
                { "n",               "zo",            actions.open_fold,           { desc = "Expand Fold" } },
                { "n",               "h",             actions.close_fold,          { desc = "Collapse Fold" } },
                { "n",               "zc",            actions.close_fold,          { desc = "Collapse Fold" } },
                { "n",               "za",            actions.toggle_fold,         { desc = "Toggle fold" } },
                { "n",               "zR",            actions.open_all_folds,      { desc = "Expand All folds" } },
                { "n",               "zM",            actions.close_all_folds,     { desc = "Collapse All folds" } },
                { "n",               "<c-b>",         actions.scroll_view(-0.25),  { desc = "Scroll Up" } },
                { "n",               "<c-f>",         actions.scroll_view(0.25),   { desc = "Scroll Down" } },
                { "n",               "ge",            actions.goto_file_edit,      { desc = "Edit File" } },
                { "n",               "i",             actions.listing_style,       { desc = "Toggle List/Tree" } },
                { "n",               "f",             actions.toggle_flatten_dirs, { desc = "Flatten" } },
                { "n",               "R",             actions.refresh_files,       { desc = "Refresh" } },
                { "n",               "<leader>e",     actions.toggle_files,        { desc = "Toggle File Panel" } },
                { "n",               "gL",            actions.cycle_layout,        { desc = "Cycle Layout" } },
                { "n",               "<leader>j",     next_conflict,               { desc = "Next Conflict" } },
                { "n",               "]x",            next_conflict,               { desc = "Next Conflict" } },
                { "n",               "<leader>k",     prev_conflict,               { desc = "Previous Conflict" } },
                { "n",               "[x",            prev_conflict,               { desc = "Previous Conflict" } },
                { "n",               "g?",            actions.help("file_panel"),  { desc = "Open the help panel" } },
                { { "n", "v", "x" }, "<leader>O",     cca("ours"),                 { desc = "Choose OURS (File)" } },
                { { "n", "v", "x" }, "<leader>T",     cca("theirs"),               { desc = "Choose THEIRS (File)" } },
                { { "n", "v", "x" }, "<leader>B",     cca("base"),                 { desc = "Choose BASE (File)" } },
                { { "n", "v", "x" }, "<leader>A",     cca("all"),                  { desc = "Choose ALL (File)" } },
                { { "n", "v", "x" }, "<leader>N",     cca("none"),                 { desc = "Choose NONE (File)" } },
            },
            file_history_panel = {
                { "n", "g!",            actions.options,                    { desc = "Options" } },
                { "n", "<C-A-d>",       actions.open_in_diffview,           { desc = "Open" } },
                { "n", "y",             actions.copy_hash,                  { desc = "Copy Commit Hash" } },
                { "n", "L",             actions.open_commit_log,            { desc = "Show Log" } },
                { "n", "X",             actions.restore_entry,              { desc = "Restore File" } },
                { "n", "zo",            actions.open_fold,                  { desc = "Expand Fold" } },
                { "n", "zc",            actions.close_fold,                 { desc = "Collapse Fold" } },
                { "n", "h",             actions.close_fold,                 { desc = "Collapse Fold" } },
                { "n", "za",            actions.toggle_fold,                { desc = "Toggle Fold" } },
                { "n", "zR",            actions.open_all_folds,             { desc = "Expand All Folds" } },
                { "n", "zM",            actions.close_all_folds,            { desc = "Collapse All Folds" } },
                { "n", "j",             next_file,                          { desc = "Next File" } },
                { "n", "<down>",        next_file,                          { desc = "Next File" } },
                { "n", "<leader>J",     next_file,                          { desc = "Next File" } },
                { "n", "<tab>",         next_file,                          { desc = "Next File" } },
                { "n", "k",             prev_file,                          { desc = "Previous File" } },
                { "n", "<up>",          prev_file,                          { desc = "Previous File" } },
                { "n", "<leader>K",     prev_file,                          { desc = "Previous File" } },
                { "n", "<s-tab>",       prev_file,                          { desc = "Previous File" } },
                { "n", "<cr>",          actions.select_entry,               { desc = "Open" } },
                { "n", "<2-LeftMouse>", actions.select_entry,               { desc = "Open" } },
                { "n", "<c-b>",         actions.scroll_view(-0.25),         { desc = "Scroll Up" } },
                { "n", "<c-f>",         actions.scroll_view(0.25),          { desc = "Scroll Down" } },
                { "n", "ge",            actions.goto_file_edit,             { desc = "Edit File" } },
                { "n", "<leader>e",     actions.toggle_files,               { desc = "Toggle File Panel" } },
                { "n", "gL",            actions.cycle_layout,               { desc = "Cycle Layout" } },
                { "n", "g?",            actions.help("file_history_panel"), { desc = "Help" } },
            },
            option_panel = {
                { "n", "<tab>", actions.select_entry,         { desc = "Change Option" } },
                { "n", "q",     actions.close,                { desc = "Close Panel" } },
                { "n", "g?",    actions.help("option_panel"), { desc = "Help" } },
            },
            help_panel = {
                { "n", "q",     actions.close, { desc = "Close Help" } },
                { "n", "<esc>", actions.close, { desc = "Close Help" } },
            },
        }

        require("diffview").setup({
            diff_binaries = true,
            enhanced_diff_hl = true,
            git_cmd = { "git" },
            keymaps = diffview_keymaps,
        })
    end,
}
