local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")
local utils = require("jj.utils")

return function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or utils.get_jj_root()
    if opts.cwd == nil then
        return
    end

    local cmd = { "jj", "resolve", "--list" }
    local cmd_output = utils.get_os_command_output(cmd)

    local results = {}
    for _, str in ipairs(cmd_output) do
        -- https://github.com/martinvonz/jj/blob/9a5b001d58353afb7ea6cb894c22d80878b811ae/cli/src/cli_util.rs#L1778
        local word = string.match(str, "^(.-)%s%s%s")
        table.insert(results, word)
    end

    pickers
        .new(opts, {
            prompt_title = "Jujutsu Conflicts",
            __locations_input = true,
            finder = finders.new_table({
                results = results,
                entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.file_sorter(opts),
        })
        :find()
end
