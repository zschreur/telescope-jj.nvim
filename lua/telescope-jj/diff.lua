local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")
local utils = require("telescope-jj.utils")

return function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or utils.get_jj_root()
    if opts.cwd == nil then
        return
    end

    local cmd = { "jj", "diff", "--name-only", "--no-pager" }
    local cmd_output = utils.get_os_command_output(cmd, opts.cwd)

    pickers
        .new(opts, {
            prompt_title = "Jujutsu Diff",
            __locations_input = true,
            finder = finders.new_table({
                results = cmd_output,
                entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
            }),
            previewer = utils.diff_previwer.new(opts),
            sorter = conf.file_sorter(opts),
        })
        :find()
end
