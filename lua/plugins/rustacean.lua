return {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
        vim.g.rustaceanvim = function()
            local extension_path = vim.fn.stdpath("data")
                .. (
                    OsCurrent == Os.WINDOWS and "\\mason\\packages\\codelldb\\extension\\"
                    or "/mason/packages/codelldb/extension/"
                )
            local codelldb_path = extension_path
                .. (OsCurrent == Os.WINDOWS and "adapter\\codelldb.exe" or "adapter/codelldb")
            local liblldb_path

            if OsCurrent == Os.WINDOWS then
                liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
            elseif OsCurrent == Os.LINUX then
                liblldb_path = extension_path .. "lldb/lib/liblldb.so"
            else
                liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
            end

            return {
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
        end
    end,
}
