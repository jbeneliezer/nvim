local servers = {
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
            "--background-index",
            "--clang-tidy",
            "--completion-style=bundled",
            "--enable-config",
            "--fallback-style=file:"
            .. vim.fn.stdpath("config")
            .. (OsCurrent == OS.WINDOWS and "\\.clang-format" or "/.clang-format"),
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
                lint = {
                    enable = true,
                    extendSelect = { "I" },
                    ignore = { "F", "E741" },
                },
                organizeImports = true,
                showSyntaxErrors = false,
            },
        },
    },
    rust_analyzer = {},
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
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_enable = { exclude = { "rust_analyzer" } },
            })

            vim.lsp.config("*", {
                capabilities = vim.tbl_deep_extend(
                    "force",
                    vim.lsp.protocol.make_client_capabilities() or {},
                    require("cmp_nvim_lsp").default_capabilities() or {}
                ),
            })

            for k, v in pairs(servers) do
                if k ~= "rust_analyzer" then
                    vim.lsp.config(k, v)
                end
            end
        end,
    },
    {
        "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
        config = function()
            require("toggle_lsp_diagnostics").init(vim.diagnostic.config())
        end,
    },
}
