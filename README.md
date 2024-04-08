A telescope picker for Jujutsu repos

# Setup

Require `telescope-jj.nvim` in your nvim package manager:

Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
"zschreur/telescope-jj.nvim",
```

Load the extension in your config with:
```lua
telescope.load_extension("jj")
```

Call with:
```lua
telescope.extensions.jj.files(opts) -- opts is optional telescope picker options
```

The example below includes a fallback to the default `git_files` picker if the `jj` picker fails.
```lua
local builtin = require("telescope.builtin")
local telescope = require("telescope")

telescope.load_extension("jj")

local vcs_picker = function(opts)
    local jj_pick_status, jj_res = pcall(telescope.extensions.jj.files, opts)
    if jj_pick_status then
        return
    end

    local git_files_status, git_res = pcall(builtin.git_files, opts)
    if not git_files_status then
        print(jj_res)
        print(git_res)
    end
end

vim.keymap.set("n", "<C-p>", vcs_picker, {})
```
