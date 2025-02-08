local function get_python()
    local venv = vim.fn.getenv("VIRTUAL_ENV")
    if venv ~= vim.NIL then
        if OsCurrent == Os.WINDOWS and vim.fn.executable(venv .. "/Scripts/python") then
            return venv .. "/Scripts/python"
        elseif OsCurrent == Os.LINUX and vim.fn.executable(venv .. "/bin/python") then
            return venv .. "/bin/python"
        else
            return "python"
        end
    else
        return "python"
    end
end

local function get_env_vars()
    return {
        PYTHONPATH = "C:/Program Files/Python310/Lib",
        LLDB_USE_NATIVE_PDB_READER = "yes",
    }
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
            detached = OsCurrent == Os.WINDOWS,
        },
    },
    lldb = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb.exe",
        name = "lldb",
    },
}

local dap_configurations = {
    lua = {
        {
            name = "Attach to running Neovim instance",
            type = "nlua",
            request = "attach",
        },
    },
    c = {
        {
            name = "[LLDB] Launch ./build/" .. vim.uv.cwd():match(".*[/\\](.*)") .. ".exe",
            type = "lldb",
            request = "launch",
            program = "${workspaceFolder}/build/${workspaceFolderBasename}.exe",
            env = get_env_vars(),
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            runInTerminal = true,
        },
        {
            name = "[LLDB] Launch ./build/Debug/" .. vim.uv.cwd():match(".*[/\\](.*)") .. ".exe",
            type = "lldb",
            request = "launch",
            program = "${workspaceFolder}/build/Debug/${workspaceFolderBasename}.exe",
            env = get_env_vars(),
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            runInTerminal = true,
        },
        {
            name = "[LLDB] Custom",
            type = "lldb",
            request = "launch",
            program = function()
                return vim.fn.input({
                    prompt = "Path to executable: ",
                    default = vim.fn.getcwd() .. "/",
                    completion = "file",
                })
            end,
            env = get_env_vars(),
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            runInTerminal = true,
        },
        {
            name = "[GDB] Attach to gdbserver :1234",
            type = "cppdbg",
            request = "launch",
            MIMode = "gdb",
            miDebuggerServerAddress = "localhost:1234",
            miDebuggerPath = "/usr/bin/gdb",
            cwd = "${workspaceFolder}",
            program = function()
                return vim.fn.input({
                    prompt = "Path to executable: ",
                    default = vim.fn.getcwd() .. "/",
                    completion = "file",
                })
            end,
        },
    },
    odin = {
        {
            name = "Launch ./" .. vim.uv.cwd():match(".*[/\\](.*)") .. ".exe",
            type = "lldb",
            request = "launch",
            program = "${workspaceFolderBasename}.exe",
            args = {},
            env = get_env_vars(),
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            runInTerminal = true,
            preRunCommands = { "add-dsym ${workspaceFolderBasename}.pdb" },
            breakpointMode = "file",
        },
        setmetatable({
            name = "Custom",
            type = "lldb",
            request = "launch",
            args = {},
            env = get_env_vars(),
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            runInTerminal = true,
        }, {
            __call = function()
                local path = vim.fn.input({
                    prompt = "Path to executable: ",
                    default = vim.fn.getcwd() .. "/",
                    completion = "file",
                })
                return {
                    program = path,
                }
            end,
        }),
    },
    rust = {
        {
            name = "Launch ./target/debug/" .. vim.uv.cwd():match(".*[/\\](.*)") .. ".exe",
            type = "lldb",
            request = "launch",
            program = "${workspaceFolder}/target/debug/${workspaceFolderBasename}.exe",
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
        },
        {
            name = "Custom",
            type = "lldb",
            request = "launch",
            program = function()
                return vim.fn.input({
                    prompt = "Path to executable",
                    default = vim.fn.getcwd() .. "/target/debug/",
                    completion = "file",
                })
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = true,
        },
    },
    python = {
        {
            name = "Current File",
            type = "python",
            request = "launch",
            program = "${file}",
            args = { "-m", "debugpy.adapter" },
            justMyCode = false,
            pythonPath = get_python,
            stopAtEntry = true,
            console = "integratedTerminal",
        },
        {
            name = "Current Module",
            type = "python",
            request = "launch",
            program = "${fileDirname}",
            args = { "-m", "debugpy.adapter", "-m" },
            justMyCode = false,
            pythonPath = get_python,
            stopAtEntry = true,
            console = "integratedTerminal",
        },
        {
            name = "Denali",
            type = "python",
            request = "launch",
            program = vim.fn.getcwd() .. "/Denali_SVCP/main.py",
            args = { "-m", "debugpy.adapter" },
            justMyCode = false,
            pythonPath = get_python,
            stopAtEntry = true,
            console = "integratedTerminal",
        },
        {
            name = "RTCU",
            type = "python",
            request = "launch",
            program = vim.fn.getcwd() .. "/svcp/__init__.py",
            args = { "-m", "debugpy.adapter" },
            justMyCode = false,
            pythonPath = get_python,
            stopAtEntry = true,
            console = "integratedTerminal",
        },
        {
            name = "Custom",
            type = "python",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            args = { "-m", "debugpy.adapter" },
            justMyCode = false,
            pythonPath = get_python,
            stopAtEntry = true,
            console = "integratedTerminal",
        },
    },
}

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "nvim-telescope/telescope-dap.nvim",
        "Joakker/lua-json5",
        "jbyuki/one-small-step-for-vimkind",
        "mfussenegger/nvim-dap-python",
        "ofirgall/goto-breakpoints.nvim",
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {
                highlight_new_as_changed = true,
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
        dap.set_log_level("TRACE")

        dap.listeners.before.attach.dap_keymaps = require("settings.keymaps").set_dap_keymaps
        dap.listeners.before.launch.dap_keymaps = require("settings.keymaps").set_dap_keymaps
        dap.listeners.before.event_terminated.dap_keymaps = require("settings.keymaps").del_dap_keymaps
        dap.listeners.before.event_exited.dap_keymaps = require("settings.keymaps").del_dap_keymaps

        require("dap-python").setup(
            vim.fn.stdpath("data")
            .. "/mason/packages/debugpy/venv/"
            .. (OsCurrent == Os.WINDOWS and "Scripts/python" or "bin/python"),
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
        vim.fn.sign_define(
            "DapStopped",
            { text = "", texthl = "String", linehl = "CursorLine", numhl = "CursorLine" }
        )

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