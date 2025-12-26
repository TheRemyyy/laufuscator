-- =============================================================================
-- Laufuscator Example: Functions
-- =============================================================================
-- Demonstrates local function obfuscation.
-- Run: lua obfuscator.lua examples/functions.lua output.lua
-- =============================================================================

local function greet(name)
    return "Hello, " .. name .. "!"
end

local function add(a, b)
    return a + b
end

print(greet("World"))
print("Sum: " .. add(5, 3))

local x = 10
if x > 5 then
    print("x is big")
end

print("Done!")
