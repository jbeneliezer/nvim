local servers = {
    lua_ls = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
    clangd = {
        cmd = {
            "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvarsall.bat x64;",
            "clangd",
            "--compile_commands_dir=build",
            "--background-index",
            "--clang-tidy",
            "--completion-style=bundled",
            "--enable-config",
        },
        single_file_support = true,
    },
    rust_analyzer = {},
    pyright = {
        single_file_support = true,
        settings = {
            pyright = {
                disableLanguageServices = false,
                disableOrganizeImports = false,
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
}

local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
}

local diag_config = {
    virtual_text = true,
    signs = {
        active = signs,
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
}

return {
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

            local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
            lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(lsp_capabilities)

            require("mason-lspconfig").setup_handlers({
                function(server_name)
                    if server_name == "rust_analyzer" then
                        return
                    end
                    require("lspconfig")[server_name].setup({
                        capabilities = lsp_capabilities,
                        on_attach = require("settings.keymaps").set_lsp_keymaps,
                        settings = servers[server_name],
                    })
                end,
            })

            require("rust-tools").inlay_hints.enable()
        end,
    },
    {
        "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
        config = function()
            require("toggle_lsp_diagnostics").init(vim.diagnostic.config())
        end,
    },
    {
        "simrat39/rust-tools.nvim",
        opts = {
            inlay_hints = {
                show_parameter_hints = true,
            },
            server = {
                on_attach = require("settings.keymaps").set_lsp_keymaps,
            },
            dap = {
                adapter = {
                    type = "executable",
                    command = "lldb-vscode",
                    name = "rt_lldb",
                },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            for _, sign in ipairs(signs) do
                vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
            end

            vim.diagnostic.config(diag_config)

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
                border = "rounded",
            })

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
                border = "rounded",
            })
        end,
    },
}