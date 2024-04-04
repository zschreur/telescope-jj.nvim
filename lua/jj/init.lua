local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local utils = require "telescope.utils"
local conf = require("telescope.config").values

local M = {}

local get_jj_root = function()
    local root, ret = utils.get_os_command_output({ "jj", "root" })
    if ret == 0 then
        return root[1]
    end

    error("jj root not found")
end

local jj_files = function(opts)
    local cmd = { "jj", "files", "--no-pager" };
    opts = opts or {}
    opts.cwd = opts.cwd or get_jj_root()
    pickers.new(opts, {
        prompt_title = "Jujutsu Files",
        finder = finders.new_table {
            results = utils.get_os_command_output(cmd, opts.cwd),
        },
        previewer = conf.file_previewer(opts),
        sorter = conf.file_sorter(opts),
    }):find()
end

M.files = jj_files

return M
