local ts_utils = require("telescope.utils")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")

local get_jj_root = function()
    local root, ret = ts_utils.get_os_command_output({ "jj", "root" })
    if ret == 0 then
        return root[1]
    end

    error("jj root not found")
end

local function defaulter(f, default_opts)
    default_opts = default_opts or {}
    return {
        new = function(opts)
            if conf.preview == false and not opts.preview then
                return false
            end
            opts.preview = type(opts.preview) ~= "table" and {} or opts.preview
            if type(conf.preview) == "table" then
                for k, v in pairs(conf.preview) do
                    opts.preview[k] = vim.F.if_nil(opts.preview[k], v)
                end
            end
            return f(opts)
        end,
        __call = function()
            local ok, err = pcall(f(default_opts))
            if not ok then
                error(debug.traceback(err))
            end
        end,
    }
end

local diff_previwer = defaulter(function(opts)
    return previewers.new_buffer_previewer({
        title = "JJ File Diff Preview",
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,

        define_preview = function(self, entry)
            local diff_cmd = { "jj", "diff", "--git", "--no-pager", "--", entry.value }
            putils.job_maker(diff_cmd, self.state.bufnr, {
                value = entry.value,
                bufname = self.state.bufname,
                cwd = opts.cwd,
                callback = function(bufnr)
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        putils.highlighter(bufnr, "diff", opts)
                    end
                end,
            })
        end,
    })
end, {})

return {
    get_jj_root = get_jj_root,
    get_os_command_output = ts_utils.get_os_command_output,
    diff_previwer = diff_previwer,
}
