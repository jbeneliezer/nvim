local M = {}

function M.bind(obj, m, ...)
    local args = { ... }
    return function(...)
        return obj[m](obj, unpack(args), ...)
    end
end

function M.partial(f, ...)
    local _args = { ... }
    return function(...)
        return f(unpack(_args), ...)
    end
end

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

local TM = {
    terms = {},
    ipy_terms = {},
    term_key = 1,
    ipy_term_key = 1,
    trim_spaces = false,
    ipy_started = false,
}

local function check_close(t)
    if t:is_open() then
        t:close()
        return true
    end
    return false
end

function TM.get()
    if not vim.tbl_isempty(TM.terms) then
        return TM
    end
    -- lazygit
    TM.lazygit = require("toggleterm.terminal").Terminal:new({
        display_name = "lazygit",
        cmd = "lazygit",
        hidden = true,
        count = 1,
    })
    -- regular terminals
    for i = 1, 4 do
        TM.terms[i] = require("toggleterm.terminal").Terminal:new({ display_name = "term " .. i, count = i + 1 })
    end
    -- ipython
    for i = 1, 4 do
        TM.ipy_terms[i] = require("toggleterm.terminal").Terminal:new({
            display_name = "ipython " .. i,
            cmd = "ipython --no-banner",
            count = i + 5,
        })
    end

    return TM
end

function TM.close_terms()
    local tm = TM.get()
    local any_open = false
    if check_close(tm.lazygit) then
        any_open = true
    end
    for k, v in pairs(tm.terms) do
        if check_close(v) then
            tm.term_key = k
            any_open = true
        end
    end
    for k, v in pairs(tm.ipy_terms) do
        if check_close(v) then
            tm.ipy_term_key = k
            any_open = true
        end
    end
    return any_open
end

function TM.next_term()
    local tm = TM.get()
    if tm.terms[tm.term_key]:is_focused() then
        tm.terms[tm.term_key]:close()
        tm.term_key = tm.term_key % 4 + 1
        local n = tm.terms[tm.term_key]
        _ = n:is_open() and n:focus() or n:open()
        return true
    end
    return false
end

function TM.prev_term()
    local tm = TM.get()
    if tm.terms[tm.term_key]:is_focused() then
        tm.terms[tm.term_key]:close()
        tm.term_key = tm.term_key == 1 and 4 or tm.term_key - 1
        local p = tm.terms[tm.term_key]
        _ = p:is_open() and p:focus() or p:open()
        return true
    end
    return false
end

function TM.next_ipy_term()
    local tm = TM.get()
    if tm.ipy_terms[tm.ipy_term_key]:is_focused() then
        tm.ipy_terms[tm.ipy_term_key]:close()
        tm.ipy_term_key = tm.ipy_term_key % 4 + 1
        local n = tm.ipy_terms[tm.ipy_term_key]
        _ = n:is_open() and n:focus() or n:open()
        return true
    end
    return false
end

function TM.prev_ipy_term()
    local tm = TM.get()
    if tm.ipy_terms[tm.ipy_term_key]:is_focused() then
        tm.ipy_terms[tm.ipy_term_key]:close()
        tm.ipy_term_key = tm.ipy_term_key == 1 and 4 or tm.ipy_term_key - 1
        local p = tm.ipy_terms[tm.ipy_term_key]
        _ = p:is_open() and p:focus() or p:open()
        return true
    end
    return false
end

function TM.term_toggle()
    local tm = TM.get()
    if not tm.close_terms() then
        tm.terms[tm.term_key]:open()
    end
end

function TM.ipy_term_toggle()
    local tm = TM.get()
    if not tm.close_terms() then
        tm.ipy_terms[tm.ipy_term_key]:open()
    end
end

function TM.next_term_or_win()
    local tm = TM.get()
    if tm.next_term() or tm.next_ipy_term() then
        return
    else
        vim.cmd("wincmd l")
    end
end

function TM.prev_term_or_win()
    local tm = TM.get()
    if tm.prev_term() or tm.prev_ipy_term() then
        return
    else
        vim.cmd("wincmd h")
    end
end

function TM.ipy_start()
    local tm = TM.get()
    if not tm.ipy_started then
        tm.ipy_terms[tm.ipy_term_key]:open()
        tm.ipy_terms[tm.ipy_term_key]:close()
        tm.ipy_started = true
    end
end

function TM.send_line()
    local tm = TM.get()
    tm.ipy_start()
    require("toggleterm").send_lines_to_terminal("single_line", tm.trim_spaces, { args = tm.ipy_term_key + 5 })
    tm.ipy_terms[tm.ipy_term_key]:open()
end

function TM.send_lines()
    local tm = TM.get()
    tm.ipy_start()
    require("toggleterm").send_lines_to_terminal("visual_lines", tm.trim_spaces, { args = tm.ipy_term_key + 5 })
    tm.ipy_terms[tm.ipy_term_key]:open()
end

function TM.send_selection()
    local tm = TM.get()
    tm.ipy_start()
    require("toggleterm").send_lines_to_terminal("visual_selection", tm.trim_spaces, { args = tm.ipy_term_key + 5 })
    tm.ipy_terms[tm.ipy_term_key]:open()
end

M.TM = TM

local DM = {
    ids = { "scopes", "breakpoints", "watches", "stacks" },
    curr_id = 1,
    config_active = false,
    config = {
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
                    { id = "repl", size = 0.60 },
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
    },
    default_config = {
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
                    { id = "scopes", size = 0.34 },
                    { id = "breakpoints", size = 0.33 },
                    { id = "watches", size = 0.33 },
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
    },
    repl_config = {
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
                    { id = "scopes", size = 0.34 },
                    { id = "breakpoints", size = 0.33 },
                    { id = "watches", size = 0.33 },
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
    },
}

function DM.next_layout()
    local dapui = require("dapui")
    dapui.close()
    if DM.config_active then
        DM.curr_id = (DM.curr_id % 4) + 1
    else
        DM.config_active = true
    end
    DM.config.layouts[1].elements[2].id = DM.ids[DM.dap_curr_id]
    dapui.setup(DM.config)
    dapui.open()
end

function DM.prev_layout()
    local dapui = require("dapui")
    dapui.close()
    if DM.config_active then
        DM.curr_id = DM.curr_id - 1
        if DM.curr_id == 0 then
            DM.curr_id = 4
        end
    else
        DM.config_active = true
    end
    DM.config.layouts[1].elements[2].id = DM.ids[DM.curr_id]
    dapui.setup(DM.config)
    dapui.open()
end

function DM.default_layout()
    local dapui = require("dapui")
    dapui.close()
    DM.config_active = false
    dapui.setup(DM.default_config)
    dapui.open()
end

function DM.repl_layout()
    local dapui = require("dapui")
    dapui.close()
    DM.config_active = false
    dapui.setup(DM.repl_config)
    dapui.open()
end

M.DM = DM

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
    if c.stdout then
        s = s .. ", stdout: " .. c.stdout
    end
    if c.stderr then
        s = s .. ", stderr: " .. c.stderr
    end
    print(vim.inspect(s))
end

function M.build_command()
    vim.system({ vim.fn.getcwd() .. "/make.bat" }, { stdout = handle_stdout, stderr = handle_stderr }, on_exit)
end

function M.clean_command()
    vim.system({ vim.fn.getcwd() .. "/make.bat", "clean" }, { stdout = handle_stdout, stderr = handle_stderr }, on_exit)
end

local Toggle = {}

function Toggle.new(tf, ff, initial)
    return setmetatable({
        tf = tf or function() end,
        ff = ff or function() end,
        value = initial or false,
    }, {
        __index = Toggle,
        __call = Toggle.call,
    })
end

function Toggle:call()
    self.value = not self.value
    if self.value then
        self.tf()
    else
        self.ff()
    end
end

M.Toggle = Toggle

return M