return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-context",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    event = "VimEnter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
    end,
    config = function()
        vim.filetype.add({
            extension = {
                vert = "vert",
                frag = "frag",
            }
        })
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "c", "rust", "lua", "vim", "vimdoc", "query", "python" },
            auto_install = true,
            highlight = { enable = true },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = { query = "@function.outer", desc = "Around Function" },
                        ["if"] = { query = "@function.inner", desc = "Inside Function" },
                        ["ac"] = { query = "@class.outer", desc = "Around Class" },
                        ["ic"] = { query = "@class.inner", desc = "Inside Class" },
                        ["al"] = { query = "@loop.outer", desc = "Around Loop" },
                        ["il"] = { query = "@loop.inner", desc = "Inside Loop" },
                        ["is"] = { query = "@scope", query_group = "locals", desc = "Inside Scope" },
                    },
                    selection_modes = {
                        ["@function.outer"] = "V",
                        ["@function.inner"] = "V",
                        ["@class.outer"] = "V",
                        ["@class.inner"] = "V",
                        ["@loop.outer"] = "V",
                        ["@loop.inner"] = "V",
                        ["@scope"] = "V",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]f"] = { query = "@function.outer", desc = "Function Start" },
                        ["]]"] = { query = "@class.outer", desc = "Class Start" },
                        ["]c"] = { query = "@class.outer", desc = "Class Start" },
                        ["]l"] = { query = "@loop.outer", desc = "Loop Start" },
                        ["]s"] = { query = "@scope", query_group = "locals", desc = "Scope Start" },
                    },
                    goto_next_end = {
                        ["]F"] = { query = "@function.outer", desc = "Function End" },
                        ["]["] = { query = "@class.outer", desc = "Class End" },
                        ["]C"] = { query = "@class.outer", desc = "Class End" },
                        ["]L"] = { query = "@loop.outer", desc = "Loop End" },
                        ["]S"] = { query = "@scope", query_group = "locals", desc = "Scope End" },
                    },
                    goto_previous_start = {
                        ["[f"] = { query = "@function.outer", desc = "Function Start" },
                        ["[]"] = { query = "@class.outer", desc = "Class Start" },
                        ["[c"] = { query = "@class.outer", desc = "Class Start" },
                        ["[l"] = { query = "@loop.outer", desc = "Loop Start" },
                        ["[s"] = { query = "@scope", query_group = "locals", desc = "Scope Start" },
                    },
                    goto_previous_end = {
                        ["[F"] = { query = "@function.outer", desc = "Function End" },
                        ["[["] = { query = "@class.outer", desc = "Class End" },
                        ["[C"] = { query = "@class.outer", desc = "Class End" },
                        ["[L"] = { query = "@loop.outer", desc = "Loop End" },
                        ["[S"] = { query = "@scope", query_group = "locals", desc = "Scope End" },
                    },
                },
            },
        })
        require("treesitter-context").setup({ max_lines = 5, multiline_threshold = 5 })
        vim.treesitter.language.register("glsl", "vert")
        vim.treesitter.language.register("glsl", "frag")
        vim.treesitter.language.register("verilog", "v")
    end,
}