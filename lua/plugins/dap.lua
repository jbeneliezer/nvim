local get_python = function()
	local venv = vim.fn.getenv("VIRTUAL_ENV")
	if vim.loop.os_uname().sysname == "Windows_NT" then
		if venv ~= nil and vim.fn.executable(venv .. "/Scripts/python") then
			return venv .. "/Scripts/python"
		else
			return "python"
		end
	elseif venv ~= nil and vim.fn.executable(venv .. "/bin/python") then
		return venv .. "/bin/python"
	else
		return "python"
	end
end

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-telescope/telescope-dap.nvim",
		"folke/neodev.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"Joakker/lua-json5",
		"jbyuki/one-small-step-for-vimkind",
		"mfussenegger/nvim-dap-python",
		"nvim-neotest/neotest",
		"nvim-neotest/neotest-python",
		"ofirgall/goto-breakpoints.nvim",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local dap_vtext = require("nvim-dap-virtual-text")

		-- Use "tabnew" for all debug adapters
		dap.defaults.fallback.terminal_win_cmd = "tabnew"

		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = "█", texthl = "DiagnosticSignError", linehl = "", numhl = "DiagnosticSignError" }
		)
		vim.fn.sign_define(
			"DapStopped",
			{ text = "", texthl = "String", linehl = "CursorLine", numhl = "CursorLine" }
		)

		dap.listeners.before["event_terminated"]["my-plugin"] = function(session, body)
			print("Session terminated", vim.inspect(session), vim.inspect(body))
		end

		dap.adapters.nlua = function(callback, config)
			callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
		end

		if vim.loop.os_uname().sysname == "Linux" then
			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
			}
		elseif vim.loop.os_uname().sysname == "Windows_NT" then
			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command =
				"C:\\Users\\jb\\AppData\\Local\\cpptools-win64\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe",
				options = {
					detached = false,
				},
			}
		end

		if vim.loop.os_uname().sysname == "Linux" then
			require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
		elseif vim.loop.os_uname().sysname == "Windows_NT" then
			require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/Scripts/python", {
				console = "integratedTerminal",
			})
		end

		dap.configurations.lua = {
			{
				name = "Attach to running Neovim instance",
				type = "nlua",
				request = "attach",
			},
		}

		dap.configurations.c = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
			},
			{
				name = "Attach to gdbserver :1234",
				type = "cppdbg",
				request = "launch",
				MIMode = "gdb",
				miDebuggerServerAddress = "localhost:1234",
				miDebuggerPath = "/usr/bin/gdb",
				cwd = "${workspaceFolder}",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
			},
			{
				name = "Attach to gdbserver :1234",
				type = "cppdbg",
				request = "launch",
				MIMode = "gdb",
				miDebuggerServerAddress = "localhost:1234",
				miDebuggerPath = "/usr/bin/gdb",
				cwd = "${workspaceFolder}",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				stopAtEntry = true,
			},
		}

		dap.configurations.rust = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable", vim.fn.getcwd() .. "/target/debug/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
			},
		}

		dap.configurations.python = {
			{
				name = "File",
				type = "python",
				request = "launch",
				program = "${file}",
				args = { "-m", "debugpy.adapter" },
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
				pythonPath = get_python,
				stopAtEntry = true,
				console = "integratedTerminal",
			},
		}

		require("neodev").setup({
			library = {
				plugins = { "nvim-dap-ui" },
				types = true,
			},
		})

		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					dap = {
						justMyCode = false,
						console = "integratedTerminal",
					},
					args = { "--log-level", "DEBUG", "--quiet" },
					runner = "pytest",
					python = get_python,
				}),
			},
		})

		dapui.setup({
			layouts = {
				{
					elements = {
						{ id = "scopes",      size = 0.34 },
						{ id = "breakpoints", size = 0.33 },
						{ id = "watches",     size = 0.33 },
					},
					size = 10,
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

		dap_vtext.setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			only_first_definition = false,
			all_references = false,
			display_callback = function(variable, _buf, _stackframe, _node)
				return variable.name .. " = " .. variable.value
			end,
			virt_text_pos = "eol",
			all_frames = false,
			virt_lines = false,
			virt_text_win_col = nil,
		})
	end,
}
