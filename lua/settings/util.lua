local M = {}

M.toggle_cmp_source = function(source)
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

local TermManager = {}
TermManager.__index = TermManager

function TermManager:new()
    self = setmetatable({ terms = {}, term_key = 2, ipy_term_key = 6 }, self)
    -- lazygit
    self.terms[1] = require("toggleterm.terminal").Terminal:new({
        display_name = "lazygit",
        cmd = "lazygit",
        hidden = true,
        count = 5,
    })
    -- regular terminals
    for i = 2, 5 do
        self.terms[i] = require("toggleterm.terminal").Terminal:new({ display_name = "term " .. i - 1, count = i })
    end
    -- ipython
    for i = 6, 9 do
        self.terms[i] = require("toggleterm.terminal").Terminal:new({
            display_name = "ipython " .. i - 5,
            cmd = "ipython --no-banner",
            count = i,
        })
    end
    return self
end

function TermManager:close_term()
    local any_open = false
    for k, v in pairs(self.terms) do
        if v:is_open() then
            if k >= 2 and k <= 5 then
                self.term_key = k
            elseif k >= 6 and k <= 9 then
                self.ipy_term_key = k
            end
            v:close()
            any_open = true
        end
    end
    return any_open
end

function TermManager:next_term(lo, hi)
    for i = lo, hi - 1 do
        if self.terms[i]:is_focused() then
            self.terms[i]:close()
            local n = self.terms[i + 1]
            if n:is_open() then
                n:focus()
            else
                n:open()
            end
            return true
        end
    end
    if self.terms[hi]:is_focused() then
        self.terms[hi]:close()
        local n = self.terms[lo]
        if n:is_open() then
            n:focus()
        else
            n:open()
        end
        return true
    end
    return false
end

function TermManager:prev_term(lo, hi)
    for i = hi, lo + 1, -1 do
        if self.terms[i]:is_focused() then
            self.terms[i]:close()
            local n = self.terms[i - 1]
            if n:is_open() then
                n:focus()
            else
                n:open()
            end
            return true
        end
    end
    if self.terms[lo]:is_focused() then
        self.terms[lo]:close()
        local n = self.terms[hi]
        if n:is_open() then
            n:focus()
        else
            n:open()
        end
        return true
    end
    return false
end

function TermManager:term_toggle()
    if not self:close_term() then
        self.terms[self.term_key]:open()
    end
end

function TermManager:ipy_term_toggle()
    if not self:close_term() then
        self.terms[self.ipy_term_key]:open()
    end
end

function TermManager:next_term_or_win()
    if not self:next_term(2, 5) and not self:next_term(6, 9) then
        vim.cmd("wincmd l")
    end
end

function TermManager:prev_term_or_win()
    if not self:prev_term(2, 5) and not self:prev_term(6, 9) then
        vim.cmd("wincmd h")
    end
end

M.TermManager = TermManager

local dapui_config = {
    controls = {
        element = "console",
        enabled = true,
        icons = {
            disconnect = "",
            pause = "",
            play = "",
            run_last = "",
            step_back = "",
            step_into = "",
            step_out = "",
            step_over = "",
            terminate = "",
        },
    },
    layouts = {
        {
            elements = {
                { id = "repl",   size = 0.60 },
                { id = "scopes", size = 0.40 },
            },
            size = 12,
            position = "bottom",
        },
        {
            elements = {
                { id = "console", size = 0.95 },
            },
            size = 85,
            position = "right",
        },
    },
}

local dap_curr_id = 1
local dap_ids = { "scopes", "breakpoints", "watches", "stacks" }

function M.dap_next_layout()
    local dapui = require("dapui")
    dapui.close()
    dap_curr_id = (dap_curr_id % 4) + 1
    dapui_config.layouts[1].elements[2].id = dap_ids[dap_curr_id]
    dapui.setup(dapui_config)
    dapui.open()
end

function M.dap_prev_layout()
    local dapui = require("dapui")
    dapui.close()
    dap_curr_id = dap_curr_id - 1
    if dap_curr_id == 0 then
        dap_curr_id = 4
    end
    dapui_config.layouts[1].elements[2].id = dap_ids[dap_curr_id]
    dapui.setup(dapui_config)
    dapui.open()
end

function M.dap_default_layout()
    local dapui = require("dapui")
    dapui.close()
    dapui.setup({
        controls = {
            element = "console",
            enabled = true,
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = "",
            },
        },
        layouts = {
            {
                elements = {
                    { id = "scopes",      size = 0.34 },
                    { id = "breakpoints", size = 0.33 },
                    { id = "watches",     size = 0.33 },
                },
                size = 12,
                position = "bottom",
            },
            {
                elements = {
                    { id = "console", size = 0.95 },
                },
                size = 85,
                position = "right",
            },
        },
    })
    dapui.open()
end

function M.dap_repl_layout()
    local dapui = require("dapui")
    dapui.close()
    dapui.setup({
        controls = {
            element = "repl",
            enabled = true,
            icons = {
                disconnect = "",
                pause = "",
                play = "",
                run_last = "",
                step_back = "",
                step_into = "",
                step_out = "",
                step_over = "",
                terminate = "",
            },
        },
        layouts = {
            {
                elements = {
                    { id = "scopes",      size = 0.34 },
                    { id = "breakpoints", size = 0.33 },
                    { id = "watches",     size = 0.33 },
                },
                size = 12,
                position = "bottom",
            },
            {
                elements = {
                    { id = "repl", size = 0.95 },
                },
                size = 85,
                position = "right",
            },
        },
    })
    dapui.open()
end

function M.dap_disassemble()
    require("dap").repl.execute("disassemble")
end

local function handle_stdout(err, data)
    if err ~= nil then
        vim.notify(err .. ": " .. data, vim.log.levels.INFO)
    end
end

local function handle_stderr(err, data)
    if err ~= nil then
        vim.notify(err .. ": " .. data, vim.log.levels.ERROR)
    end
end

local function on_exit(c)
    local s = "code: " .. c.code .. ", signal: " .. c.signal
    if c.stdout ~= nil then
        s = s .. ", stdout: " .. c.stdout
    end
    if c.stderr ~= nil then
        s = s .. ", stdout: " .. c.stderr
    end
    vim.print(s)
end

function M.build_command()
    vim.system({ vim.fn.getcwd() .. "/make.bat" }, { stdout = handle_stdout, stderr = handle_stderr }, on_exit)
end

function M.clean_command()
    vim.system({ vim.fn.getcwd() .. "/make.bat", "clean" }, { stdout = handle_stdout, stderr = handle_stderr }, on_exit)
end

return M
