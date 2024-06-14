local s1 = "file 2-sided conflict"
local s2 = "file  2-sided conflict"
local s3 = "file   2-sided conflict"
local s4 = "file   3-sided conflict"
local s5 = "file 2-sided conflict including 1 deletion"

local pattern = "^(.-)%s+%d+%-sided conflict"
assert(string.match(s1, pattern) == "file")
assert(string.match(s2, pattern) == "file")
assert(string.match(s3, pattern) == "file")
assert(string.match(s4, pattern) == "file")
assert(string.match(s5, pattern) == "file")
