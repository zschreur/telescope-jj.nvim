local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
    error("This plugins requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
    setup = function(ext_config, config)
        -- access extension config and user config
    end,
    exports = require("telescope-jj"),
    health = function()
        if vim.fn.executable("jj") == 1 then
            vim.health.ok("jj installed")
        end

        local obj = vim.system({ "jj", "--version" }, { text = true }):wait()
        for major, minor, patch in string.gmatch(obj.stdout, "jj (%d+).(%d+).(%d+)") do
            if not (tonumber(major) == 0 and tonumber(minor) >= 19) then
                vim.health.warn("requires jj version 0.19.0 or greater")
                vim.health.info("found jj version: " .. major .. "." .. minor .. "." .. patch)
            else
                vim.health.ok(
                    "jj version " .. major .. "." .. minor .. "." .. patch .. " is supported"
                )
            end
        end
    end,
})
