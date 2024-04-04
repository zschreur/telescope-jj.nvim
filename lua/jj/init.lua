local builtin = require "telescope.builtin"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local utils = require "telescope.utils"
local conf = require("telescope.config").values

local M = {}

local set_opts_cwd = function(opts)
    if opts.cwd then
        opts.cwd = vim.fn.expand(opts.cwd)
    else
        opts.cwd = vim.loop.cwd()
    end

    -- Find root of git directory and remove trailing newline characters
    local jj_root, ret = utils.get_os_command_output({ "jj", "root" }, opts.cwd)
    local use_git_root = vim.F.if_nil(opts.use_git_root, true)

    if ret == 0 and use_git_root then
        opts.cwd = jj_root[1]
    end
end

local jj_files = function(opts)
    opts = opts or {}
    set_opts_cwd(opts)
    pickers.new(opts, {
        prompt_title = "Jujutsu Files",
        finder = finders.new_table {
            results = utils.get_os_command_output({ "jj", "files", "--no-pager" }, opts.cwd),
        },
        previewer = conf.file_previewer(opts),
        sorter = conf.file_sorter(opts),
    }):find()
end

local is_jj_repo = function()
    local _, ret = utils.get_os_command_output({ "jj", "root" })
    return ret == 0
end

local vcs_picker = function(opts)
    if is_jj_repo() then
        return jj_files(opts)
    end
    local status, res = pcall(builtin.git_files, opts);

    if not status then
        print(res)
    end
end

M.pick = jj_files

return M
