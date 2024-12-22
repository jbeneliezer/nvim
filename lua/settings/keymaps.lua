local M = {}

local default_opts = { noremap = true, silent = true }
local keymap = function(mode, lhs, rhs, opts, description)
    local local_opts = opts or { noremap = true, silent = true }
    local_opts.desc = description or "which_key_ignore"
    vim.keymap.set(mode, lhs, rhs, local_opts)
end

local toggle_source = function(source)
    local cmp = require("cmp")
    local toggle = false
    local sources = cmp.get_config().sources

    for i = #sources, 1, -1 do
        if sources[i].name == source then
            table.remove(sources, i)
            toggle = true
        end
    end

    if not toggle then
        table.insert(sources, { name = source })
    end

    cmp.setup.buffer({
        sources = sources,
    })
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
    keymap({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    keymap({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

    keymap({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { noremap = true, silent = true, expr = true })
    keymap({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { noremap = true, silent = true, expr = true })

    -- This repeats the last query with always previous direction and to the start of the range.
    keymap({ "n", "x", "o" }, "<leader>0", function()
        ts_repeat_move.repeat_last_move({ forward = false, start = true })
    end)

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

    -- Windows
    keymap("n", "<c-h>", "<c-w>h")
    keymap("n", "<c-j>", "<c-w>j")
    keymap("n", "<c-k>", "<c-w>k")
    keymap("n", "<c-l>", "<c-w>l")

    keymap("n", "<leader>c", "<cmd>BufferClose<cr>")

    local next_file_repeat, prev_file_repeat = repeatable_pair(function()
        vim.cmd("BufferNext")
    end, function()
        vim.cmd("BufferPrevious")
    end)
    local next_file_move_repeat, prev_file_move_repeat = repeatable_pair(function()
        vim.cmd("BufferMoveNext")
    end, function()
        vim.cmd("BufferMovePrevious")
    end)
    keymap("n", "L", next_file_repeat)
    keymap("n", "H", prev_file_repeat)
    keymap("n", "<leader>L", next_file_move_repeat)
    keymap("n", "<leader>H", prev_file_move_repeat)
    for i = 1, 9 do
        keymap({ "n", "v" }, "<leader>" .. i, "<cmd>BufferGoto " .. i .. "<cr>")
    end

    -- File Explorer
    -- keymap("n", "<leader>e", "<cmd>Lex 25<cr>", default_opts, "Explorer")
    keymap("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")

    -- Comment
    keymap("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", { noremap = false }, "Comment")
    keymap("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)gv", { noremap = false }, "Comment")

    -- Copilot
    keymap("n", "<leader>C", function()
        toggle_source("copilot")
    end, default_opts, "Toggle Copilot")

    -- Paste in visual mode
    keymap("v", "p", '"_dP')

    -- Toggleterm
    if OsCurrent == Os.WINDOWS then
        local ps_term = require("toggleterm.terminal").Terminal:new({
            cmd = "powershell -nologo",
            hidden = true,
            op_open = function(_)
                vim.cmd("startinsert!")
            end,
        })
        keymap({ "n", "v", "t" }, "<c-t>", function()
            ps_term:toggle()
        end)
        keymap({ "n", "v", "t" }, "<c-p>", function()
            ps_term:toggle()
        end)
    elseif OsCurrent == Os.LINUX then
        keymap({ "n", "v", "t" }, "<c-t>", "<cmd>ToggleTerm<cr>")
        keymap({ "n", "v", "t" }, "<c-p>", "<cmd>ToggleTerm<cr>")
    end

    -- lazygit
    local lazygit = require("toggleterm.terminal").Terminal:new({
        cmd = "lazygit",
        hidden = true,
        op_open = function(_)
            vim.cmd("startinsert!")
        end,
    })
    keymap({ "n", "v", "t" }, "<c-g>", function()
        lazygit:toggle()
    end)

    -- LF
    -- keymap({ "n", "v" }, "<c-e>", require("lf").start)
    -- keymap("t", "<c-e>", "<cmd>ToggleTerm<cr>")

    -- Dap
    local dap = require("dap")
    local next_bp_repeat, prev_bp_repeat =
        repeatable_pair(require("goto-breakpoints").next, require("goto-breakpoints").prev)
    keymap("n", "<F5>", repeatable(dap.continue))
    keymap("n", "<F8>", repeatable(dap.step_over))
    keymap("n", "<F9>", repeatable(dap.step_into))
    keymap("n", "<F10>", repeatable(dap.step_out))
    keymap("n", "<leader>da", function()
        require("dapui").elements.watches.add(vim.fn.input("Expression: "))
    end, default_opts, "Add Watch")
    keymap("n", "<leader>db", require("telescope").extensions.dap.list_breakpoints, default_opts, "Breakpoints")
    keymap("n", "<leader>du", require("dapui").toggle, default_opts, "UI")
    keymap("n", "<leader>dt", dap.toggle_breakpoint, default_opts, "Breakpoint")
    keymap("n", "<leader>dc", repeatable(dap.continue), default_opts, "Continue")
    keymap("n", "<leader>dC", require("telescope").extensions.dap.commands, default_opts, "Commands")
    keymap({ "n", "v" }, "<leader>de", require("dapui").eval, default_opts, "Evaluate")
    keymap("n", "<leader>dr", dap.run_last, default_opts, "Run Last")
    keymap("n", "<leader>dR", dap.repl.toggle, default_opts, "Repl")
    keymap("n", "<leader>dp", dap.pause, default_opts, "Pause")
    keymap("n", "<leader>dq", dap.terminate, default_opts, "Quit")
    keymap("n", "<leader>dsi", repeatable(dap.step_into), default_opts, "Into")
    keymap("n", "<leader>dso", repeatable(dap.step_over), default_opts, "Over")
    keymap("n", "<leader>dsu", repeatable(dap.step_out), default_opts, "Out")
    keymap("n", "<leader>d<leader>", repeatable(dap.run_to_cursor), default_opts, "Run to Cursor")
    keymap("n", "<leader>bc", dap.clear_breakpoints, default_opts, "Clear Breakpoints")
    keymap("n", "<leader>bn", next_bp_repeat, default_opts, "Next Breakpoint")
    keymap("n", "<leader>bN", prev_bp_repeat, default_opts, "Previous Breakpoint")
    keymap("n", "<leader>b<leader>", require("goto-breakpoints").stopped, default_opts, "Current Stopped Line")

    -- Neotest
    local neotest = require("neotest")
    keymap("n", "<leader>nm", neotest.run.run, default_opts, "Run Test")
    keymap("n", "<leader>nM", function()
        neotest.run.run({ strategy = "dap" })
    end, default_opts, "Debug Test")
    keymap("n", "<leader>nf", function()
        neotest.run.run({ vim.fn.expand("%") })
    end, default_opts, "Run All Tests")
    keymap("n", "<leader>nF", function()
        neotest.run.run({ vim.fn.expand("%"), strategy = "dap" })
    end, default_opts, "Debug All Tests")
    keymap("n", "<leader>ns", neotest.summary.toggle, default_opts, "Test Summary")
    keymap("n", "<leader>np", neotest.run.stop, default_opts, "Stop Test")
    keymap("n", "<leader>na", neotest.run.attach, default_opts, "Attach To Test")

    -- Telescope
    local telescope_builtin = require("telescope.builtin")
    keymap("n", "<leader>fa", telescope_builtin.autocommands, default_opts, "Autocommands")
    keymap("n", "<leader>fc", telescope_builtin.commands, default_opts, "Commands")
    -- keymap("n", "<leader>fC", function()
    --     telescope_builtin.colorscheme({ enable_preview = true })
    -- end, default_opts, "Colorscheme")
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

    -- Fzf-Lua
    if FZF_LUA then
        keymap("n", "<leader>_fl", require("fzf-lua").resume, default_opts, "Resume")

        keymap("n", "<leader>_ff", require("fzf-lua").files, default_opts, "Files")
        keymap("n", "<leader>_fr", require("fzf-lua").oldfiles, default_opts, "Recent Files")
        keymap("n", "<leader>_fb", require("fzf-lua").buffers, default_opts, "Buffers")

        keymap("n", "<leader>_fg", require("fzf-lua").live_grep, default_opts, "Live Grep")
        -- keymap("n", "<leader>_f_g", require("fzf-lua").live_grep_native, default_opts, "Live Grep Native")
        keymap("n", "<leader>_fG", require("fzf-lua").live_grep_resume, default_opts, "Live Grep Resume")
        keymap("n", "<leader>_f/", require("fzf-lua").lgrep_curbuf, default_opts, "Live Grep Buffer")
        keymap("n", "<leader>_f*", require("fzf-lua").grep_cword, default_opts, "Grep word")
        keymap("n", "<leader>_F*", require("fzf-lua").grep_cWORD, default_opts, "Grep WORD")
        keymap({ "v", "x" }, "<leader>_f*", require("fzf-lua").visual, default_opts, "Grep visual")
    end

    -- Todo-comments
    keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", default_opts, "Todo")

    -- Neogen
    local neogen = require("neogen")
    keymap("n", "<leader>mf", function()
        neogen.generate({ type = "func" })
    end, default_opts, "Document Function")
    keymap("n", "<leader>mc", function()
        neogen.generate({ type = "class" })
    end, default_opts, "Document Class")
    keymap("n", "<leader>mt", function()
        neogen.generate({ type = "type" })
    end, default_opts, "Document Type")
    keymap("n", "<leader>mF", function()
        neogen.generate({ type = "File" })
    end, default_opts, "Document File")

    -- Trouble
    local trouble = require("trouble")
    keymap("n", "<leader>t", function()
        trouble.toggle({ mode = "diagnostics" })
    end, default_opts, "Trouble Diagnostics")
    keymap("n", "<leader>s", function()
        trouble.toggle({ mode = "symbols", focus = true, win = { position = "left" } })
    end, default_opts, "Trouble Symbols")

    local next_trouble_repeat, prev_trouble_repeat = repeatable_pair(function()
        trouble.next({ skip_groups = true, jump = true })
    end, function()
        trouble.previous({ skip_groups = true, jump = true })
    end)

    keymap({ "n", "v" }, "]t", next_trouble_repeat, default_opts, "Next Trouble")
    keymap({ "n", "v" }, "[t", prev_trouble_repeat, default_opts, "Previous Trouble")
    keymap({ "n", "v" }, "g;", next_trouble_repeat, default_opts, "Next Trouble")
    keymap({ "n", "v" }, "g,", prev_trouble_repeat, default_opts, "Previous Trouble")
    keymap({ "n", "v" }, "g0", function()
        trouble.first({ skip_groups = true, jump = true })
    end, default_opts, "First Trouble")
    keymap({ "n", "v" }, "g$", function()
        trouble.last({ skip_groups = true, jump = true })
    end, default_opts, "Last Trouble")
end

M.set_lsp_keymaps = function(_, bufnr)
    -- Navigation
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
    keymap({ "n", "v" }, "<leader>lf", function()
        lsp_format(bufnr)
    end, lsp_opts, "Format")
    keymap({ "n", "v" }, "<leader>ll", "<Plug>(toggle-lsp-diag)", { noremap = false }, "Toggle Diagnostics")
    keymap({ "n", "v" }, "<leader>lt", "<Plug>(toggle-lsp-diag-vtext)", { noremap = false }, "Toggle Vtext")
    keymap({ "n", "v" }, "<leader>lu", "<Plug>(toggle-lsp-diag-underline)", { noremap = false }, "Toggle Underline")
end

M.set_git_keymaps = function(bufnr)
    local gs = require("gitsigns")
    -- local gs = package.loaded.gitsigns
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
    keymap("n", "<leader>gD", function()
        gs.diffthis("~")
    end, gs_opts, "Diff with Head")
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

return M
