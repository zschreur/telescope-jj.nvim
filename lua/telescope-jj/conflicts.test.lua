local s1 = "file two-sided conflict"
local s2 = "file  two-sided conflict"
local s3 = "file   two-sided conflict"
local s4 = "file   three-sided conflict"
local s5 = "file two-sided conflict two-sided conflict"

local pattern = "^(.-)%s+%a+%-sided conflict$"
assert(string.match(s1, pattern) == "file")
assert(string.match(s2, pattern) == "file")
assert(string.match(s3, pattern) == "file")
assert(string.match(s4, pattern) == "file")
assert(string.match(s5, pattern) == "file two-sided conflict")
