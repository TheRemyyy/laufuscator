-- =============================================================================
-- Laufuscator Example: Basic
-- =============================================================================
-- A simple example demonstrating basic Lua constructs.
-- Run: lua obfuscator.lua examples/basic.lua output.lua
-- =============================================================================

local message = "Hello, World!"
print(message)

local x = 10
local y = 20
local sum = x + y
print("Sum: " .. sum)

if sum > 25 then
    print("Big number!")
else
    print("Small number")
end
