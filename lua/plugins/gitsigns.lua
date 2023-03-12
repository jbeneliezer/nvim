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
					name = "Gitsigns",
					s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk", mode = { "n", "v" } },
					r = { "Gitsigns reset_hunk<CR>", "Reset Hunk", mode = { "n", "v" } },
					S = { gs.stage_buffer, "Stage Buffer" },
					u = { gs.undo_stage_hunk, "Undo Stage Hunk" },
					R = { gs.reset_buffer, "Reset Buffer" },
					p = { gs.preview_hunk, "Preview Hunk" },
					b = { gs.toggle_current_line_blame, "Toggle Blame" },
					d = { gs.diffthis, "Diff" },
					D = {
						function()
							gs.diffthis("~")
						end,
						"Diff with Head",
					},
					x = { gs.toggle_deleted, "Toggle Deleted" },
				},
			}, { prefix = "<leader>", buffer = bufnr })
		end,
	},
}