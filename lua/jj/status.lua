local from_entry = require("telescope.from_entry")
local putils = require("telescope.previewers.utils")
local diff_files = function(opts)
    return require("telescope.previewers").new_buffer_previewer({
        title = "JJ File Diff Preview",
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,

        define_preview = function(self, entry)
            if entry.status and (entry.status == "??" or entry.status == "A ") then
                local p = from_entry.path(entry, true, false)
                if p == nil or p == "" then
                    return
                end
                conf.buffer_previewer_maker(p, self.state.bufnr, {
                    bufname = self.state.bufname,
                    winid = self.state.winid,
                    preview = opts.preview,
                    file_encoding = opts.file_encoding,
                })
            else
                local cmd = utils.get_os_command_output(
                    { "jj", "diff", "--no-pager", entry.value },
                    opts.cwd
                )
                putils.job_maker(cmd, self.state.bufnr, {
                    value = entry.value,
                    bufname = self.state.bufname,
                    cwd = opts.cwd,
                    callback = function(bufnr)
                        if vim.api.nvim_buf_is_valid(bufnr) then
                            putils.highlighter(bufnr, "diff", opts)
                        end
                    end,
                })
            end
        end,
    })
end

local jj_show = function(opts)
    local cmd = { "jj", "show", "--summary", "--no-pager", "-T", '""' }

    local gen_new_finder = function()
        if vim.F.if_nil(opts.expand_dir, true) then
            table.insert(args, #args - 1, "-uall")
        end
        local git_cmd = git_command(args, opts)
        opts.entry_maker = vim.F.if_nil(opts.entry_maker, make_entry.gen_from_git_status(opts))
        return finders.new_oneshot_job(git_cmd, opts)
    end

    local initial_finder = gen_new_finder()
    if not initial_finder then
        return
    end

    pickers
        .new(opts, {
            prompt_title = "Git Status",
            finder = initial_finder,
            previewer = previewers.git_file_diff.new(opts),
            sorter = conf.file_sorter(opts),
            on_complete = {
                function(self)
                    local lines = self.manager:num_results()
                    local prompt = action_state.get_current_line()
                    if lines == 0 and prompt == "" then
                        utils.notify("builtin.git_status", {
                            msg = "No changes found",
                            level = "ERROR",
                        })
                        actions.close(self.prompt_bufnr)
                    end
                end,
            },
            attach_mappings = function(prompt_bufnr, map)
                actions.git_staging_toggle:enhance({
                    post = function()
                        local picker = action_state.get_current_picker(prompt_bufnr)

                        -- temporarily register a callback which keeps selection on refresh
                        local selection = picker:get_selection_row()
                        local callbacks = { unpack(picker._completion_callbacks) } -- shallow copy
                        picker:register_completion_callback(function(self)
                            self:set_selection(selection)
                            self._completion_callbacks = callbacks
                        end)

                        -- refresh
                        picker:refresh(gen_new_finder(), { reset_prompt = false })
                    end,
                })

                map({ "i", "n" }, "<tab>", actions.git_staging_toggle)
                return true
            end,
        })
        :find()
end
