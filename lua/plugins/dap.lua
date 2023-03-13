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
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local dap_vtext = require("nvim-dap-virtual-text")
		-- local json5 = require("json5")

		dap.adapters.nlua = function(callback, config)
			callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
		end

		if OS() == "Linux" then
			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command = "/home/jb/.local/bin/cpptools-linux/extension/debugAdapters/bin/OpenDebugAD7",
			}
		elseif OS() == "Windows_NT" then
			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				command = "C:\\Users\\jb\\AppData\\Local\\cpptools-win64\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe",
				options = {
					detached = false,
				},
			}
		end

		require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")

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
				type = "python",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				pythonPath = function()
					-- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
					-- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
					-- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
					local cwd = vim.fn.getcwd()
					if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
						return cwd .. "/venv/bin/python"
					elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
						return cwd .. "/.venv/bin/python"
					else
						return "/usr/bin/python"
					end
				end,
			},
		}

		require("neodev").setup({
			library = {
				plugins = { "nvim-dap-ui" },
				types = true,
			},
		})

		dapui.setup({
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.33 },
						{ id = "breakpoints", size = 0.33 },
						{ id = "watches", size = 0.33 },
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						"console",
					},
					size = 10,
					position = "bottom",
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
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapStopped",
			{ text = "", texthl = "String", linehl = "CursorLine", numhl = "CursorLine" }
		)

		dap.listeners.before["event_terminated"]["my-plugin"] = function(session, body)
			print("Session terminated", vim.inspect(session), vim.inspect(body))
		end
	end,
}
