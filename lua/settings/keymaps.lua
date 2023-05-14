local default_opts = { noremap = true, silent = true }
local keymap = function(mode, lhs, rhs, opts, description)
    local local_opts = opts or { noremap = true, silent = true }
    local_opts["desc"] = description or "which_key_ignore"
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

keymap({ "n", "v" }, "<c-n>", "J")
keymap({ "n", "v" }, "J", "<c-d>zz")
keymap({ "n", "v" }, "K", "<c-u>zz")

keymap("n", "<leader>c", "<cmd>bdelete<cr>", default_opts, "Close")
keymap("n", "<leader>e", "<cmd>Lex 25<cr>", default_opts, "Explorer")

keymap("n", "<leader>j", "<cmd>m .+1<cr>==")
keymap("v", "<leader>j", "<cmd>m '>+1<cr>gv=gv<cr>")
keymap("n", "<leader>k", "<cmd>m .-2<cr>==")
keymap("v", "<leader>k", "<cmd>m '>-2<cr>gv=gv<cr>")

keymap("n", "<leader>o", "<c-w>o", default_opts, "Fullscreen")
keymap("n", "<leader>q", "<cmd>q<cr>", default_opts, "Quit")
keymap("n", "<leader>t", require("trouble").toggle, default_opts, "Trouble")
keymap("n", "<leader>w", "<cmd>w<cr>", default_opts, "Save")

-- Resize with arrows
keymap("n", "<c-Up>", "<cmd>resize -2<cr>")
keymap("n", "<c-Down>", "<cmd>resize +2<cr>")
keymap("n", "<c-Left>", "<cmd>vertical resize -2<cr>")
keymap("n", "<c-Right>", "<cmd>vertical resize +2<cr>")

-- Stay in indent mode
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Windows
keymap("n", "<c-h>", "<c-w>h")
keymap("n", "<c-j>", "<c-w>j")
keymap("n", "<c-k>", "<c-w>k")
keymap("n", "<c-l>", "<c-w>l")

-- Buffers
keymap("n", "<leader>c", "<cmd>bdelete<cr>")
keymap("n", "<s-l>", "<cmd>BufferLineCycleNext<cr>")
keymap("n", "<s-h>", "<cmd>BufferLineCyclePrev<cr>")
keymap("n", "<leader>L", "<cmd>BufferLineMoveNext<cr>")
keymap("n", "<leader>H", "<cmd>BufferLineMovePrev<cr>")
for i = 1, 9 do
    keymap({"n", "v"}, "<leader>" .. i, function ()
        require("bufferline").go_to_buffer(i, true)
    end)
end

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
-- if vim.loop.os_uname().sysname == "Windows_NT" then
--     local ps_term = require("toggleterm.terminal").Terminal:new({
--         cmd = "powershell -nologo",
--         hidden = true,
--         op_open = function(_)
--             vim.cmd("startinsert!")
--         end,
--     })
--     keymap({ "n", "v", "t" }, "<c-t>", function()
--         ps_term:toggle()
--     end)
--     keymap({ "n", "v", "t" }, "<c-p>", function()
--         ps_term:toggle()
--     end)
-- else
keymap({ "n", "v", "t" }, "<c-t>", "<cmd>ToggleTerm<cr>")
keymap({ "n", "v", "t" }, "<c-p>", "<cmd>ToggleTerm<cr>")
-- end

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
keymap({ "n", "v" }, "<c-e>", require("lf").start)
keymap("t", "<c-e>", "<cmd>ToggleTerm<cr>")

-- Todo-comments
keymap("n", "]t", function()
    require("todo-comments").jump_next()
end)
keymap("n", "[t", function()
    require("todo-comments").jump_prev()
end)

-- Dap
keymap("n", "<F5>", require("dap").continue)
keymap("n", "<F8>", require("dap").step_over)
keymap("n", "<F9>", require("dap").step_into)
keymap("n", "<F10>", require("dap").step_out)
keymap("n", "<leader>da", function()
    require("dapui").elements.watches.add(vim.fn.input("Expression: "))
end, default_opts, "Add Watch")
keymap("n", "<leader>db", require("telescope").extensions.dap.list_breakpoints, default_opts, "Breakpoints")
keymap("n", "<leader>du", require("dapui").toggle, default_opts, "UI")
keymap("n", "<leader>dt", require("dap").toggle_breakpoint, default_opts, "Breakpoint")
keymap("n", "<leader>dc", require("dap").continue, default_opts, "Continue")
keymap("n", "<leader>dC", require("telescope").extensions.dap.commands, default_opts, "Commands")
keymap({ "n", "v" }, "<leader>de", require("dapui").eval, default_opts, "Evaluate")
keymap("n", "<leader>dr", require("dap").run_last, default_opts, "Run Last")
keymap("n", "<leader>dR", require("dap").repl.toggle, default_opts, "Repl")
keymap("n", "<leader>dp", require("dap").pause, default_opts, "Pause")
keymap("n", "<leader>dq", require("dap").terminate, default_opts, "Quit")
keymap("n", "<leader>dsi", require("dap").step_into, default_opts, "Into")
keymap("n", "<leader>dso", require("dap").step_over, default_opts, "Over")
keymap("n", "<leader>dsu", require("dap").step_out, default_opts, "Out")
keymap("n", "<leader>d<leader>", require("dap").run_to_cursor, default_opts, "Run to Cursor")
keymap("n", "<leader>bc", require("dap").clear_breakpoints, default_opts, "Clear Breakpoints")

-- Neotest
keymap("n", "<leader>nm", require("neotest").run.run, default_opts, "Run Test")
keymap("n", "<leader>nM", function()
    require("neotest").run.run({ strategy = "dap" })
end, default_opts, "Debug Test")
keymap("n", "<leader>nf", function()
    require("neotest").run.run({ vim.fn.expand("%") })
end, default_opts, "Run All Tests")
keymap("n", "<leader>nF", function()
    require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
end, default_opts, "Debug All Tests")
keymap("n", "<leader>ns", require("neotest").summary.toggle, default_opts, "Test Summary")

-- Telescope
keymap("n", "<leader>fa", require("telescope.builtin").autocommands, default_opts, "Autocommands")
keymap("n", "<leader>fc", require("telescope.builtin").commands, default_opts, "Commands")
keymap("n", "<leader>fC", function()
    require("telescope.builtin").colorscheme({ enable_preview = true })
end, default_opts, "Colorscheme")
keymap("n", "<leader>ff", require("telescope.builtin").find_files, default_opts, "Find Files")
keymap("n", "<leader>fr", require("telescope.builtin").oldfiles, default_opts, "Find Recent")
keymap("n", "<leader>fg", require("telescope.builtin").live_grep, default_opts, "Live Grep")
keymap("n", "<leader>fh", require("telescope.builtin").help_tags, default_opts, "Help Tags")
keymap("n", "<leader>fH", require("telescope.builtin").highlights, default_opts, "Highlights")
keymap("n", "<leader>fk", require("telescope.builtin").keymaps, default_opts, "Keymaps")
keymap("n", "<leader>fp", require("telescope").extensions.projects.projects, default_opts, "Projects")
keymap("n", "<leader>fu", require("telescope").extensions.undo.undo, default_opts, "Undo")
keymap("n", "<leader>fs", require("auto-session.session-lens").search_session, default_opts, "Sessions")

-- Git
keymap("n", "<leader>gb", require("telescope.builtin").git_branches, default_opts, "Find Branch")
keymap("n", "<leader>gc", require("telescope.builtin").git_commits, default_opts, "Find Commit")
keymap({ "n", "v" }, "<leader>gd", require("gitsigns").diffthis, default_opts, "Diff")
keymap("n", "<leader>gD", function()
    require("gitsigns").diffthis("~")
end, default_opts, "Diff with Head")
keymap({ "n", "v" }, "<leader>gj", require("gitsigns").next_hunk, default_opts, "Next Hunk")
keymap({ "n", "v" }, "<leader>gk", require("gitsigns").prev_hunk, default_opts, "Prev Hunk")
keymap({ "n", "v" }, "<leader>gp", require("gitsigns").preview_hunk, default_opts, "Preview Hunk")
keymap({ "n", "v" }, "<leader>gr", require("gitsigns").reset_hunk, default_opts, "Reset Hunk")
keymap("n", "<leader>gR", require("gitsigns").reset_buffer, default_opts, "Reset Buffer")
keymap({ "n", "v" }, "<leader>gt", require("gitsigns").blame_line, default_opts, "Blame")
keymap({ "n", "v" }, "<leader>gs", require("gitsigns").stage_hunk, default_opts, "Stage Hunk")
keymap("n", "<leader>gS", require("gitsigns").stage_buffer, default_opts, "Stage Buffer")