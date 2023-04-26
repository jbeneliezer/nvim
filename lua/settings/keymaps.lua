local default_opts = { noremap = true, silent = true }
local keymap = function(mode, lhs, rhs, opts, description)
    local local_opts = opts
    local_opts["desc"] = description or "which_key_ignore"
    vim.keymap.set(mode, lhs, rhs, local_opts)
    -- end
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

keymap({ "n", "v" }, "<c-n>", "J", default_opts)
keymap({ "n", "v" }, "J", "<c-d>zz", default_opts)
keymap({ "n", "v" }, "K", "<c-u>zz", default_opts)

keymap("n", "<leader>c", "<cmd>bdelete<cr>", default_opts, "Close")
keymap("n", "<leader>e", "<cmd>Lex 25<cr>", default_opts, "Explorer")

keymap("n", "<leader>j", "<cmd>m .+1<cr>==<cr>", default_opts)
keymap("v", "<leader>j", "<cmd>m '>+1<cr>gv=gv<cr>", default_opts)
keymap("n", "<leader>k", "<cmd>m .-2<cr>==<cr>", default_opts)
keymap("v", "<leader>k", "<cmd>m '>-2<cr>gv=gv<cr>", default_opts)

keymap("n", "<leader>m", require("grapple").toggle, default_opts, "Toggle Tag")
keymap("n", "<leader>o", "<cmd>ToggleOnly<cr>", default_opts, "Fullscreen")
keymap("n", "<leader>q", "<cmd>q<cr>", default_opts, "Quit")
keymap("n", "<leader>t", require("trouble").toggle, default_opts, "Trouble")
keymap("n", "<leader>w", "<cmd>w<cr>", default_opts, "Save")

-- Resize with arrows
keymap("n", "<c-Up>", "<cmd>resize -2<cr>", default_opts)
keymap("n", "<c-Down>", "<cmd>resize +2<cr>", default_opts)
keymap("n", "<c-Left>", "<cmd>vertical resize -2<cr>", default_opts)
keymap("n", "<c-Right>", "<cmd>vertical resize +2<cr>", default_opts)

-- Stay in indent mode
keymap("v", "<", "<gv", default_opts)
keymap("v", ">", ">gv", default_opts)

-- Windows
keymap("n", "<c-h>", "<c-w>h", default_opts)
keymap("n", "<c-j>", "<c-w>j", default_opts)
keymap("n", "<c-k>", "<c-w>k", default_opts)
keymap("n", "<c-l>", "<c-w>l", default_opts)

-- Buffers
keymap("n", "<leader>c", "<cmd>bdelete<cr>", default_opts)
keymap("n", "<s-l>", "<cmd>BufferLineCycleNext<cr>", default_opts)
keymap("n", "<s-h>", "<cmd>BufferLineCyclePrev<cr>", default_opts)
keymap("n", "<leader>L", "<cmd>BufferLineMoveNext<cr>", default_opts)
keymap("n", "<leader>H", "<cmd>BufferLineMovePrev<cr>", default_opts)
keymap("n", "<leader>1", function()
    require("bufferline").go_to_buffer(1, true)
end, default_opts)
keymap("n", "<leader>2", function()
    require("bufferline").go_to_buffer(2, true)
end, default_opts)
keymap("n", "<leader>3", function()
    require("bufferline").go_to_buffer(3, true)
end, default_opts)
keymap("n", "<leader>4", function()
    require("bufferline").go_to_buffer(4, true)
end, default_opts)
keymap("n", "<leader>5", function()
    require("bufferline").go_to_buffer(5, true)
end, default_opts)
keymap("n", "<leader>6", function()
    require("bufferline").go_to_buffer(6, true)
end, default_opts)
keymap("n", "<leader>7", function()
    require("bufferline").go_to_buffer(7, true)
end, default_opts)
keymap("n", "<leader>8", function()
    require("bufferline").go_to_buffer(8, true)
end, default_opts)
keymap("n", "<leader>9", function()
    require("bufferline").go_to_buffer(9, true)
end, default_opts)

-- Comment
keymap("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", { noremap = false }, "Comment")
keymap("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)gv", { noremap = false }, "Comment")

-- Copilot
keymap("n", "<leader>C", function()
    toggle_source("copilot")
end, default_opts, "Toggle Copilot")

-- Paste in visual mode
keymap("v", "p", '"_dP', default_opts)

-- Toggleterm
keymap({ "n", "t" }, "<c-t>", "<cmd>ToggleTerm<cr>", default_opts)

-- LF
keymap({ "n", "v" }, "<c-e>", require("lf").start, default_opts)

-- Todo-comments
keymap("n", "]t", function()
    require("todo-comments").jump_next()
end, default_opts)
keymap("n", "[t", function()
    require("todo-comments").jump_prev()
end, default_opts)

-- Dap
keymap("n", "<F5>", require("dap").continue, default_opts)
keymap("n", "<F10>", require("dap").step_over, default_opts)
keymap("n", "<F11>", require("dap").step_into, default_opts)
keymap("n", "<F12>", require("dap").step_out, default_opts)
keymap("n", "<leader>da", function()
    require("dapui").elements.watches.add(vim.fn.input("Expression: "))
end, default_opts, "Add Watch")
keymap("n", "<leader>du", require("dapui").toggle, default_opts, "UI")
keymap("n", "<leader>dt", require("dap").toggle_breakpoint, default_opts, "Breakpoint")
keymap("n", "<leader>dc", require("dap").continue, default_opts, "Continue")
keymap("n", "<leader>dr", require("dap").run_last, default_opts, "Run Last")
keymap("n", "<leader>dR", require("dap").repl.toggle, default_opts, "Repl")
keymap("n", "<leader>dp", require("dap").pause, default_opts, "Pause")
keymap("n", "<leader>dq", require("dap").terminate, default_opts, "Quit")
keymap("n", "<leader>ds", "<leader>ds", default_opts, "Step")
keymap("n", "<leader>dsi", require("dap").step_into, default_opts, "Into")
keymap("n", "<leader>dso", require("dap").step_over, default_opts, "Over")
keymap("n", "<leader>dsu", require("dap").step_out, default_opts, "Out")

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
end, default_opts)
