return {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
        local data_path = vim.fn.stdpath("data")
        local extension_path, codelldb_path, liblldb_path
        if OsCurrent == OS.WINDOWS then
            extension_path = data_path .. "\\mason\\packages\\codelldb\\extension\\"
            codelldb_path = extension_path .. "adapter\\codelldb.exe"
            liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
        else
            extension_path = data_path .. "/mason/packages/codelldb/extension/"
            codelldb_path = extension_path .. "adapter/codelldb"
            liblldb_path = extension_path .. "lldb/lib/liblldb." .. (OsCurrent == OS.LINUX and "so" or "dylib")
        end
        vim.g.rustaceanvim = {
            server = {
                on_attach = function(client, bufnr)
                    require("settings.keymaps").set_rust_keymaps(client, bufnr)
                end,
                cmd = function()
                    local mason_registry = require("mason-registry")
                    if mason_registry.is_installed("rust-analyzer") then
                        -- This may need to be tweaked depending on the operating system.
                        local ra = mason_registry.get_package("rust-analyzer")
                        local ra_filename = ra:get_receipt():get().links.bin["rust-analyzer"]
                        return { ("%s/%s"):format(ra:get_install_path(), ra_filename or "rust-analyzer") }
                    else
                        -- global installation
                        return { "rust-analyzer" }
                    end
                end,
            },
            dap = {
                adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
            },
        }
    end,
}
