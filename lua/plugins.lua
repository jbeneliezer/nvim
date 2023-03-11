local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme gruvbox")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				show_current_context = true,
				show_current_context_start = true,
			})

			vim.cmd("hi IndentBlanklineContextStart guisp=#000000 gui=nocombine")

			vim.api.nvim_create_autocmd({ "Colorscheme" }, {
				desc = "remove underline from context start",
				command = "hi IndentBlanklineContextStart guisp=#000000 gui=nocombine",
				group = vim.api.nvim_create_augroup("RemoveUnderline", { clear = true }),
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "rust", "lua", "vim", "help", "query" },
				auto_install = true,
				highlight = { enable = true, }
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = true,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip/loaders/from_vscode").lazy_load()

			local check_backspace = function()
				local col = vim.fn.col(".") - 1
				return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
			end

			local kind_icons = {
				Text = "",
				Method = "m",
				Function = "",
				Constructor = "",
				Field = "",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "",
				Event = "",
				Operator = "",
				TypeParameter = "",
			}
			-- find more here: https://www.nerdfonts.com/cheat-sheet

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end
				},
				mapping = {
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
					["<C-e>"] = cmp.mapping({
						i = cmp.mapping.abort(),
						c = cmp.mapping.close(),
					}),
					-- Accept currently selected item. If none selected, `select` first item.
					-- Set `select` to `false` to only confirm explicitly selected items.
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expandable() then
							luasnip.expand()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif check_backspace() then
							fallback()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						-- Kind icons
						vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
						-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
						vim_item.menu = ({
							--[[ cmp_tabnine = "Tab9", ]]
							--[[ copilot = "Cop", ]]
							nvim_lua = "[Nvim]",
							nvim_lsp = "[Lsp]",
							luasnip = "[Snip]",
							buffer = "[Buf]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				sources = {
					--[[ { name = "cmp_tabnine" }, ]]
					--[[ { name = "copilot" }, ]]
					{ name = "nvim_lua" },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},
				experimental = {
					ghost_text = true,
					native_menu = false,
				},
				window = {
					completion = {
						border = "rounded",
						scrollbar = "|",
					},
					documentation = {
						border = "rounded",
					},
				},
			})
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = "hrsh7th/nvim-cmp",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0, -- Offset from pattern match
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})

			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
		end,
	},

	-- Lsp
	{
		"williamboman/mason.nvim",
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "bashls", "rust_analyzer" }
			})
		end,
	},
	{
		"WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
		config = function()
			require("toggle_lsp_diagnostics").init(vim.diagnostic.config())
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("lsp").setup()
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		opts = { direction = "tab" },
	},
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({
				plugins = {
					presets = {
						operators = false,
						text_objects = false,
						g = false,
					},
				},
			})
		end
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local keymap = function(mode, lhs, rhs, opts, description)
					local local_opts = opts or { noremap = true, silent = true, buffer = bufnr }
					local_opts["desc"] = description or "which_key_ignore"
					vim.keymap.set(mode, lhs, rhs, local_opts)
					-- end
				end

				-- Navigation
				keymap('n', ']c', function()
					if vim.wo.diff then return ']c' end
					vim.schedule(function() gs.next_hunk() end)
					return '<Ignore>'
				end, { expr = true })

				keymap('n', '[c', function()
					if vim.wo.diff then return '[c' end
					vim.schedule(function() gs.prev_hunk() end)
					return '<Ignore>'
				end, { expr = true })

				-- Text object
				keymap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

				local wk = require("which-key")
				wk.register({
					g = {
						name = "Gitsigns",
						s = { '<cmd>Gitsigns stage_hunk<cr>', 'Stage Hunk', mode = { "n", "v" } },
						r = { 'Gitsigns reset_hunk<CR>', 'Reset Hunk', mode = { "n", "v" } },
						S = { gs.stage_buffer, 'Stage Buffer' },
						u = { gs.undo_stage_hunk, 'Undo Stage Hunk' },
						R = { gs.reset_buffer, 'Reset Buffer' },
						p = { gs.preview_hunk, 'Preview Hunk' },
						b = { gs.toggle_current_line_blame, 'Toggle Blame' },
						d = { gs.diffthis, 'Diff' },
						D = { function() gs.diffthis('~') end, 'Diff with Head' },
						x = { gs.toggle_deleted, "Toggle Deleted" },
					},
				}, { prefix = "<leader>", buffer = bufnr })
			end,
		},
	},
	{
		"tpope/vim-fugitive",
	},
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({ easing_function = "sine" })

			local mappings = {
				['<C-u>'] = { 'scroll', { '-vim.wo.scroll', 'true', '100' } },
				['<C-d>'] = { 'scroll', { 'vim.wo.scroll', 'true', '100' } },
				['K']     = { 'scroll', { '-vim.wo.scroll', 'true', '100' } },
				['J']     = { 'scroll', { 'vim.wo.scroll', 'true', '100' } },
				['<C-b>'] = { 'scroll', { '-vim.api.nvim_win_get_height(0)', 'true', '450' } },
				['<C-f>'] = { 'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '450' } },
				-- ['<C-y>'] = {'scroll', {'-0.10', 'false', '100'}},
				-- ['<C-e>'] = {'scroll', { '0.10', 'false', '100'}},
				['zt']    = { 'zt', { '250' } },
				['zz']    = { 'zz', { '250' } },
				['zb']    = { 'zb', { '250' } },
			}
			require("neoscroll.config").set_mappings(mappings)
		end,
	},
	{
		"cbochs/grapple.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"akinsho/bufferline.nvim",
		tag = "v3.5.0",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = {
					-- numbers = function(opts)
					-- 	local key = require("grapple").key(opts.id)
					-- 	if key ~= nil then
					-- 		return string.format("%d", key)
					-- 	else
					-- 		return ""
					-- 	end
					-- end,
					numbers = "ordinal",
					indicator = { style = "none", },
					diagnostics = "nvim_lsp",
					show_buffer_close_icons = false,
					show_close_icon = false,
					-- separator_style = { ")", ")" },
					-- separator_style = { "", "" },
					separator_style = { "", "" },
				}
			})
		end,
	},
}

require("lazy").setup(plugins)
