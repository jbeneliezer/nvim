return {
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
			keymap("n", "]c", function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					gs.next_hunk()
				end)
				return "<Ignore>"
			end, { expr = true })

			keymap("n", "[c", function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gs.prev_hunk()
				end)
				return "<Ignore>"
			end, { expr = true })

			-- Text object
			keymap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")

			local wk = require("which-key")
			wk.register({
				g = {
					name = "Git",
					j = { require("gitsigns").next_hunk, "Next Hunk" },
					k = { require("gitsigns").prev_hunk, "Prev Hunk" },
					t = { require("gitsigns").blame_line, "Blame" },
					p = { require("gitsigns").preview_hunk, "Preview Hunk" },
					r = { require("gitsigns").reset_hunk, "Reset Hunk" },
					R = { require("gitsigns").reset_buffer, "Reset Buffer" },
					s = { require("gitsigns").stage_hunk, "Stage Hunk" },
					S = { require("gitsigns").stage_buffer, "Stage Buffer" },
					d = { require("gitsigns").diffthis, "Diff" },
					D = {
						function()
							require("gitsigns").diffthis("~")
						end,
						"Diff with Head",
					},
				},
			}, { prefix = "<leader>", buffer = bufnr, mode = { "n", "v" } })
		end,
	},
}
