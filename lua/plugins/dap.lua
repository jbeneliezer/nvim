--- Finds the right python interpreter for the DAP configuration.
--- @return string
local function get_python()
    local venv = vim.fn.getenv("VIRTUAL_ENV")
    if venv ~= vim.NIL then
        local p = venv .. (OsCurrent == OS.WINDOWS and "/Scripts/python" or "/bin/python")
        if vim.fn.executable(p) then
            return p
        elseif vim.fn.executable("python3") then
            return "python3"
        else
            return "python"
        end
    elseif vim.fn.executable("python3") then
        return "python3"
    else
        return "python"
    end
end

--- Gets the environment variables for the DAP configuration.
--- For LLDB configurations adds PYTHONPATH and LLDB_USE_NATIVE_PDB_READER
--- @return table<string, string>
local get_env_vars = function(opts)
    local vars = {}
    for k, v in pairs(vim.fn.environ()) do
        table.insert(vars, string.format("%s=%s", k, v))
    end
    if opts["lldb"] then
        vars.PYTHONPATH = "C:/Program Files/Python310/Lib"
        vars.LLDB_USE_NATIVE_PDB_READER = "yes"
    end
    return vars
end

local dap_adapters = {
    nlua = function(on_config, config)
        on_config({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
    end,
    cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
        options = {
            detached = OsCurrent == OS.WINDOWS,
        },
    },
    lldb = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
        name = "lldb",
    },
}

--- Wrapper for vim.fn.input with common presets.
---@param opts table<string, string>? passed through to vim.fn.input.
---@return fun(): string
local get_program = function(opts)
    return function()
        return vim.fn.input(vim.tbl_extend("force", {
            prompt = "Path to executable: ",
            default = vim.fn.getcwd() .. "/",
            completion = "file",
        }, opts or {}))
    end
end

local default_confs = {
    lua = {
        {
            name = "Attach to running Neovim instance",
            type = "nlua",
            request = "attach",
        },
    },
    c = {
        type = "lldb",
        request = "launch",
        env = get_env_vars({ lldb = true }),
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        runInTerminal = true,
    },
    odin = {
        type = "lldb",
        request = "launch",
        env = get_env_vars({ lldb = true }),
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        runInTerminal = true,
        preRunCommands = { "add-dsym ${workspaceFolderBasename}.pdb" },
        breakpointMode = "file",
    },
    python = {
        type = "python",
        request = "launch",
        args = { "-m", "debugpy.adapter" },
        justMyCode = false,
        pythonPath = get_python,
        stopAtEntry = true,
        console = "integratedTerminal",
    },
}

local dap_configurations = {
    lua = default_confs.lua,
    c = {
        vim.tbl_extend("force", default_confs.c, {
            name = "[LLDB] Launch ./build/" .. vim.uv.cwd():match(".*[/\\](.*)"),
            program = "${workspaceFolder}/build/${workspaceFolderBasename}",
        }),
        vim.tbl_extend("force", default_confs.c, {
            name = "[LLDB] Launch ./build/Debug/" .. vim.uv.cwd():match(".*[/\\](.*)"),
            program = "${workspaceFolder}/build/Debug/${workspaceFolderBasename}",
        }),
        vim.tbl_extend("force", default_confs.c, {
            name = "[LLDB] Custom",
            program = get_program(),
        }),
        vim.tbl_extend("force", default_confs.c, {
            name = "[GDB] Attach to gdbserver :1234",
            type = "cppdbg",
            MIMode = "gdb",
            miDebuggerServerAddress = "localhost:1234",
            miDebuggerPath = "/usr/bin/gdb",
            program = get_program(),
        }),
    },
    odin = {
        vim.tbl_extend("force", default_confs.odin, {
            name = "Launch ./" .. vim.uv.cwd():match(".*[/\\](.*)"),
            program = "${workspaceFolderBasename}",
        }),
        setmetatable(vim.tbl_extend("force", default_confs.odin, { name = "Custom" }), {
            __call = function()
                local path = get_program()()
                return {
                    program = path,
                }
            end,
        }),
    },
    python = {
        vim.tbl_extend("force", default_confs.python, { name = "Current File", program = "${file}" }),
        vim.tbl_extend("force", default_confs.python, {
            name = "Current Module",
            program = "${fileDirname}",
            args = { "-m", "debugpy.adapter", "-m" },
        }),
        vim.tbl_extend(
            "force",
            default_confs.python,
            { name = "Current Package", program = "${workspaceFolderBasename}/${workspaceFolderBasename}/__init__.py" }
        ),
        vim.tbl_extend(
            "force",
            default_confs.python,
            { name = "SVCP", program = "${workspaceFolder}/svcp/__init__.py" }
        ),
        vim.tbl_extend("force", default_confs.python, {
            name = "Custom",
            program = get_program({ prompt = "Path to script: " }),
        }),
    },
}

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "nvim-telescope/telescope-dap.nvim",
        "jbyuki/one-small-step-for-vimkind",
        "mfussenegger/nvim-dap-python",
        "ofirgall/goto-breakpoints.nvim",
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {
                highlight_new_as_changed = false,
                show_stop_reason = true,
                only_first_definition = false,
                all_references = true,
                all_frames = true,
                virt_text_pos = "eol",
            },
        },
    },
    config = function()
        local dap = require("dap")

        dap.defaults.fallback.terminal_win_cmd = "tabnew"
        -- dap.set_log_level("TRACE")

        dap.listeners.before.attach["dap_keymaps"] = require("settings.keymaps").set_dap_keymaps
        dap.listeners.before.launch["dap_keymaps"] = require("settings.keymaps").set_dap_keymaps
        dap.listeners.before.event_terminated["dap_keymaps"] = require("settings.keymaps").del_dap_keymaps
        dap.listeners.before.event_exited["dap_keymaps"] = require("settings.keymaps").del_dap_keymaps

        require("dap-python").setup(
            vim.fn.stdpath("data")
            .. "/mason/packages/debugpy/venv/"
            .. (OsCurrent == OS.WINDOWS and "Scripts/python" or "bin/python"),
            {
                console = "integratedTerminal",
            }
        )

        dap.adapters = vim.tbl_extend("force", dap.adapters, dap_adapters)
        dap.configurations = vim.tbl_extend("force", dap.configurations, dap_configurations)
        dap.configurations.cpp = dap.configurations.c

        vim.fn.sign_define(
            "DapBreakpoint",
            { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "DiagnosticSignError" }
        )
        vim.fn.sign_define("DapStopped", { text = "", texthl = "String", linehl = "CursorLine", numhl = "String" })

        local repl = require("dap.repl")
        repl.commands = vim.tbl_extend("force", repl.commands, {
            custom_commands = {
                [".d"] = function()
                    dap.repl.execute("disassemble")
                end,
            },
        })
    end,
}
