local util = require("settings.util")
local partial = util.partial
local ts_repeat_move = util.ts_repeat_move
local repeatable_pair = util.repeatable_pair
local repeatable = util.repeatable
local LZ = util.LZ

local default_opts = { noremap = true, silent = true }
local keymap = function(mode, lhs, rhs, opts, description)
    local local_opts = opts or default_opts
    local_opts.desc = description or ""
    vim.keymap.set(mode, lhs, rhs, local_opts)
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

local M = {}

function M.set_basic_keymaps()
    keymap({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
    keymap({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

    keymap({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "<leader>0", partial(ts_repeat_move.repeat_last_move, { forward = false, start = true }))
    keymap({ "n", "x", "o" }, "<leader>$", partial(ts_repeat_move.repeat_last_move, { forward = true, start = false }))

    keymap({ "n", "v" }, "<c-n>", "J")
    keymap({ "n", "v" }, "J", "<c-d>zz")
    keymap({ "n", "v" }, "K", "<c-u>zz")

    keymap("n", "<leader>j", ":m .+1<cr>==")
    keymap("n", "<leader>k", ":m .-2<cr>==")
    keymap("v", "<leader>j", ":m '>+1<cr>gv=gv")
    keymap("v", "<leader>k", ":m '<-2<cr>gv=gv")

    keymap("n", "<leader>o", "<c-w>o", default_opts, "Fullscreen")
    keymap("n", "<leader>q", "<cmd>q<cr>", default_opts, "Quit")
    keymap("n", "<leader>z", "<cmd>tabclose<cr>", default_opts, "Close Tab")
    keymap("n", "<leader>w", "<cmd>w<cr>", default_opts, "Save")

    -- Resize with arrows
    keymap("n", "<c-Up>", "<cmd>resize -2<cr>")
    keymap("n", "<c-Down>", "<cmd>resize +2<cr>")
    keymap("n", "<c-Left>", "<cmd>vertical resize -2<cr>")
    keymap("n", "<c-Right>", "<cmd>vertical resize +2<cr>")

    keymap("n", "<c-ScrollWheelUp>", "<cmd>vertical resize -1<cr>")
    keymap("n", "<c-ScrollWheelDown>", "<cmd>vertical resize +1<cr>")

    -- Stay in visual mode
    keymap("v", "<", "<gv")
    keymap("v", ">", ">gv")
    keymap("v", "=", "=gv")

    -- Windows
    -- keymap("n", "<c-h>", "<c-w>h")
    keymap("n", "<c-j>", "<c-w>j")
    keymap("n", "<c-k>", "<c-w>k")
    -- keymap("n", "<c-l>", "<c-w>l")

    keymap("n", "<leader>c", "<cmd>BufferClose<cr>")

    local next_file, prev_file = repeatable_pair(partial(vim.cmd, "BufferNext"), partial(vim.cmd, "BufferPrevious"))
    local next_file_move, prev_file_move =
        repeatable_pair(partial(vim.cmd, "BufferMoveNext"), partial(vim.cmd, "BufferMovePrevious"))
    keymap("n", "L", next_file)
    keymap("n", "H", prev_file)
    keymap("n", "<leader>L", next_file_move)
    keymap("n", "<leader>H", prev_file_move)
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
    keymap({ "n", "v", "t" }, "<c-_>", LZ.export_call("toggleterm").toggle_all)

    -- LF
    -- keymap({ "n", "v" }, "<c-e>", require("lf").start)

    -- Dap
    local dap = LZ.export_call("dap")
    local telescope_dap = LZ.export_call("telescope", 3).extensions.dap
    local dap_repl = LZ.export_call("dap.repl")
    local dapui = LZ.export_call("dapui")
    local dapui_watches = LZ.export_call("dapui.elements.watches")
    local goto_breakpoints = LZ.export_call("goto-breakpoints")
    local next_bp, prev_bp = repeatable_pair(goto_breakpoints.next, goto_breakpoints.prev)

    keymap("n", "<leader>da", function()
        dapui_watches.add(vim.fn.input("Expression: "))
    end, default_opts, "Add Watch")
    keymap("n", "<leader>db", telescope_dap.list_breakpoints, default_opts, "Breakpoints")
    keymap("n", "<leader>du", dapui.toggle, default_opts, "UI")
    keymap("n", "<leader>dt", dap.toggle_breakpoint, default_opts, "Breakpoint")
    keymap("n", "<leader>dc", repeatable(dap.continue), default_opts, "Continue")
    keymap("n", "<leader>dC", telescope_dap.commands, default_opts, "Commands")
    keymap("n", "<leader>dr", dap.run_last, default_opts, "Run Last")
    keymap("n", "<leader>dR", dap_repl.toggle, default_opts, "Repl")
    keymap("n", "<leader>bc", dap.clear_breakpoints, default_opts, "Clear Breakpoints")
    keymap("n", "<leader>bn", next_bp, default_opts, "Next Breakpoint")
    keymap("n", "<leader>bN", prev_bp, default_opts, "Previous Breakpoint")
    keymap("n", "<leader>b<leader>", goto_breakpoints.stopped, default_opts, "Current Stopped Line")
    keymap("n", "<leader>dB", partial(dapui.toggle, { 1, true }), default_opts, "Toggle Bottom Layout")
    keymap("n", "<leader>dL", partial(dapui.toggle, { 2, true }), default_opts, "Toggle Side Layout")

    local DM = util.DM
    keymap("n", "<leader>dl", DM.next_layout, default_opts, "Next Layout")
    keymap("n", "<leader>dh", DM.prev_layout, default_opts, "Prev Layout")
    keymap("n", "<leader>dd", DM.default_layout, default_opts, "Default Layout")
    keymap("n", "<leader>dD", DM.repl_layout, default_opts, "Repl Layout")

    -- Telescope
    local telescope_builtin = LZ.export_call("telescope.builtin")
    keymap("n", "<leader>fa", require("telescope").extensions.ast_grep.ast_grep, default_opts, "Ast Grep")
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
    keymap("n", "<leader>fu", LZ.export_call("telescope", 3).extensions.undo.undo, default_opts, "Undo")
    keymap("n", "<leader>fs", LZ.export_call("auto-session.session-lens").search_session, default_opts, "Sessions")
    keymap("n", "<leader>fj", telescope_builtin.jumplist, default_opts, "Jump List")
    keymap("n", "<leader>f/", telescope_builtin.current_buffer_fuzzy_find, default_opts, "Buffer Grep")
    keymap("n", "<leader>f.", telescope_builtin.resume, default_opts, "Resume")

    -- Todo-comments
    keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", default_opts, "Todo")

    -- Neogen
    local neogen = LZ.export_call("neogen")
    keymap("n", "<leader>mf", partial(neogen.generate, { type = "func" }), default_opts, "Document Function")
    keymap("n", "<leader>mc", partial(neogen.generate, { type = "class" }), default_opts, "Document Class")
    keymap("n", "<leader>mt", partial(neogen.generate, { type = "type" }), default_opts, "Document Type")
    keymap("n", "<leader>mF", partial(neogen.generate, { type = "File" }), default_opts, "Document File")

    -- Trouble
    local trouble = LZ.export_call("trouble")
    keymap("n", "<leader>lt", partial(trouble.toggle, { mode = "diagnostics" }), default_opts, "Trouble Diagnostics")
    keymap(
        "n",
        "<leader>ls",
        partial(trouble.toggle, { mode = "symbols", focus = true, win = { position = "left" } }),
        default_opts,
        "Trouble Symbols"
    )

    local next_trouble, prev_trouble = repeatable_pair(
        partial(trouble.next, { skip_groups = true, jump = true }),
        partial(trouble.prev, { skip_groups = true, jump = true })
    )

    keymap({ "n", "v" }, "<leader>tr", trouble.refresh, default_opts, "Refresh Trouble")
    keymap({ "n", "v" }, "]t", next_trouble, default_opts, "Next Trouble")
    keymap({ "n", "v" }, "[t", prev_trouble, default_opts, "Previous Trouble")
    keymap({ "n", "v" }, "g;", next_trouble, default_opts, "Next Trouble")
    keymap({ "n", "v" }, "g,", prev_trouble, default_opts, "Previous Trouble")
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
    local next_diag, prev_diag = repeatable_pair(vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
    local lsp_opts = { noremap = true, silent = true, buffer = bufnr }

    keymap({ "n", "v" }, "gD", vim.lsp.buf.declaration, lsp_opts, "Goto Declaration")
    keymap({ "n", "v" }, "gd", vim.lsp.buf.definition, lsp_opts, "Goto Definition")
    keymap({ "n", "v" }, "gi", vim.lsp.buf.implementation, lsp_opts, "Goto Implementation")
    keymap({ "n", "v" }, "gr", vim.lsp.buf.references, lsp_opts, "Goto References")
    keymap({ "n", "v" }, "]d", next_diag, lsp_opts, "Next Diagnostic")
    keymap({ "n", "v" }, "[d", prev_diag, lsp_opts, "Previous Diagnostic")
    keymap({ "n", "v" }, "gn", next_diag, lsp_opts, "Next Diagnostic")
    keymap({ "n", "v" }, "gN", prev_diag, lsp_opts, "Previous Diagnostic")
    keymap({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, lsp_opts, "Code Action")
    keymap({ "n", "v" }, "<leader>li", vim.diagnostic.open_float, lsp_opts, "Diagnostic Info")
    keymap({ "n", "v" }, "<leader>lI", "<cmd>LspInfo<cr>", lsp_opts, "Info")
    keymap({ "n", "v" }, "<leader>lr", LZ.export_call("telescope.builtin").lsp_references, lsp_opts, "References")
    keymap({ "n", "v" }, "<leader>lR", vim.lsp.buf.rename, lsp_opts, "Rename")
    keymap({ "n", "v" }, "<leader>lf", partial(lsp_format, bufnr), lsp_opts, "Format")
    keymap({ "n", "v" }, "<leader>ll", "<Plug>(toggle-lsp-diag)", { noremap = false }, "Toggle Diagnostics")
    keymap({ "n", "v" }, "<leader>lv", "<Plug>(toggle-lsp-diag-vtext)", { noremap = false }, "Toggle Vtext")
    keymap({ "n", "v" }, "<leader>lu", "<Plug>(toggle-lsp-diag-underline)", { noremap = false }, "Toggle Underline")
end

M.set_git_keymaps = function(bufnr)
    local gs = LZ.export_call("gitsigns")
    local gs_opts = { noremap = true, silent = true, buffer = bufnr }

    local next_hunk, prev_hunk = repeatable_pair(function()
        _ = vim.wo.diff and vim.cmd.normal({ "]c", bang = true }) or gs.nav_hunk("next")
    end, function()
        _ = vim.wo.diff and vim.cmd.normal({ "[c", bang = true }) or gs.nav_hunk("prev")
    end)
    keymap("n", "]h", next_hunk)
    keymap("n", "[h", prev_hunk)

    -- Text object
    keymap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>")

    keymap("n", "<leader>gb", LZ.export_call("telescope.builtin").git_branches, gs_opts, "Find Branch")
    keymap("n", "<leader>gc", LZ.export_call("telescope.builtin").git_commits, gs_opts, "Find Commit")
    -- keymap({ "n", "v" }, "<leader>gd", gs.diffthis, gs_opts, "Diff")
    -- keymap("n", "<leader>gD", partial(gs.diffthis, "~"), gs_opts, "Diff with Head")
    keymap({ "n", "v" }, "<leader>gj", next_hunk, gs_opts, "Next Hunk")
    keymap({ "n", "v" }, "<leader>gk", prev_hunk, gs_opts, "Prev Hunk")
    keymap({ "n", "v" }, "<leader>g0", next_hunk, gs_opts, "Next Hunk")
    keymap({ "n", "v" }, "<leader>g$", prev_hunk, gs_opts, "Prev Hunk")
    keymap({ "n", "v" }, "<leader>gp", gs.preview_hunk, gs_opts, "Preview Hunk")
    keymap({ "n", "v" }, "<leader>gr", gs.reset_hunk, gs_opts, "Reset Hunk")
    keymap("n", "<leader>gR", gs.reset_buffer, gs_opts, "Reset Buffer")
    keymap({ "n", "v" }, "<leader>gt", gs.toggle_current_line_blame, gs_opts, "Blame")
    keymap({ "n", "v" }, "<leader>gs", gs.stage_hunk, gs_opts, "Stage Hunk")
    keymap({ "n", "v" }, "<leader>gu", gs.undo_stage_hunk, gs_opts, "Undo Stage Hunk")
    keymap({ "n", "v" }, "<leader>gu", gs.undo_stage_hunk, gs_opts, "Undo Stage Hunk")
    keymap("n", "<leader>gS", gs.stage_buffer, gs_opts, "Stage Buffer")

    -- Diffview
    local dv_toggle = util.Toggle.new(partial(vim.cmd, "DiffviewOpen"), partial(vim.cmd, "DiffviewClose"))
    local dv_fh_toggle = util.Toggle.new(partial(vim.cmd, "DiffviewFileHistory"), partial(vim.cmd, "DiffviewClose"))
    keymap("n", "<leader>gd", util.tbl_f(dv_toggle), default_opts, "Toggle Diffview")
    keymap("n", "<leader>gf", util.tbl_f(dv_fh_toggle), default_opts, "Toggle Diffview File History")
end

function M.set_term_keymaps()
    local term_opts = { noremap = true, silent = true, buffer = 0 }
    keymap("t", "<esc>", "<c-\\><c-n>", term_opts)
end

function M.set_ipy_keymaps()
    local TM = util.TM
    keymap("v", "<leader>tl", TM.send_line, default_opts, "Send Line to IPython")
    keymap("v", "<leader>tL", TM.send_lines, default_opts, "Send Selected Lines to IPython")
    keymap("v", "<leader>ts", TM.send_selection, default_opts, "Send Selection to IPython")

    -- Molten
    keymap("n", "<leader>mI", "<cmd>MoltenInit<cr>", default_opts, " Initialize")
end

function M.set_neotest_keymaps()
    -- Neotest
    local neotest = LZ.export_call("neotest", 2)
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
end

local MS = {
    show_hide = util.Toggle.new(partial(vim.cmd, "MoltenShowOutput"), partial(vim.cmd, "MoltenHideOutput")),
    auto_open = false,
    vtext = true,
}
MS.next_cell, MS.prev_cell = repeatable_pair(partial(vim.cmd, "MoltenNext"), partial(vim.cmd, "MoltenPrev"))

local molten_keymaps = {
    { "n", "<leader>mQ", "<cmd>MoltenDeinit<cr>", default_opts, " De-init" },
    { "n", "<leader>mq", "<cmd>MoltenInterrupt<cr>", default_opts, " Interrupt" },
    { "n", "<leader>mi", "<cmd>MoltenInfo<cr>", default_opts, " Info" },
    { "n", "<leader>me", "<cmd>MoltenEvaluateLine<cr>", default_opts, " Evaluate Line" },
    { "n", "<leader>mr", "<cmd>MoltenReevaluateCell<cr>", default_opts, " Re-evaluate Cell" },
    { "n", "<leader>ma", "<cmd>MoltenReevaluateAll<cr>", default_opts, " Re-evaluate All" },
    { "n", "<leader>md", "<cmd>MoltenDelete<cr>", default_opts, " Delete Cell" },
    { "n", "<leader>mR", "<cmd>MoltenRestart<cr>", default_opts, " Restart" },
    { "v", "<leader>m", "<cmd><C-u>MoltenEvaluateVisual<cr>gv", default_opts, " Evaluate Visual Selection" },
    { "n", "<leader>mn", MS.next_cell, default_opts, " Next Cell" },
    { "n", "<leader>mN", MS.prev_cell, default_opts, " Previous Cell" },
    {
        "n",
        "<leader>ms",
        util.tbl_f(MS.show_hide),
        default_opts,
        " Show/Hide Output",
    },
    {
        "n",
        "<leader>mS",
        function()
            MS.auto_open = not MS.auto_open
            vim.fn.MoltenUpdateOption("molten_auto_open_output", MS.auto_open)
            MS.show_hide.value = MS.auto_open
        end,
        default_opts,
        " Toggle Auto Open Output",
    },
    {
        "n",
        "<leader>mv",
        function()
            MS.vtext = not MS.vtext
            vim.fn.MoltenUpdateOption("molten_virt_text_output", MS.vtext)
        end,
        default_opts,
        " Toggle Vtext Output",
    },
    {
        "n",
        "<leader>m<cr>",
        function()
            vim.cmd("noautocmd MoltenEnterOutput")
            MS.show_hide.value = true
        end,
        default_opts,
        " Enter Output",
    },
}

function M.set_molten_keymaps()
    for _, v in ipairs(molten_keymaps) do
        keymap(unpack(v))
    end
end

function M.del_molten_keymaps()
    for _, v in ipairs(molten_keymaps) do
        vim.keymap.del(v[1], v[2])
    end
end

local dap_keymaps = {
    { { "n", "v" }, "<leader>de", LZ.export_call("dapui").eval, default_opts, "Evaluate" },
    { "n", "<leader>dp", LZ.export_call("dap").pause, default_opts, "Pause" },
    { "n", "<leader>dq", LZ.export_call("dap").terminate, default_opts, "Quit" },
    { "n", "<leader>dsi", repeatable(LZ.export_call("dap").step_into), default_opts, "Into" },
    { "n", "<leader>dso", repeatable(LZ.export_call("dap").step_over), default_opts, "Over" },
    { "n", "<leader>dsu", repeatable(LZ.export_call("dap").step_out), default_opts, "Out" },
    { "n", "<F5>", repeatable(LZ.export_call("dap").continue) },
    { "n", "<F8>", repeatable(LZ.export_call("dap").step_over) },
    { "n", "<F9>", repeatable(LZ.export_call("dap").step_into) },
    { "n", "<F10>", repeatable(LZ.export_call("dap").step_out) },
    {
        "n",
        "<leader>d<leader>",
        repeatable(LZ.export_call("dap").run_to_cursor),
        default_opts,
        "Run to Cursor",
    },
}

M.set_dap_keymaps = function()
    for _, v in ipairs(dap_keymaps) do
        keymap(unpack(v))
    end
end

M.del_dap_keymaps = function()
    M.set_dap_keymaps()
    for _, v in ipairs(dap_keymaps) do
        vim.keymap.del(v[1], v[2])
    end
end

return M
