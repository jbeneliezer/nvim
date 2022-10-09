local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
	return
end

local dap_ui_status_ok, dapui = pcall(require, "dapui")
if not dap_ui_status_ok then
	return
end

local dap_virtual_status, virtual = pcall(require, "nvim-dap-virtual-text")
if not dap_virtual_status then
	return
end

local json5_ok, json5 = pcall(require, "json5")
if not json5_ok then
	return
end

-- Cppdbg
dap.ext.vscode.json_decode = json5.parse
dap.ext.vscode.load_launchjs(nil, { cppdbg = {'c', 'cpp'} })

vim.g.dap_virtual_text = true

dap.adapters.cpp = {
	type = "executable",
	attach = {
		pidProperty = "pid",
		pidSelect = "ask",
	},
	command = "gdb",
	name = "gdb",
}

--[[ dap.configurations.cpp = { ]]
--[[ 	{ ]]
--[[ 		name = "gdb", ]]
--[[ 		type = "cpp", ]]
--[[ 		request = "launch", ]]
--[[ 		program = function() ]]
--[[ 			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") ]]
--[[ 		end, ]]
--[[ 		cwd = "${workspaceFolder}", ]]
--[[ 		externalTerminal = false, ]]
--[[ 		stopOnEntry = false, ]]
--[[ 		args = {}, ]]
--[[ 	}, ]]
--[[ } ]]

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

virtual.setup({
	enabled = true, -- enable this plugin (the default)
	enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
	highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
	highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
	show_stop_reason = true, -- show stop reason when stopped for exceptions
	commented = false, -- prefix virtual text with comment string
	only_first_definition = false, -- only show virtual text at first definition (if there are multiple)
	all_references = false, -- show virtual text on all references of the variable (not only definitions)
	filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
	-- experimental features:
	virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
	all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
	virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
	virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
	-- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
})

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end
