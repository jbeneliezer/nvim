local M = {}

--- No-op.
---@vararg any
M.noop = function(...) end

M.default_opts = { noremap = true, silent = true }

---Wrapper for vim.keymap.set()
---@param mode string|table
---@param lhs string|table
---@param rhs string|function
---@param opts table?
---@param desc string?
M.set_keymap = function(mode, lhs, rhs, opts, desc)
    local local_opts = opts or M.default_opts
    local_opts.desc = desc or ""
    if type(lhs) == "table" then
        for _, v in pairs(lhs) do
            vim.keymap.set(mode, v, rhs, local_opts)
        end
    else
        vim.keymap.set(mode, lhs, rhs, local_opts)
    end
end

---Wrapper for vim.keymap.del()
---@param mode string|table
---@param lhs string|table
---@param buffer integer|boolean?
M.del_keymap = function(mode, lhs, buffer)
    if type(lhs) == "table" then
        for _, v in pairs(lhs) do
            vim.keymap.del(mode, v, { buffer })
        end
    else
        vim.keymap.del(mode, lhs, { buffer })
    end
end

--- Wrapper for vim.lsp.format.
---@param bufnr integer
M.lsp_format = function(bufnr)
    vim.lsp.buf.format({
        async = true,
        bufnr = bufnr,
        filter = function(client)
            return client.name ~= "clangd"
        end,
    })
end

--- Converts table into function, mainly to work with vim.keymap.set.
---@param obj table metatable with __call() implemented.
---@return any result of calling obj:__call().
M.tbl_fn = function(obj)
    return function(...)
        return obj(...)
    end
end

--- Partial functions.
---@generic T
---@param f fun(...: any): T
---@vararg any
---@return fun(...: any): T
M.partial = function(f, ...)
    local args = { ... }
    return function(...)
        return f(unpack(args, ...))
    end
end

--- Partial bound method.
---@generic K, T
---@param obj table<K, fun(...: any): T>
---@param m K
---@vararg any
---@return T
M.bind = function(obj, m, ...)
    local args = { ... }
    return function(...)
        return obj[m](obj, unpack(args, ...))
    end
end

--- Toggles whether source is included in completion menu.
---@param source string
M.toggle_cmp_source = function(source)
    local cmp = require("cmp")
    local toggle = false
    local sources = cmp.get_config().sources

    if sources == nil then
        return
    end

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

---@class (exact) LZ
---@field index fun(path: string): table<string, table>
---@field module_call fun(path: string): (fun(_: table, ...: any): any)
---@field export_call fun(path: string): table<string, (fun(...:any): any)>
---@field export_call_recursive fun(path: string, level: integer?): table<string, any>
local LZ = {}

LZ.index = function(path)
    return setmetatable({}, {
        __index = function(_, k)
            return require(path)[k]
        end,
        __newindex = function(_, k, v)
            require(path)[k] = v
        end,
    })
end

---@overload fun(path: string): (fun(_: table, ...: any): any)
LZ.module_call = function(path)
    ---@overload fun(_: table, ...: any): any
    ---@diagnostic disable-next-line
    return setmetatable({}, {
        __call = function(_, ...)
            return require(path)(...)
        end,
    })
end

---@overload fun(path: string): table<string, (fun(...:any): any)>
LZ.export_call = function(path)
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                return require(path)[k](...)
            end
        end,
    })
end

LZ.export_call_recursive = function(path, level)
    level = level or 1
    local function export_call_r(lvl, ks)
        return setmetatable({}, {
            __index = function(_, k)
                local new_ks = ks or {}
                if lvl == 1 then
                    return function(...)
                        local m = require(path)
                        for _, v in ipairs(new_ks) do
                            m = m[v]
                        end
                        return m[k](...)
                    end
                else
                    table.insert(new_ks, k)
                    return export_call_r(lvl - 1, new_ks)
                end
            end,
        })
    end
    return export_call_r(level)
end

---@module "nvim-treesitter.textobjects.repeatable_move"
M.ts_repeat_move = LZ.export_call_recursive("nvim-treesitter.textobjects.repeatable_move")

--- Makes a pair of functions forward and backward repeatable.
---@param ff fun(): nil
---@param bf fun(): nil
---@return (fun(opts: table, ...): nil), (fun(opts: table, ...): nil)
M.repeatable_pair = function(ff, bf)
    return M.ts_repeat_move.make_repeatable_move_pair(ff, bf)
end

--- Makes a function repeatable.
---@param f fun(): nil
---@return fun(opts: table, ...): nil
M.repeatable = function(f)
    local fw, _ = M.repeatable_pair(f, function() end)
    return fw
end

--- Closes terminal if it is open.
---@param t Terminal terminal to close.
---@return boolean whether terminal was open.
local check_close = function(t)
    if t:is_open() then
        t:close()
        return true
    end
    return false
end

---@class (exact) TM Terminal Manager, manages groups of terminals.
---@field lazygit Terminal terminal for lazygit.
---@field terms table<integer, Terminal> regular terminals.
---@field ipy_terms table<integer, Terminal> ipython terminals.
---@field term_key integer current regular terminal index.
---@field ipy_term_key integer current ipython terminal index.
---@field get fun(): TM
---@field close_terms fun(): boolean
---@field next_term fun(): boolean
---@field prev_term fun(): boolean
---@field next_ipy_term fun(): boolean
---@field prev_ipy_term fun(): boolean
---@field term_toggle fun(): nil
---@field ipy_term_toggle fun(): nil
---@field next_term_or_win fun(): nil
---@field prev_term_or_win fun(): nil
local TM = {
    terms = {},
    ipy_terms = {},
    term_key = 1,
    ipy_term_key = 1,
}

--- Creates terminals if they don't exist yet, otherwise just returns TM.
---@return TM
TM.get = function()
    ---@module "toggleterm.terminal"
    if not vim.tbl_isempty(TM.terms) then
        return TM
    end
    -- lazygit terminal
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
    -- ipython terminals
    for i = 1, 4 do
        TM.ipy_terms[i] = require("toggleterm.terminal").Terminal:new({
            display_name = "ipython " .. i,
            cmd = "ipython --no-banner",
            count = i + 5,
        })
    end
    return TM
end

--- Closes all terminals, saving the index of the last one closed.
---@return boolean whether any terminals were open.
TM.close_terms = function()
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

--- Closes any currently opened terminals.
--- Opens and focuses the next terminal if a terminal is currently focused.
---@return boolean whether any terminal was focused when called.
TM.next_term = function()
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

--- Closes any currently opened terminals.
--- Opens and focuses the previous terminal if a terminal is currently focused.
---@return boolean whether any terminal was focused when called.
TM.prev_term = function()
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

--- Same as next_term, except that it applies to ipython terminals
---@return boolean whether any ipython terminal was focused when called.
TM.next_ipy_term = function()
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

--- Same as prev_term, except that it applies to ipython terminals
---@return boolean whether any ipython terminal was focused when called.
TM.prev_ipy_term = function()
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

--- Toggles the most recently opened terminal.
TM.term_toggle = function()
    local tm = TM.get()
    if not tm.close_terms() then
        tm.terms[tm.term_key]:open()
    end
end

--- Toggles the most recently opened ipython terminal.
TM.ipy_term_toggle = function()
    local tm = TM.get()
    if not tm.close_terms() then
        tm.ipy_terms[tm.ipy_term_key]:open()
    end
end

--- If a regular or ipython terminal is currently opened, closes it and opens the next one.
--- Otherwise, calls "wincmd l"
TM.next_term_or_win = function()
    local tm = TM.get()
    if tm.next_term() or tm.next_ipy_term() then
        return
    else
        vim.cmd("wincmd l")
    end
end

--- If a regular or ipython terminal is currently opened, closes it and opens the previous one.
--- Otherwise, calls "wincmd h"
TM.prev_term_or_win = function()
    local tm = TM.get()
    if tm.prev_term() or tm.prev_ipy_term() then
        return
    else
        vim.cmd("wincmd h")
    end
end

---@class (exact) DM Dapui Manager, manages layouts and controls.
---Allows for dynamically switching between layouts.
---@field ids string[] element ids to cycle between.
---@field curr_id integer index of current element id.
---@field config_active boolean whether layout cycling is active.
---@field config table<string, table> config that supports layout cycling.
---@field default_config table<string, table> default config.
---@field repl_config table<string, table> like default config, but with repl in place of console.
---@field reload fun(config: table<string, table>): nil
---@field next_layout fun(): nil
---@field prev_layout fun(): nil
---@field default_layout fun(): nil
---@field repl_layout fun(): nil
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
    },
}

--- Reloads dapui with updated config.
---@param config table<string, table> config to reload dapui with.
DM.reload = function(config)
    local plugin = require("lazy.core.config").plugins["nvim-dap-ui"]
    plugin.opts = config
    require("lazy.core.loader").reload(plugin)
end

--- If layout cycling is active, switches to the next layout.
--- Otherwise, switches to layout cycling config.
DM.next_layout = function()
    require("dapui").close()
    if DM.config_active then
        DM.curr_id = (DM.curr_id % 4) + 1
    else
        DM.config_active = true
    end
    DM.config.layouts[1].elements[2].id = DM.ids[DM.curr_id]
    DM.reload(DM.config)
    require("dapui").open()
end

--- If layout cycling is active, switches to the previous layout.
--- Otherwise, switches to layout cycling config.
DM.prev_layout = function()
    require("dapui").close()
    if DM.config_active then
        DM.curr_id = DM.curr_id == 1 and 4 or DM.curr_id - 1
    else
        DM.config_active = true
    end
    DM.config.layouts[1].elements[2].id = DM.ids[DM.curr_id]
    DM.reload(DM.config)
    require("dapui").open()
end

--- Switches to default config.
DM.default_layout = function()
    require("dapui").close()
    DM.config_active = false
    DM.reload(DM.default_config)
    require("dapui").open()
end

--- Switches to repl config.
DM.repl_layout = function()
    require("dapui").close()
    DM.config_active = false
    DM.reload(DM.repl_config)
    require("dapui").open()
end

--- Custom DAP command to get disassembly.
--- Really should create a custom element and add to dapui.
M.dap_disassemble = function()
    require("dap").repl.execute("disassemble")
end

local handle_stdout = function(err, data)
    if err ~= nil then
        vim.notify(err .. ": " .. data, vim.log.levels.INFO)
    end
end

local handle_stderr = function(err, data)
    if err ~= nil then
        vim.notify(err .. ": " .. data, vim.log.levels.ERROR)
    end
end

local on_exit = function(c)
    local s = "code: " .. c.code .. ", signal: " .. c.signal
    if c.stdout then
        s = s .. ", stdout: " .. c.stdout
    end
    if c.stderr then
        s = s .. ", stderr: " .. c.stderr
    end
    print(vim.inspect(s))
end

M.build_command = function()
    vim.system({ vim.fn.getcwd() .. "/make.bat" }, { stdout = handle_stdout, stderr = handle_stderr }, on_exit)
end

M.clean_command = function()
    vim.system({ vim.fn.getcwd() .. "/make.bat", "clean" }, { stdout = handle_stdout, stderr = handle_stderr }, on_exit)
end

---@class (exact) Toggle turns set/clear functions into single toggle function.
---@field rf fun(...: any): nil function called on rising edge.
---@field ff fun(...: any): nil function called on falling edge.
---@field value boolean Toggle value.
---@field linked Toggle other Toggle instance to set/clear when toggling.
---@field new fun(rf: (fun(...: any): nil)?, ff: (fun(...: any): nil)?, initial: boolean?, linked: Toggle?): Toggle
local Toggle = {}

--- Creates a new Toggle instance.
---@param rf (fun(...: any): nil)? function to call on rising edge.
---@param ff (fun(...: any): nil)? function to call on falling edge.
---@param initial boolean? initial value.
---@param linked Toggle? value of linked will be set/cleared when toggling.
---@return Toggle
Toggle.new = function(rf, ff, initial, linked)
    return setmetatable({
        rf = rf or M.noop,
        ff = ff or M.noop,
        value = initial or false,
        linked = linked or {},
    }, {
        __index = Toggle,
        __call = Toggle.call,
    })
end

--- Sets value, calling rf() if it was previously false.
---@vararg any passed through to rf.
function Toggle:set(...)
    _ = not self.value and self:rf(...)
    self.value = true
    if self.linked then
        self.linked.value = self.value
    end
end

--- Clears value, calling ff() if it was previously true.
---@vararg any passed through to ff.
function Toggle:clear(...)
    _ = self.value and self:ff(...)
    self.value = false
    if self.linked then
        self.linked.value = self.value
    end
end

--- Toggles value, calling rf() if it was previously false, and ff() if it was previously true.
---@vararg any passed through to either rf or ff.
function Toggle:call(...)
    self.value = not self.value
    _ = self.value and self:rf(...) or self:ff(...)
    if self.linked then
        self.linked.value = self.value
    end
end

M.LZ = LZ
M.TM = TM
M.DM = DM
M.Toggle = Toggle

return M
