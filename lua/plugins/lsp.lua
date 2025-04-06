local servers = {
    ast_grep = {},
    lua_ls = {
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = { vim.env.VIMRUNTIME },
                    -- library = vim.api.nvim_get_runtime_file("", true)
                    checkThirdParty = false,
                },
                telemetry = { enable = false },
            },
        },
    },
    clangd = {
        cmd = {
            "clangd",
            "--compile_commands_dir=build",
            "--background-index",
            "--clang-tidy",
            "--completion-style=bundled",
            "--enable-config",
        },
        single_file_support = true,
    },
    pyright = {
        single_file_support = true,
        settings = {
            pyright = {
                disableLanguageServices = false,
                disableOrganizeImports = true,
            },
            python = {
                analysis = {
                    autoImportCompletions = true,
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    typeCheckingMode = "basic",
                    useLibraryCodeForTypes = true,
                },
            },
        },
    },
    ruff = {
        init_options = {
            settings = {
                configurationPreference = "filesystemFirst",
                exclude = {
                    "venv",
                    ".venv",
                    ".pytest_cache",
                    ".mypy_cache",
                    ".ruff_cache",
                    "__pycache__",
                    ".pyc$",
                },
                lineLength = 120,
                showSyntaxErrors = false,
                lint = {
                    -- enable = false,
                    ignore = { "F", "E741" },
                },
            },
        },
    },
}

local diag_icons = {
    [vim.diagnostic.severity.ERROR] = "",
    [vim.diagnostic.severity.WARN] = "",
    [vim.diagnostic.severity.HINT] = "",
    [vim.diagnostic.severity.INFO] = "",
}

local diag_config = {
    underline = true,
    virtual_text = {
        prefix = function(diagnostic, i, total)
            return i == total and diag_icons[diagnostic.severity] .. " " or ""
        end,
    },
    virtual_lines = false,
    signs = { text = diag_icons },
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
    update_in_insert = false,
    severity_sort = true,
}

return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.diagnostic.config(diag_config)
        end,
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ui = { border = "rounded" },
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_installation = { exclude = { "rust_analyzer" } },
            })

            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities() or {},
                require("cmp_nvim_lsp").default_capabilities() or {}
            )

            require("mason-lspconfig").setup_handlers({
                function(server_name)
                    if server_name == "rust_analyzer" then
                        return true
                    end
                    local server_opts = vim.tbl_deep_extend("force", {
                        capabilities = vim.deepcopy(capabilities),
                        on_attach = function(client, bufnr)
                            require("settings.keymaps").set_lsp_keymaps(client, bufnr)
                        end,
                    }, servers[server_name] or {})
                    require("lspconfig")[server_name].setup(server_opts)
                end,
            })
        end,
    },
    {
        "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
        config = function()
            require("toggle_lsp_diagnostics").init(vim.diagnostic.config())
        end,
    },
}
