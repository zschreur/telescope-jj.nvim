# telescope-jj.nvim

A Telescope picker for Jujutsu repos.

## Setup
- Follow setup instructions for telescope: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#installation
- Require `telescope-jj.nvim`

Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ "nvim-lua/plenary.nvim", lazy = true }
```

Using [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug 'zschreur/telescope-jj.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)
```lua
call dein#add('zschreur/telescope-jj.nvim')
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'zschreur/telescope-jj.nvim'
}
```

Load the extension in your config with:
```lua
telescope.load_extension("jj")
```
### Example

```lua
{
    "zschreur/telescope-jj.nvim",
    config = function()
        telescope.load_extension "jj"
    end,
},
```

## Usage

```lua
-- opts is optional telescope picker options

telescope.extensions.jj.conflict(opts) -- list files with conflicts
telescope.extensions.jj.diff(opts) -- list files with differences (like jj status)
telescope.extensions.jj.files(opts) -- list all files in repo
```

### Git fallback

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
        error("Could not launch jj/git files: \n" .. jj_res .. "\n" .. git_res)
    end
end

vim.keymap.set("n", "<C-p>", vcs_picker, {})
```
