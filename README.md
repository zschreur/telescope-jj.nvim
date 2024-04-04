A telescope picker for Jujutsu repos

# Setup

Require `jj_telescope` in your nvim package manager:

Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
    "zschreur/jj_telescope",
```

Load the extension in your config with:
```lua
telescope.load_extension "jj"
```

The example below includes a fallback to the default `git_files` picker if the `jj` picker fails.
```lua
local telescope = require "telescope"
local builtin = require "telescope.builtin"

telescope.load_extension "jj"

local vcs_picker = function(opts)
    local jj_pick_status, jj_res = pcall(telescope.extensions.jj.pick, opts);
    if jj_pick_status then
        return
    end

    local git_files_status, git_res = pcall(builtin.git_files, opts);
    if not git_files_status then
        print(jj_res)
        print(git_res)
    end
end

vim.keymap.set("n", "<C-p>", vcs_picker, {})
```
