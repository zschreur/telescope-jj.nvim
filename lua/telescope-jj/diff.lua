local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local utils = require("telescope-jj.utils")

local status_map = {
    A = { icon = "A", hl = "TelescopeJJStatusAdded" },
    M = { icon = "M", hl = "TelescopeJJStatusModified" },
    D = { icon = "D", hl = "TelescopeJJStatusDeleted" },
    R = { icon = "R", hl = "TelescopeJJStatusRenamed" },
}

local function setup_highlights()
    local links = {
        TelescopeJJStatusAdded = "diffAdded",
        TelescopeJJStatusModified = "diffChanged",
        TelescopeJJStatusDeleted = "diffRemoved",
        TelescopeJJStatusRenamed = "DiagnosticInfo",
    }
    for group, link in pairs(links) do
        vim.api.nvim_set_hl(0, group, { link = link, default = true })
    end
end

local function parse_summary_line(line)
    local status = line:sub(1, 1)
    local rest = line:sub(3)
    if status == "R" then
        local old, new = rest:match("^{(.*) => (.*)}$")
        if old and new then
            return status, new, old
        end
    end
    return status, rest, nil
end

local function make_diff_entry_maker(opts)
    local has_devicons, devicons = pcall(require, "nvim-web-devicons")

    local icon_width = 0
    if has_devicons then
        icon_width = 2
    end

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 1 },
            { width = icon_width },
            { remaining = true },
        },
    })

    return function(line)
        local status, filename, old_name = parse_summary_line(line)
        local info = status_map[status] or { icon = status, hl = "Comment" }

        local display_name = filename
        if old_name then
            display_name = old_name .. " => " .. filename
        end

        local file_icon, icon_hl
        if has_devicons then
            file_icon, icon_hl = devicons.get_icon(filename, nil, { default = true })
        end

        return {
            value = filename,
            ordinal = filename,
            display = function()
                if has_devicons then
                    return displayer({
                        { info.icon, info.hl },
                        { file_icon, icon_hl },
                        display_name,
                    })
                end
                return displayer({
                    { info.icon, info.hl },
                    "",
                    display_name,
                })
            end,
            filename = filename,
            jj_status = status,
            jj_old_name = old_name,
        }
    end
end

return function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or utils.get_jj_root()
    if opts.cwd == nil then
        return
    end

    setup_highlights()

    local cmd = { "jj", "diff", "--summary", "--no-pager" }
    local prompt_title = "Jujutsu Diff"

    if opts.revision then
        table.insert(cmd, "-r")
        table.insert(cmd, opts.revision)
        prompt_title = "Jujutsu Diff (" .. opts.revision .. ")"
    elseif opts.from or opts.to then
        if opts.from then
            table.insert(cmd, "--from")
            table.insert(cmd, opts.from)
        end
        if opts.to then
            table.insert(cmd, "--to")
            table.insert(cmd, opts.to)
        end
        local from_str = opts.from or "@"
        local to_str = opts.to or "@"
        prompt_title = "Jujutsu Diff (" .. from_str .. " → " .. to_str .. ")"
    end

    local cmd_output = utils.get_os_command_output(cmd, opts.cwd)

    pickers
        .new(opts, {
            prompt_title = prompt_title,
            __locations_input = true,
            finder = finders.new_table({
                results = cmd_output,
                entry_maker = opts.entry_maker or make_diff_entry_maker(opts),
            }),
            previewer = utils.diff_previwer.new(opts),
            sorter = conf.file_sorter(opts),
        })
        :find()
end
