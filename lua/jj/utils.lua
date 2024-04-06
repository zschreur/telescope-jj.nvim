local ts_utils = require("telescope.utils")

local get_jj_root = function()
    local root, ret = ts_utils.get_os_command_output({ "jj", "root" })
    if ret == 0 then
        return root[1]
    end

    error("jj root not found")
end

return {
    get_jj_root = get_jj_root,
    get_os_command_output = ts_utils.get_os_command_output
}
