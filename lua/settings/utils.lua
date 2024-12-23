local M = {}

local default_opts = { noremap = true, silent = true }
local keymap = function(mode, lhs, rhs, opts, description)
    local local_opts = opts or default_opts
    local_opts.desc = description or "which_key_ignore"
    vim.keymap.set(mode, lhs, rhs, local_opts)
end

local terms = {}
for i = 1, 4 do
    terms[i] = require("toggleterm.terminal").Terminal:new({ display_name = "term", count = i })
    if OsCurrent == Os.WINDOWS then
        terms[i].cmd = "powershell -nologo"
    end
end

-- ipython
terms.ipy_term = require("toggleterm.terminal").Terminal:new({
    display_name = "ipython",
    cmd = "ipython",
    hidden = true,
    count = 5,
})
keymap({ "n", "v", "t" }, "<leader><c-p>", function()
    terms.ipy_term:toggle()
end)

-- lazygit
terms.lazygit = require("toggleterm.terminal").Terminal:new({
    display_name = "lazygit",
    cmd = "lazygit",
    hidden = true,
    count = 6,
})
keymap({ "n", "v", "t" }, "<c-g>", function()
    terms.lazygit:toggle()
end)

M.close_any_or_open1 = function()
    local any_open = false
    for _, v in pairs(terms) do
        if v:is_open() then
            v:close()
            any_open = true
        end
    end
    if not any_open then
        terms[1]:open()
    end
end

M.next_term_or_win = function()
    for i = 1, 4 do
        if terms[i]:is_focused() then
            terms[i]:close()
            local n = terms[i % 4 + 1]
            if n:is_open() then
                n:focus()
            else
                n:open()
            end
            return
        end
    end
    vim.cmd("wincmd l")
end

M.prev_term_or_win = function()
    for i = 1, 4 do
        if terms[i]:is_focused() then
            terms[i]:close()
            local ind = i - 1
            if ind == 0 then
                ind = 4
            end
            local p = terms[ind]
            if p:is_open() then
                p:focus()
            else
                p:open()
            end
            return
        end
    end
    vim.cmd("wincmd h")
end

M.terms = terms
return M
