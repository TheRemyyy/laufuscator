-- =============================================================================
-- Laufuscator Example: Comprehensive
-- =============================================================================
-- A comprehensive test covering most Lua language features.
-- Run: lua obfuscator.lua examples/comprehensive.lua output.lua
-- =============================================================================

-- String output
local message = "Hello, World!"
print(message)

-- Variables and math
local x = 10
local y = 20
local sum = x + y
print("Sum: " .. sum)

-- If/else conditions
if sum > 25 then
    print("Big number!")
else
    print("Small number")
end

-- For loop
print("Counting:")
for i = 1, 5 do
    print("  " .. i)
end

-- While loop
local counter = 3
while counter > 0 do
    print("Countdown: " .. counter)
    counter = counter - 1
end

-- Tables
local data = {
    name = "Laufuscator",
    version = 3.0,
    active = true
}
print("Name: " .. data.name)
print("Version: " .. data.version)

-- Nested conditions
local score = 85
if score >= 90 then
    print("Grade: A")
elseif score >= 80 then
    print("Grade: B")
elseif score >= 70 then
    print("Grade: C")
else
    print("Grade: F")
end

-- String operations
local greeting = "Hello"
local target = "Lua"
print(greeting .. " " .. target .. "!")

-- Math operations
local a, b = 15, 4
print("Add: " .. (a + b))
print("Sub: " .. (a - b))
print("Mul: " .. (a * b))
print("Div: " .. (a / b))
print("Mod: " .. (a % b))

print("=== Test Complete ===")
