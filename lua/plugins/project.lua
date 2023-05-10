return {
	"ahmedkhalf/project.nvim",
	config = function()
		require("project_nvim").setup({
			patterns = {
				".git",
				"_darcs",
				".hg",
				".bzr",
				".svn",
				"Makefile",
				"package.json",
				">branches",
				">branch",
				">tags",
				"venv",
				"=Source",
			},
			silent_chdir = true,
		})
	end,
}
