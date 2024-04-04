local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
    error('This plugins requires nvim-telescope/telescope.nvim')
end

return telescope.register_extension {
    setup = function(ext_config, config)
        -- access extension config and user config
    end,
    exports = require("jj")
}
