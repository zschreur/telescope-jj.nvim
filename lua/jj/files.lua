local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")
local utils = require("jj.utils")

return function(opts)
    local cmd = { "jj", "files", "--no-pager" }
    opts = opts or {}
    opts.cwd = opts.cwd or utils.get_jj_root()
    pickers
        .new(opts, {
            prompt_title = "Jujutsu Files",
            __locations_input = true,
            finder = finders.new_table({
                results = utils.get_os_command_output(cmd),
                entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.file_sorter(opts),
        })
        :find()
end
