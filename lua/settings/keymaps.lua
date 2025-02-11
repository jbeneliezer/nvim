local M = {}

local default_opts = { noremap = true, silent = true }
local keymap = function(mode, lhs, rhs, opts, description)
    local local_opts = opts or default_opts
    local_opts.desc = description or "which_key_ignore"
    vim.keymap.set(mode, lhs, rhs, local_opts)
end

local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
local repeatable_pair = ts_repeat_move.make_repeatable_move_pair
local repeatable = function(f)
    local fw, _ = repeatable_pair(f, function() end)
    return fw
end

local lsp_format = function(bufnr)
    vim.lsp.buf.format({
        async = true,
        bufnr = bufnr,
        filter = function(client)
            return client.name ~= "clangd"
        end,
    })
end

function M.set_normal_keymaps()
    local util = require("settings.util")
    local bind = util.bind
    local partial = util.partial

    keymap({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
    keymap({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

    keymap({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { noremap = true, silent = true, expr = true })

    -- This repeats the last query with always previous direction and to the start of the range.
    keymap({ "n", "x", "o" }, "<leader>0", partial(ts_repeat_move.repeat_last_move, { forward = false, start = true }))

    -- This repeats the last query with always next direction and to the end of the range.
    keymap({ "n", "x", "o" }, "<leader>$", function()
        ts_repeat_move.repeat_last_move({ forward = true, start = false })
    end)

    keymap({ "n", "v" }, "<c-n>", "J")
    keymap({ "n", "v" }, "J", "<c-d>zz")
    keymap({ "n", "v" }, "K", "<c-u>zz")

    keymap("n", "<leader>j", ":m .+1<cr>==")
    keymap("n", "<leader>k", ":m .-2<cr>==")
    keymap("v", "<leader>j", ":m '>+1<cr>gv=gv")
    keymap("v", "<leader>k", ":m '<-2<cr>gv=gv")

    keymap("n", "<leader>o", "<c-w>o", default_opts, "Fullscreen")
    keymap("n", "<leader>q", "<cmd>q<cr>", default_opts, "Quit")
    keymap("n", "<leader>w", "<cmd>w<cr>", default_opts, "Save")

    -- Resize with arrows
    keymap("n", "<c-Up>", "<cmd>resize -2<cr>")
    keymap("n", "<c-Down>", "<cmd>resize +2<cr>")
    keymap("n", "<c-Left>", "<cmd>vertical resize -2<cr>")
    keymap("n", "<c-Right>", "<cmd>vertical resize +2<cr>")

    keymap("n", "<c-ScrollWheelUp>", "<cmd>vertical resize -1<cr>")
    keymap("n", "<c-ScrollWheelDown>", "<cmd>vertical resize +1<cr>")

    -- Stay in indent mode
    keymap("v", "<", "<gv")
    keymap("v", ">", ">gv")
    keymap("v", "=", "=gv")

    -- Windows
    -- keymap("n", "<c-h>", "<c-w>h")
    keymap("n", "<c-j>", "<c-w>j")
    keymap("n", "<c-k>", "<c-w>k")
    -- keymap("n", "<c-l>", "<c-w>l")

    keymap("n", "<leader>c", "<cmd>BufferClose<cr>")

    local next_file_repeat, prev_file_repeat =
        repeatable_pair(partial(vim.cmd, "BufferNext"), partial(vim.cmd, "BufferPrevious"))
    local next_file_move_repeat, prev_file_move_repeat =
        repeatable_pair(partial(vim.cmd, "BufferMoveNext"), partial(vim.cmd, "BufferMovePrevious"))
    keymap("n", "L", next_file_repeat)
    keymap("n", "H", prev_file_repeat)
    keymap("n", "<leader>L", next_file_move_repeat)
    keymap("n", "<leader>H", prev_file_move_repeat)
    for i = 1, 9 do
        keymap({ "n", "v" }, "<leader>" .. i, "<cmd>BufferGoto " .. i .. "<cr>")
    end

    -- File Explorer
    keymap("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")
    -- keymap("n", "<leader>e", "<cmd>Lex 25<cr>", default_opts, "Explorer")

    -- Comment
    keymap("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", { noremap = false }, "Comment")
    keymap("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)gv", { noremap = false }, "Comment")

    -- Copilot
    -- keymap("n", "<leader>C", function()
    --     util.toggle_cmp_source("copilot")
    -- end, default_opts, "Toggle Copilot")

    -- Paste in visual mode
    keymap("v", "p", '"_dP')

    -- Build and Debug
    keymap("n", "M", util.build_command, default_opts, "Build Command")
    keymap("n", "C", util.clean_command, default_opts, "Clean Command")

    -- Toggleterm
    local TM = util.TM
    keymap({ "n", "v", "t" }, "<c-g>", function()
        TM.get().lazygit:toggle()
    end)
    keymap({ "n", "v", "t" }, "<c-l>", TM.next_term_or_win)
    keymap({ "n", "v", "t" }, "<c-h>", TM.prev_term_or_win)
    keymap({ "n", "v", "t" }, "<c-p>", TM.term_toggle)
    keymap({ "n", "v", "t" }, "<leader><c-p>", TM.ipy_term_toggle)
    keymap({ "n", "v", "t" }, "<c-_>", require("toggleterm").toggle_all)

    -- LF
    -- keymap({ "n", "v" }, "<c-e>", require("lf").start)

    -- Dap
    local dap = require("dap")
    local dapui = require("dapui")
    local next_bp_repeat, prev_bp_repeat =
        repeatable_pair(require("goto-breakpoints").next, require("goto-breakpoints").prev)

    keymap("n", "<leader>da", function()
        require("dapui").elements.watches.add(vim.fn.input("Expression: "))
    end, default_opts, "Add Watch")
    keymap("n", "<leader>db", require("telescope").extensions.dap.list_breakpoints, default_opts, "Breakpoints")
    keymap("n", "<leader>du", require("dapui").toggle, default_opts, "UI")
    keymap("n", "<leader>dt", dap.toggle_breakpoint, default_opts, "Breakpoint")
    keymap("n", "<leader>dc", repeatable(dap.continue), default_opts, "Continue")
    keymap("n", "<leader>dC", require("telescope").extensions.dap.commands, default_opts, "Commands")
    keymap("n", "<leader>dr", dap.run_last, default_opts, "Run Last")
    keymap("n", "<leader>dR", dap.repl.toggle, default_opts, "Repl")
    keymap("n", "<leader>bc", dap.clear_breakpoints, default_opts, "Clear Breakpoints")
    keymap("n", "<leader>bn", next_bp_repeat, default_opts, "Next Breakpoint")
    keymap("n", "<leader>bN", prev_bp_repeat, default_opts, "Previous Breakpoint")
    keymap("n", "<leader>b<leader>", require("goto-breakpoints").stopped, default_opts, "Current Stopped Line")
    keymap("n", "<leader>dB", partial(dapui.toggle, { 1, true }), default_opts, "Toggle Bottom Layout")
    keymap("n", "<leader>dL", partial(dapui.toggle, { 2, true }), default_opts, "Toggle Side Layout")
    local DM = util.DM
    keymap("n", "<leader>dl", DM.next_layout, default_opts, "Next Layout")
    keymap("n", "<leader>dh", DM.prev_layout, default_opts, "Prev Layout")
    keymap("n", "<leader>dd", DM.default_layout, default_opts, "Default Layout")
    keymap("n", "<leader>dD", DM.repl_layout, default_opts, "Repl Layout")

    -- Neotest
    local neotest = require("neotest")
    keymap("n", "<leader>nm", neotest.run.run, default_opts, "Run Test")
    keymap("n", "<leader>nM", partial(neotest.run.run, { strategy = "dap" }), default_opts, "Debug Test")
    keymap("n", "<leader>nf", partial(neotest.run.run, { vim.fn.expand("%") }), default_opts, "Run All Tests")
    keymap(
        "n",
        "<leader>nF",
        partial(neotest.run.run, { vim.fn.expand("%"), strategy = "dap" }),
        default_opts,
        "Debug All Tests"
    )
    keymap("n", "<leader>ns", neotest.summary.toggle, default_opts, "Test Summary")
    keymap("n", "<leader>np", neotest.run.stop, default_opts, "Stop Test")
    keymap("n", "<leader>na", neotest.run.attach, default_opts, "Attach To Test")

    -- Telescope
    local telescope_builtin = require("telescope.builtin")
    keymap("n", "<leader>fa", telescope_builtin.autocommands, default_opts, "Autocommands")
    keymap("n", "<leader>fc", telescope_builtin.commands, default_opts, "Commands")
    keymap("n", "<leader>ff", telescope_builtin.find_files, default_opts, "Files")
    keymap("n", "<leader>fr", telescope_builtin.oldfiles, default_opts, "Recent Files")
    keymap("n", "<leader>fC", telescope_builtin.command_history, default_opts, "Recent Commands")
    keymap("n", "<leader>fR", telescope_builtin.registers, default_opts, "Registers")
    keymap("n", "<leader>fg", telescope_builtin.live_grep, default_opts, "Live Grep")
    keymap("n", "<leader>fh", telescope_builtin.help_tags, default_opts, "Help Tags")
    keymap("n", "<leader>fH", telescope_builtin.highlights, default_opts, "Highlights")
    keymap("n", "<leader>fk", telescope_builtin.keymaps, default_opts, "Keymaps")
    -- keymap("n", "<leader>fp", require("telescope").extensions.projects.projects, default_opts, "Projects")
    keymap("n", "<leader>fu", require("telescope").extensions.undo.undo, default_opts, "Undo")
    keymap("n", "<leader>fs", require("auto-session.session-lens").search_session, default_opts, "Sessions")
    keymap("n", "<leader>fj", telescope_builtin.jumplist, default_opts, "Jump List")
    keymap("n", "<leader>f/", telescope_builtin.current_buffer_fuzzy_find, default_opts, "Buffer Grep")
    keymap("n", "<leader>f.", telescope_builtin.resume, default_opts, "Resume")

    -- Todo-comments
    keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", default_opts, "Todo")

    -- Neogen
    local neogen = require("neogen")
    keymap("n", "<leader>mf", partial(neogen.generate, { type = "func" }), default_opts, "Document Function")
    keymap("n", "<leader>mc", partial(neogen.generate, { type = "class" }), default_opts, "Document Class")
    keymap("n", "<leader>mt", partial(neogen.generate, { type = "type" }), default_opts, "Document Type")
    keymap("n", "<leader>mF", partial(neogen.generate, { type = "File" }), default_opts, "Document File")

    -- Trouble
    local trouble = require("trouble")
    keymap("n", "<leader>lt", partial(trouble.toggle, { mode = "diagnostics" }), default_opts, "Trouble Diagnostics")
    keymap(
        "n",
        "<leader>s",
        partial(trouble.toggle, { mode = "symbols", focus = true, win = { position = "left" } }),
        default_opts,
        "Trouble Symbols"
    )

    local next_trouble_repeat, prev_trouble_repeat = repeatable_pair(
        partial(trouble.next, { skip_groups = true, jump = true }),
        partial(trouble.prev, { skip_groups = true, jump = true })
    )

    keymap({ "n", "v" }, "<leader>tr", trouble.refresh, default_opts, "Refresh Trouble")
    keymap({ "n", "v" }, "]t", next_trouble_repeat, default_opts, "Next Trouble")
    keymap({ "n", "v" }, "[t", prev_trouble_repeat, default_opts, "Previous Trouble")
    keymap({ "n", "v" }, "g;", next_trouble_repeat, default_opts, "Next Trouble")
    keymap({ "n", "v" }, "g,", prev_trouble_repeat, default_opts, "Previous Trouble")
    keymap(
        { "n", "v" },
        "g0",
        partial(trouble.first, { skip_groups = true, jump = true }),
        default_opts,
        "First Trouble"
    )
    keymap({ "n", "v" }, "g$", partial(trouble.last, { skip_groups = true, jump = true }), default_opts, "Last Trouble")
end

function M.set_lsp_keymaps(_, bufnr)
    -- Navigation
    local partial = require("settings.util").partial
    local next_diag_repeat, prev_diag_repeat = repeatable_pair(vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
    local lsp_opts = { noremap = true, silent = true, buffer = bufnr }

    keymap({ "n", "v" }, "gD", vim.lsp.buf.declaration, lsp_opts, "Goto Declaration")
    keymap({ "n", "v" }, "gd", vim.lsp.buf.definition, lsp_opts, "Goto Definition")
    keymap({ "n", "v" }, "gi", vim.lsp.buf.implementation, lsp_opts, "Goto Implementation")
    keymap({ "n", "v" }, "gr", vim.lsp.buf.references, lsp_opts, "Goto References")
    keymap({ "n", "v" }, "]d", next_diag_repeat, lsp_opts, "Next Diagnostic")
    keymap({ "n", "v" }, "[d", prev_diag_repeat, lsp_opts, "Previous Diagnostic")
    keymap({ "n", "v" }, "gn", next_diag_repeat, lsp_opts, "Next Diagnostic")
    keymap({ "n", "v" }, "gN", prev_diag_repeat, lsp_opts, "Previous Diagnostic")
    keymap({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, lsp_opts, "Code Action")
    keymap({ "n", "v" }, "<leader>li", vim.diagnostic.open_float, lsp_opts, "Diagnostic Info")
    keymap({ "n", "v" }, "<leader>lI", "<cmd>LspInfo<cr>", lsp_opts, "Info")
    keymap({ "n", "v" }, "<leader>lr", require("telescope.builtin").lsp_references, lsp_opts, "References")
    keymap({ "n", "v" }, "<leader>lR", vim.lsp.buf.rename, lsp_opts, "Rename")
    keymap({ "n", "v" }, "<leader>lf", partial(lsp_format, bufnr), lsp_opts, "Format")
    keymap({ "n", "v" }, "<leader>ll", "<Plug>(toggle-lsp-diag)", { noremap = false }, "Toggle Diagnostics")
    keymap({ "n", "v" }, "<leader>lv", "<Plug>(toggle-lsp-diag-vtext)", { noremap = false }, "Toggle Vtext")
    keymap({ "n", "v" }, "<leader>lu", "<Plug>(toggle-lsp-diag-underline)", { noremap = false }, "Toggle Underline")
end

M.set_git_keymaps = function(bufnr)
    local partial = require("settings.util").partial
    local gs = require("gitsigns")
    local gs_opts = { noremap = true, silent = true, buffer = bufnr }

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

    -- Navigation
    local next_hunk_repeat, prev_hunk_repeat = repeatable_pair(next_hunk, prev_hunk)
    keymap("n", "]h", next_hunk_repeat)
    keymap("n", "[h", prev_hunk_repeat)

    -- Text object
    keymap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")

    -- Git
    keymap("n", "<leader>gb", require("telescope.builtin").git_branches, gs_opts, "Find Branch")
    keymap("n", "<leader>gc", require("telescope.builtin").git_commits, gs_opts, "Find Commit")
    keymap({ "n", "v" }, "<leader>gd", gs.diffthis, gs_opts, "Diff")
    keymap("n", "<leader>gD", partial(gs.diffthis, "~"), gs_opts, "Diff with Head")
    keymap({ "n", "v" }, "<leader>gj", next_hunk_repeat, gs_opts, "Next Hunk")
    keymap({ "n", "v" }, "<leader>gk", prev_hunk_repeat, gs_opts, "Prev Hunk")
    keymap({ "n", "v" }, "<leader>gp", gs.preview_hunk, gs_opts, "Preview Hunk")
    keymap({ "n", "v" }, "<leader>gr", gs.reset_hunk, gs_opts, "Reset Hunk")
    keymap("n", "<leader>gR", gs.reset_buffer, gs_opts, "Reset Buffer")
    keymap({ "n", "v" }, "<leader>gt", gs.toggle_current_line_blame, gs_opts, "Blame")
    keymap({ "n", "v" }, "<leader>gs", gs.stage_hunk, gs_opts, "Stage Hunk")
    keymap({ "n", "v" }, "<leader>gu", gs.undo_stage_hunk, gs_opts, "Undo Stage Hunk")
    keymap("n", "<leader>gS", gs.stage_buffer, gs_opts, "Stage Buffer")
end

function M.set_term_keymaps()
    local term_opts = { noremap = true, silent = true, buffer = 0 }
    keymap("t", "<esc>", "<c-\\><c-n>", term_opts)
end

function M.set_ipy_keymaps()
    local util = require("settings.util")
    local TM = util.TM
    keymap("v", "<leader>tl", TM.send_line, default_opts, "Send Line to IPython")
    keymap("v", "<leader>tL", TM.send_lines, default_opts, "Send Selected Lines to IPython")
    keymap("v", "<leader>ts", TM.send_selection, default_opts, "Send Selection to IPython")

    -- Molten
    keymap("n", "<leader>mI", ":MoltenInit<CR>", default_opts, "Initialize")
end

function M.set_molten_keymaps()
    local util = require("settings.util")
    local bind = util.bind
    local partial = util.partial

    keymap("n", "<leader>mQ", ":MoltenDeinit<CR>", default_opts, "De-init")
    keymap("n", "<leader>mq", ":MoltenInterrupt<CR>", default_opts, "Interrupt")
    keymap("n", "<leader>mi", ":MoltenInfo<CR>", default_opts, "Info")
    keymap("n", "<leader>me", ":MoltenEvaluateLine<CR>", default_opts, "Evaluate Line")
    keymap("n", "<leader>mr", ":MoltenReevaluateCell<CR>", default_opts, "Re-evaluate Cell")
    keymap("n", "<leader>ma", ":MoltenReevaluateAll<CR>", default_opts, "Re-evaluate All")
    keymap("n", "<leader>md", ":MoltenDelete<CR>", default_opts, "Delete Cell")
    keymap("n", "<leader>mR", ":MoltenRestart<CR>", default_opts, "Restart")
    keymap("v", "<leader>m", ":<C-u>MoltenEvaluateVisual<CR>gv", default_opts, "Evaluate Visual Selection")

    local next_cell_repeat, prev_cell_repeat =
        repeatable_pair(partial(vim.cmd, "MoltenNext"), partial(vim.cmd, "MoltenPrev"))
    keymap("n", "<leader>mn", next_cell_repeat, default_opts, "Next Cell")
    keymap("n", "<leader>mN", prev_cell_repeat, default_opts, "Previous Cell")

    local show_hide = util.Toggle.new(partial(vim.cmd, "MoltenShowOutput"), partial(vim.cmd, "MoltenHideOutput"))
    local auto_open = false
    local vtext = true
    keymap("n", "<leader>ms", bind(show_hide, "call"), default_opts, "Show/Hide Output")
    keymap("n", "<leader>mS", function()
        auto_open = not auto_open
        vim.fn.MoltenUpdateOption("molten_auto_open_output", auto_open)
        show_hide.value = auto_open
    end, default_opts, "Auto Open Output")
    keymap("n", "<leader>mv", function()
        vtext = not vtext
        vim.fn.MoltenUpdateOption("molten_virt_text_output", vtext)
    end, default_opts, "Virtual Text Output")
    keymap("n", "<leader>m<cr>", function()
        vim.cmd("noautocmd MoltenEnterOutput")
        show_hide.value = true
    end, default_opts, "Enter Output")
end

local dap_keymaps = {
    ["<leader>de"] = { { "n", "v" }, "<leader>de", require("dapui").eval, default_opts, "Evaluate" },
    ["<leader>dp"] = { "n", "<leader>dp", require("dap").pause, default_opts, "Pause" },
    ["<leader>dq"] = { "n", "<leader>dq", require("dap").terminate, default_opts, "Quit" },
    ["<leader>dsi"] = { "n", "<leader>dsi", repeatable(require("dap").step_into), default_opts, "Into" },
    ["<leader>dso"] = { "n", "<leader>dso", repeatable(require("dap").step_over), default_opts, "Over" },
    ["<leader>dsu"] = { "n", "<leader>dsu", repeatable(require("dap").step_out), default_opts, "Out" },
    ["<leader>d<leader>"] = {
        "n",
        "<leader>d<leader>",
        repeatable(require("dap").run_to_cursor),
        default_opts,
        "Run to Cursor",
    },
    ["<F5>"] = { "n", "<F5>", repeatable(require("dap").continue) },
    ["<F8>"] = { "n", "<F8>", repeatable(require("dap").step_over) },
    ["<F9>"] = { "n", "<F9>", repeatable(require("dap").step_into) },
    ["<F10>"] = { "n", "<F10>", repeatable(require("dap").step_out) },
}

M.set_dap_keymaps = function()
    for _, v in pairs(dap_keymaps) do
        keymap(unpack(v))
    end
end

M.del_dap_keymaps = function()
    for _, v in pairs(vim.api.nvim_get_keymap("n")) do
        for dk, _ in pairs(dap_keymaps) do
            if dk == v["lhs"]:gsub(" ", "<leader>") then
                vim.keymap.del("n", dk)
            end
        end
    end
    for _, v in pairs(vim.api.nvim_get_keymap("v")) do
        for dk, _ in pairs(dap_keymaps) do
            if dk == v["lhs"]:gsub(" ", "<leader>") then
                vim.keymap.del("v", dk)
            end
        end
    end
end

return M
