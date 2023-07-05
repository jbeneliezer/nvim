return {
	"ahmedkhalf/project.nvim",
	event = "VimEnter",
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
				".venv",
                "pyproject.toml",
				"=Source",
			},
			silent_chdir = true,
		})
	end,
}
