local conflicts = require("jj.conflicts")
local diff = require("jj.diff")
local files = require("jj.files")

return {
    conflicts = conflicts,
    diff = diff,
    files = files,
}
