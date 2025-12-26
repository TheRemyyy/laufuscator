-- =============================================================================
-- Laufuscator v3.0 - Advanced Lua Code Obfuscator
-- =============================================================================
--
-- A powerful Lua obfuscator using VM-based bytecode execution with multiple
-- layers of protection.
--
-- Features:
--   - Nested VM (VM inside VM)
--   - Multi-layer string encryption (XOR + rotation + split)
--   - Bytecode table encryption with dynamic keys
--   - Control flow flattening with dispatcher
--   - Opaque predicates and fake branches
--   - Garbage/junk code injection
--   - Environment sandboxing and metamethod traps
--   - Self-decrypting layers
--   - Anti-debug/anti-tamper/anti-emulation protection
--   - Instruction mutation and polymorphic handlers
--
-- Usage:
--   lua obfuscator.lua <input.lua> <output.lua>
--
-- Repository: https://github.com/TheRemyyy/laufuscator
-- License: MIT
--
-- =============================================================================

local Obfuscator = {}

-- ============================================================================
-- JSON PARSER (Minimal implementation for config loading)
-- ============================================================================
local JSON = {}

local function skipWhitespace(str, pos)
    while pos <= #str and str:sub(pos, pos):match('[%s]') do
        pos = pos + 1
    end
    return pos
end

local parseValue  -- forward declaration

local function parseString(str, pos)
    pos = pos + 1  -- skip opening quote
    local result = {}
    while pos <= #str do
        local c = str:sub(pos, pos)
        if c == '"' then
            return table.concat(result), pos + 1
        elseif c == '\\' then
            pos = pos + 1
            local escaped = str:sub(pos, pos)
            if escaped == 'n' then table.insert(result, '\n')
            elseif escaped == 't' then table.insert(result, '\t')
            elseif escaped == 'r' then table.insert(result, '\r')
            else table.insert(result, escaped)
            end
            pos = pos + 1
        else
            table.insert(result, c)
            pos = pos + 1
        end
    end
    error("Unterminated string")
end

local function parseNumber(str, pos)
    local startPos = pos
    if str:sub(pos, pos) == '-' then pos = pos + 1 end
    while pos <= #str and str:sub(pos, pos):match('[%d]') do pos = pos + 1 end
    if pos <= #str and str:sub(pos, pos) == '.' then
        pos = pos + 1
        while pos <= #str and str:sub(pos, pos):match('[%d]') do pos = pos + 1 end
    end
    if pos <= #str and str:sub(pos, pos):lower() == 'e' then
        pos = pos + 1
        if str:sub(pos, pos):match('[+-]') then pos = pos + 1 end
        while pos <= #str and str:sub(pos, pos):match('[%d]') do pos = pos + 1 end
    end
    return tonumber(str:sub(startPos, pos - 1)), pos
end

local function parseObject(str, pos)
    local result = {}
    pos = pos + 1  -- skip opening brace
    pos = skipWhitespace(str, pos)
    if str:sub(pos, pos) == '}' then return result, pos + 1 end
    while true do
        pos = skipWhitespace(str, pos)
        if str:sub(pos, pos) ~= '"' then error("Expected string key at position " .. pos) end
        local key
        key, pos = parseString(str, pos)
        pos = skipWhitespace(str, pos)
        if str:sub(pos, pos) ~= ':' then error("Expected ':' at position " .. pos) end
        pos = pos + 1
        local value
        value, pos = parseValue(str, pos)
        result[key] = value
        pos = skipWhitespace(str, pos)
        local c = str:sub(pos, pos)
        if c == '}' then return result, pos + 1
        elseif c == ',' then pos = pos + 1
        else error("Expected ',' or '}' at position " .. pos)
        end
    end
end

local function parseArray(str, pos)
    local result = {}
    pos = pos + 1  -- skip opening bracket
    pos = skipWhitespace(str, pos)
    if str:sub(pos, pos) == ']' then return result, pos + 1 end
    while true do
        local value
        value, pos = parseValue(str, pos)
        table.insert(result, value)
        pos = skipWhitespace(str, pos)
        local c = str:sub(pos, pos)
        if c == ']' then return result, pos + 1
        elseif c == ',' then pos = pos + 1
        else error("Expected ',' or ']' at position " .. pos)
        end
    end
end

parseValue = function(str, pos)
    pos = skipWhitespace(str, pos)
    local c = str:sub(pos, pos)
    if c == '"' then return parseString(str, pos)
    elseif c == '{' then return parseObject(str, pos)
    elseif c == '[' then return parseArray(str, pos)
    elseif c == 't' and str:sub(pos, pos + 3) == 'true' then return true, pos + 4
    elseif c == 'f' and str:sub(pos, pos + 4) == 'false' then return false, pos + 5
    elseif c == 'n' and str:sub(pos, pos + 3) == 'null' then return nil, pos + 4
    elseif c:match('[%d-]') then return parseNumber(str, pos)
    else error("Unexpected character '" .. c .. "' at position " .. pos)
    end
end

function JSON.decode(str)
    local result, _ = parseValue(str, 1)
    return result
end

-- ============================================================================
-- CONFIGURATION
-- ============================================================================
local CONFIG = {
    VM_ENABLED = true,
    NESTED_VM = true,
    STRING_ENCRYPTION = true,
    STRING_SPLITTING = true,
    MULTI_LAYER_ENCRYPT = true,
    BYTECODE_ENCRYPTION = true,
    DYNAMIC_KEYS = true,
    CONTROL_FLOW_FLATTEN = true,
    OPAQUE_PREDICATES = true,
    FAKE_BRANCHES = true,
    JUNK_CODE = true,
    GARBAGE_CODE = true,
    VARIABLE_SUBSTITUTION = true,
    ENVIRONMENT_SANDBOX = true,
    METAMETHOD_TRAPS = true,
    SELF_DECRYPT_LAYERS = 2,
    TIMING_ANTI_DEBUG = true,
    ANTI_DEBUG = true,
    ANTI_TAMPER = true,
    CRC_CHECK = true,
    VARIABLE_MANGLE = true,
    CONSTANT_OBFUSCATION = true,
    INSTRUCTION_MUTATION = true,
    FUNCTION_OUTLINE = true,
    ENCRYPTION_LAYERS = 3,
    JUNK_DENSITY = 0.3,
    SPLIT_MIN_LENGTH = 4,
    MBA_OBFUSCATION = true,
    INSTRUCTION_SUBSTITUTION = true,
    BOGUS_CONTROL_FLOW = true,
    ANTI_EMULATION = true,
    REAL_CFG_FLATTEN = true,
    STRING_HIDE_RUNTIME = true,
}

-- JSON config key to CONFIG key mapping
local CONFIG_MAP = {
    -- obfuscation
    vm_enabled = "VM_ENABLED",
    nested_vm = "NESTED_VM",
    self_decrypt_layers = "SELF_DECRYPT_LAYERS",
    -- encryption
    string_encryption = "STRING_ENCRYPTION",
    string_splitting = "STRING_SPLITTING",
    multi_layer_encrypt = "MULTI_LAYER_ENCRYPT",
    bytecode_encryption = "BYTECODE_ENCRYPTION",
    dynamic_keys = "DYNAMIC_KEYS",
    encryption_layers = "ENCRYPTION_LAYERS",
    split_min_length = "SPLIT_MIN_LENGTH",
    -- control_flow
    control_flow_flatten = "CONTROL_FLOW_FLATTEN",
    opaque_predicates = "OPAQUE_PREDICATES",
    fake_branches = "FAKE_BRANCHES",
    bogus_control_flow = "BOGUS_CONTROL_FLOW",
    real_cfg_flatten = "REAL_CFG_FLATTEN",
    -- code_injection
    junk_code = "JUNK_CODE",
    garbage_code = "GARBAGE_CODE",
    junk_density = "JUNK_DENSITY",
    -- transformations
    variable_substitution = "VARIABLE_SUBSTITUTION",
    constant_obfuscation = "CONSTANT_OBFUSCATION",
    instruction_mutation = "INSTRUCTION_MUTATION",
    instruction_substitution = "INSTRUCTION_SUBSTITUTION",
    function_outline = "FUNCTION_OUTLINE",
    variable_mangle = "VARIABLE_MANGLE",
    mba_obfuscation = "MBA_OBFUSCATION",
    -- protection
    anti_debug = "ANTI_DEBUG",
    anti_tamper = "ANTI_TAMPER",
    anti_emulation = "ANTI_EMULATION",
    crc_check = "CRC_CHECK",
    timing_anti_debug = "TIMING_ANTI_DEBUG",
    -- runtime
    environment_sandbox = "ENVIRONMENT_SANDBOX",
    metamethod_traps = "METAMETHOD_TRAPS",
    string_hide_runtime = "STRING_HIDE_RUNTIME",
}

-- Load config from JSON file
local function loadConfig(configPath)
    local f = io.open(configPath, "r")
    if not f then
        return false, "Cannot open config file: " .. configPath
    end
    local content = f:read("*all")
    f:close()

    local ok, jsonConfig = pcall(JSON.decode, content)
    if not ok then
        return false, "Failed to parse JSON: " .. tostring(jsonConfig)
    end

    -- Apply config from all sections
    local sections = {"obfuscation", "encryption", "control_flow", "code_injection",
                      "transformations", "protection", "runtime"}
    for _, section in ipairs(sections) do
        if jsonConfig[section] then
            for key, value in pairs(jsonConfig[section]) do
                local configKey = CONFIG_MAP[key]
                if configKey and CONFIG[configKey] ~= nil then
                    CONFIG[configKey] = value
                end
            end
        end
    end

    return true
end

-- Get script directory for resolving relative paths
local function getScriptDir()
    local info = debug.getinfo(1, "S")
    local path = info.source:match("@?(.*)") or ""
    return path:match("(.*[\\/])") or "."
end

-- ============================================================================
-- UTILITIES
-- ============================================================================
local function randomString(len)
    local letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    local allChars = letters .. "0123456789"
    local idx = math.random(1, #letters)
    local result = letters:sub(idx, idx)
    for i = 2, len do
        idx = math.random(1, #allChars)
        result = result .. allChars:sub(idx, idx)
    end
    return result
end

local function generateKey(size)
    local key = {}
    for i = 1, size or 32 do
        key[i] = math.random(0, 255)
    end
    return key
end

local function xorEncrypt(str, key)
    local result = {}
    for i = 1, #str do
        local keyByte = key[((i - 1) % #key) + 1]
        result[i] = string.char((str:byte(i) ~ keyByte) % 256)
    end
    return table.concat(result)
end

local function rotateBytes(str, amount)
    local result = {}
    for i = 1, #str do
        result[i] = string.char((str:byte(i) + amount) % 256)
    end
    return table.concat(result)
end

local function escapeString(s)
    local result = {}
    for i = 1, #s do
        result[i] = string.format("\\%03d", s:byte(i))
    end
    return '"' .. table.concat(result) .. '"'
end

-- CRC32 calculation
local function crc32(str)
    local crc = 0xFFFFFFFF
    for i = 1, #str do
        local byte = str:byte(i)
        crc = crc ~ byte
        for _ = 1, 8 do
            local mask = -(crc & 1)
            crc = (crc >> 1) ~ (0xEDB88320 & mask)
        end
    end
    return crc ~ 0xFFFFFFFF
end

-- Base64 encoding
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64encode(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b64chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- Hex encoding
local function hexEncode(str)
    local hex = {}
    for i = 1, #str do
        hex[i] = string.format("%02x", str:byte(i))
    end
    return table.concat(hex)
end

-- ============================================================================
-- STRING SPLITTING
-- ============================================================================
local function splitString(str, minParts, maxParts)
    if #str < CONFIG.SPLIT_MIN_LENGTH then
        return {str}
    end
    local parts = {}
    local numParts = math.random(minParts or 2, math.min(maxParts or 5, #str))
    local partSize = math.floor(#str / numParts)
    local pos = 1
    for i = 1, numParts - 1 do
        local size = partSize + math.random(-1, 1)
        if size < 1 then size = 1 end
        if pos + size > #str then size = #str - pos + 1 end
        table.insert(parts, str:sub(pos, pos + size - 1))
        pos = pos + size
    end
    if pos <= #str then
        table.insert(parts, str:sub(pos))
    end
    return parts
end

-- ============================================================================
-- OPAQUE PREDICATES (ENHANCED)
-- ============================================================================
local OpaquePredicates = {}

function OpaquePredicates.alwaysTrue()
    local predicates = {
        "((1>0))",
        "(not(1==2))",
        "((7*7)==49)",
        "(type('')=='string')",
        "((10%2)==0)",
        "((2+2)==4)",
        "((-1*-1)==1)",
        "((#'x')==1)",
        "(true or false)",
        "((1<2)and(2<3))",
        "((math.pi>3))",
        "((#{}==0))",
        "((type(print)=='function'))",
        "((_VERSION~=nil))",
        "((''..''==''))",
        "((1 and 2)==2)",
        "((nil or 1)==1)",
        "((not nil))",
        "((1~=0))",
        "((0==0))",
    }
    return predicates[math.random(1, #predicates)]
end

function OpaquePredicates.alwaysFalse()
    local predicates = {
        "((1<0))",
        "((1==2))",
        "((7*7)==50)",
        "(type('')=='number')",
        "((10%2)==1)",
        "((2+2)==5)",
        "(false and true)",
        "((#'')==1)",
        "(not true)",
        "((1>2)or(3>4))",
        "((math.pi<3))",
        "((#{}~=0))",
        "((type(print)=='string'))",
        "((_VERSION==nil))",
        "((1==0))",
        "((nil and 1))",
        "((false or false))",
        "((not 1))",
        "((1==nil))",
    }
    return predicates[math.random(1, #predicates)]
end

function OpaquePredicates.generateDeadCode()
    local v1 = randomString(6)
    local v2 = randomString(6)
    local templates = {
        "if " .. OpaquePredicates.alwaysFalse() .. " then local " .. v1 .. "=" .. math.random(1,1000) .. " end",
        "while " .. OpaquePredicates.alwaysFalse() .. " do local " .. v1 .. "=" .. math.random(1,1000) .. " end",
        "local " .. v1 .. "=" .. OpaquePredicates.alwaysTrue() .. " and " .. math.random(1,100) .. " or " .. math.random(101,200),
        "for " .. v1 .. "=1,0 do local " .. v2 .. "=" .. math.random(1,100) .. " end",
        "repeat local " .. v1 .. "=0 until true",
    }
    return templates[math.random(1, #templates)]
end

function OpaquePredicates.generateComplexFakeBranch()
    local v1, v2, v3 = randomString(5), randomString(5), randomString(5)
    local code = "if " .. OpaquePredicates.alwaysFalse() .. " then\n"
    code = code .. "local " .. v1 .. "={}\n"
    code = code .. "for " .. v2 .. "=1," .. math.random(5,20) .. " do\n"
    code = code .. v1 .. "[" .. v2 .. "]=" .. v2 .. "*" .. math.random(2,10) .. "\n"
    code = code .. "end\n"
    code = code .. "local " .. v3 .. "=0\n"
    code = code .. "for _," .. v2 .. " in pairs(" .. v1 .. ") do " .. v3 .. "=" .. v3 .. "+" .. v2 .. " end\n"
    code = code .. "print(" .. v3 .. ")\n"
    code = code .. "end\n"
    return code
end

-- ============================================================================
-- CONSTANT OBFUSCATION (ENHANCED)
-- ============================================================================
local function obfuscateNumber(n)
    local ops = {
        function(x) local a = math.random(1, 100); return "(" .. (x + a) .. "-" .. a .. ")" end,
        function(x) local a = math.random(2, 10); return "((" .. (x * a) .. ")/" .. a .. ")" end,
        function(x) local a = math.random(1, 50); return "(" .. (x - a) .. "+" .. a .. ")" end,
        function(x) return "(((" .. x .. ")*2)/2)" end,
        function(x) local a = x + math.random(1,10); return "(" .. a .. "-" .. (a-x) .. ")" end,
        function(x) return "((" .. x .. "+0))" end,
        function(x) local a = math.random(1,5); return "(((" .. (x*a) .. ")+" .. (x*(10-a)) .. ")/10)" end,
        function(x) return "((0+" .. x .. "))" end,
        function(x) local a = math.random(2,8); return "((" .. x .. "^1))" end,
        function(x) return "(math.floor(" .. x .. ".0))" end,
    }

    if CONFIG.CONSTANT_OBFUSCATION and math.random() > 0.3 then
        local result = tostring(n)
        for _ = 1, math.random(1, 2) do
            result = ops[math.random(1, #ops)](n)
        end
        return result
    end
    return tostring(n)
end

-- ============================================================================
-- GARBAGE CODE GENERATOR
-- ============================================================================
local function generateGarbageCode()
    local v1, v2, v3 = randomString(5), randomString(5), randomString(5)
    local templates = {
        "local " .. v1 .. "=" .. math.random(1,1000),
        "local " .. v1 .. "='" .. randomString(8) .. "'",
        "local " .. v1 .. "={}",
        "local " .. v1 .. "=" .. v1 .. " or " .. math.random(1,100),
        "local " .. v1 .. "=type(" .. math.random(1,100) .. ")",
        "local " .. v1 .. "=#'" .. randomString(math.random(3,10)) .. "'",
        "local " .. v1 .. "=(" .. math.random(1,50) .. "+" .. math.random(1,50) .. ")",
        "local " .. v1 .. "=tostring(" .. math.random(1,100) .. ")",
    }
    return templates[math.random(1, #templates)]
end

-- ============================================================================
-- MBA (MIXED BOOLEAN-ARITHMETIC) TRANSFORMATIONS
-- ============================================================================
local MBA = {}

-- x + y = (x ^ y) + 2*(x & y)
function MBA.transformAdd(a, b)
    return "((" .. a .. "~" .. b .. ")+2*(" .. a .. "&" .. b .. "))"
end

-- x - y = (x ^ y) - 2*(~x & y)  OR  x + (~y + 1)
function MBA.transformSub(a, b)
    local variants = {
        "((" .. a .. "~" .. b .. ")-2*(~" .. a .. "&" .. b .. "))",
        "(" .. a .. "+(~" .. b .. "+1))",
        "((" .. a .. "|" .. b .. ")-(" .. a .. "&" .. b .. ")-" .. b .. ")"
    }
    return variants[math.random(1, #variants)]
end

-- x * 2 = x << 1 = x + x
function MBA.transformMul2(a)
    local variants = {
        "(" .. a .. "<<1)",
        "(" .. a .. "+" .. a .. ")",
        "((" .. a .. "|" .. a .. ")+(" .. a .. "&" .. a .. "))"
    }
    return variants[math.random(1, #variants)]
end

-- -x = ~x + 1 = (x ^ -1) + 1
function MBA.transformNeg(a)
    local variants = {
        "(~" .. a .. "+1)",
        "((" .. a .. "~-1)+1)",
        "(0-" .. a .. ")"
    }
    return variants[math.random(1, #variants)]
end

-- x | y = (x & ~y) + y = x + (y & ~x)
function MBA.transformOr(a, b)
    return "((" .. a .. "&~" .. b .. ")+" .. b .. ")"
end

-- x & y = (x | y) - (x ^ y)
function MBA.transformAnd(a, b)
    return "((" .. a .. "|" .. b .. ")-(" .. a .. "~" .. b .. "))"
end

-- Generate MBA-obfuscated expression for handler bodies
function MBA.obfuscateExpression(expr)
    if not CONFIG.MBA_OBFUSCATION then return expr end

    -- Random chance to apply MBA
    if math.random() > 0.5 then return expr end

    -- Simple pattern matching and replacement
    local result = expr

    -- Replace a+b patterns (simplified - real impl would parse properly)
    result = result:gsub("(%w+)%+(%w+)", function(a, b)
        if math.random() > 0.7 then
            return MBA.transformAdd(a, b)
        end
        return a .. "+" .. b
    end)

    return result
end

-- ============================================================================
-- ANTI-EMULATION (Detect sandbox/VM/emulator)
-- ============================================================================
local function generateAntiEmulation()
    if not CONFIG.ANTI_EMULATION then return "" end

    local v = {}
    for i = 1, 15 do v[i] = randomString(6) end

    local code = "(function()\n"

    -- Check 1: Timing-based detection (emulators are slow) - relaxed threshold
    code = code .. "local " .. v[1] .. "=os and os.clock\n"
    code = code .. "if " .. v[1] .. " then\n"
    code = code .. "local " .. v[2] .. "=" .. v[1] .. "()\n"
    code = code .. "local " .. v[3] .. "=0\n"
    code = code .. "for " .. v[4] .. "=1,5000 do " .. v[3] .. "=" .. v[3] .. "+" .. v[4] .. " end\n"
    code = code .. "local " .. v[5] .. "=" .. v[1] .. "()-" .. v[2] .. "\n"
    -- If loop takes more than 500ms, likely emulated (very relaxed)
    code = code .. "if " .. v[5] .. ">0.5 then while true do end end\n"
    code = code .. "end\n"

    -- Check 2: Basic environment checks (relaxed memory check removed - too variable)
    code = code .. "if not collectgarbage then while true do end end\n"

    -- Check 3: _VERSION check (must be Lua 5.x)
    code = code .. "if not _VERSION or not _VERSION:match('Lua 5') then while true do end end\n"

    -- Check 4: Coroutine support (often disabled in sandboxes)
    code = code .. "if not coroutine or not coroutine.create then\n"
    code = code .. "while true do end\n"
    code = code .. "end\n"

    -- Check 5: Basic math check
    code = code .. "if not math or not math.floor then while true do end end\n"

    -- Check 6: Table operations check
    code = code .. "if not table or not table.concat then while true do end end\n"

    code = code .. "end)();\n"
    return code
end

-- ============================================================================
-- CONTROL FLOW FLATTENING (Block-level bytecode transformation)
-- ============================================================================
local function realControlFlowFlatten(bytecode)
    if not CONFIG.REAL_CFG_FLATTEN then return bytecode end

    -- Split bytecode into basic blocks
    local blocks = {}
    local currentBlock = {instructions = {}, id = 1, startIdx = 1}
    local blockId = 1

    for i, instr in ipairs(bytecode) do
        table.insert(currentBlock.instructions, instr)

        -- End block on jump or return
        if instr.op == OP.JMP or instr.op == OP.JMP_IF or
           instr.op == OP.JMP_IF_NOT or instr.op == OP.RETURN then
            currentBlock.endIdx = i
            table.insert(blocks, currentBlock)
            blockId = blockId + 1
            currentBlock = {instructions = {}, id = blockId, startIdx = i + 1}
        end
    end

    -- Add last block if not empty
    if #currentBlock.instructions > 0 then
        currentBlock.endIdx = #bytecode
        table.insert(blocks, currentBlock)
    end

    -- If only 1-2 blocks, not worth flattening
    if #blocks <= 2 then return bytecode end

    -- Deterministic rebuild with NOP insertion for obfuscation
    local result = {}
    local instrMap = {}  -- old index -> new index
    local newIdx = 1

    for blockIdx, block in ipairs(blocks) do
        -- Add 1-2 NOPs before block (deterministic based on block index)
        local nopCount = (blockIdx % 2) + 1
        for _ = 1, nopCount do
            table.insert(result, {op = OP.NOP, args = {}})
            newIdx = newIdx + 1
        end

        -- Map old indices and copy instructions
        for oldLocalIdx, instr in ipairs(block.instructions) do
            local oldGlobalIdx = block.startIdx + oldLocalIdx - 1
            instrMap[oldGlobalIdx] = newIdx

            local newInstr = {op = instr.op, args = {}}
            for j, arg in ipairs(instr.args) do
                newInstr.args[j] = arg
            end
            table.insert(result, newInstr)
            newIdx = newIdx + 1
        end
    end

    -- Map any indices that weren't captured (fallthrough targets)
    instrMap[#bytecode + 1] = newIdx

    -- Fix jump targets using the mapping
    for _, instr in ipairs(result) do
        if instr.op == OP.JMP or instr.op == OP.JMP_IF or instr.op == OP.JMP_IF_NOT then
            local oldTarget = instr.args[1]
            if oldTarget and instrMap[oldTarget] then
                instr.args[1] = instrMap[oldTarget]
            end
        end
    end

    return result
end


-- ============================================================================
-- STRING RUNTIME HIDING (Prevent strings from being visible in memory)
-- ============================================================================
local function generateStringHiding()
    if not CONFIG.STRING_HIDE_RUNTIME then return "" end

    local v = {}
    for i = 1, 5 do v[i] = randomString(6) end

    -- Create a closure that builds strings on-demand and clears them
    local code = "local " .. v[1] .. "=setmetatable({},{\n"
    code = code .. "__mode='v',\n"  -- weak values, GC can collect
    code = code .. "__index=function(t,k)\n"
    code = code .. "local v=rawget(t,k)\n"
    code = code .. "if v then return v end\n"
    code = code .. "return nil\n"
    code = code .. "end\n"
    code = code .. "})\n"

    return code
end

-- ============================================================================
-- INSTRUCTION MUTATION
-- ============================================================================
local function generateOpcodeMapping()
    -- Create shuffled mapping: original opcode -> shuffled opcode
    local opcodes = {}
    for i = 1, 50 do opcodes[i] = i end
    -- Fisher-Yates shuffle
    for i = #opcodes, 2, -1 do
        local j = math.random(1, i)
        opcodes[i], opcodes[j] = opcodes[j], opcodes[i]
    end
    -- Return both forward and reverse mappings
    local forward = {}  -- original -> shuffled
    local reverse = {}  -- shuffled -> original
    for orig, shuffled in ipairs(opcodes) do
        forward[orig] = shuffled
        reverse[shuffled] = orig
    end
    return forward, reverse
end

local function mutateInstructions(bytecode, opcodeMap)
    for _, instr in ipairs(bytecode) do
        if opcodeMap[instr.op] then
            instr.op = opcodeMap[instr.op]
        end
    end
    return bytecode
end

-- ============================================================================
-- BYTECODE ENCRYPTION
-- ============================================================================
local function encryptBytecode(bytecode, key)
    local encrypted = {}
    for i, instr in ipairs(bytecode) do
        local keyByte = key[((i - 1) % #key) + 1]
        encrypted[i] = {
            op = (instr.op ~ keyByte) % 256,
            args = {}
        }
        for j, arg in ipairs(instr.args) do
            local argKey = key[((i + j) % #key) + 1]
            encrypted[i].args[j] = (arg ~ argKey) % 65536
        end
    end
    return encrypted
end

-- ============================================================================
-- DYNAMIC KEY DERIVATION
-- ============================================================================
local function deriveKeyFromCode(source, baseKey)
    -- Create key based on source code hash + base key
    local hash = crc32(source)
    local derived = {}
    for i = 1, #baseKey do
        local b = baseKey[i]
        local h = (hash >> ((i % 4) * 8)) & 0xFF
        derived[i] = (b ~ h) % 256
    end
    return derived
end

-- ============================================================================
-- FUNCTION OUTLINING
-- ============================================================================
local function generateOutlinedFunctions()
    local funcs = {}
    local v = {}
    for i = 1, 10 do v[i] = randomString(6) end

    -- Outlined XOR decrypt function
    funcs.xorDecrypt = {
        name = v[1],
        code = "local function " .. v[1] .. "(s,k,o)\n" ..
               "o=o or 0\n" ..
               "local r={}\n" ..
               "for i=1,#s do r[i]=string.char((s:byte(i)~k[((i-1+o)%#k)+1])%256)end\n" ..
               "return table.concat(r)\n" ..
               "end\n"
    }

    -- Outlined bytecode decrypt function
    funcs.bcDecrypt = {
        name = v[2],
        code = "local function " .. v[2] .. "(bc,k,rm)\n" ..
               "local d={}\n" ..
               "for i,instr in ipairs(bc)do\n" ..
               "local kb=k[((i-1)%#k)+1]\n" ..
               "local op=(instr.o~kb)%256\n" ..
               "if rm then op=rm[op]or op end\n" ..
               "local args={}\n" ..
               "for j,a in ipairs(instr.a)do\n" ..
               "local ak=k[((i+j)%#k)+1]\n" ..
               "args[j]=(a~ak)%65536\n" ..
               "end\n" ..
               "d[i]={o=op,a=args}\n" ..
               "end\n" ..
               "return d\n" ..
               "end\n"
    }

    -- Outlined stack operations
    funcs.stackOps = {
        name = v[3],
        code = "local " .. v[3] .. "={s={},p=function(self,x)self.s[#self.s+1]=x end,o=function(self)return table.remove(self.s)end}\n"
    }

    return funcs
end

-- ============================================================================
-- LEXER
-- ============================================================================
local KEYWORDS = {
    ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
    ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
    ["function"] = true, ["goto"] = true, ["if"] = true, ["in"] = true,
    ["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true,
    ["repeat"] = true, ["return"] = true, ["then"] = true, ["true"] = true,
    ["until"] = true, ["while"] = true,
}

local function tokenize(source)
    local tokens = {}
    local pos = 1
    local len = #source

    local function peek(offset)
        local p = pos + (offset or 0)
        return p <= len and source:sub(p, p) or ""
    end

    local function advance(n) pos = pos + (n or 1) end

    local function match(pattern)
        return source:match("^" .. pattern, pos)
    end

    while pos <= len do
        local ws = match("[ \t\r\n]+")
        if ws then advance(#ws) end
        if pos > len then break end

        -- Comments
        if peek() == "-" and peek(1) == "-" then
            if peek(2) == "[" and (peek(3) == "[" or peek(3) == "=") then
                local eqCount = 0
                local i = 3
                while peek(i) == "=" do eqCount = eqCount + 1; i = i + 1 end
                if peek(i) == "[" then
                    local endPattern = "]" .. string.rep("=", eqCount) .. "]"
                    local endPos = source:find(endPattern, pos + i + 1, true)
                    advance(endPos and (endPos - pos + #endPattern) or (len - pos + 1))
                else
                    local endPos = source:find("\n", pos, true)
                    advance(endPos and (endPos - pos + 1) or (len - pos + 1))
                end
            else
                local endPos = source:find("\n", pos, true)
                advance(endPos and (endPos - pos + 1) or (len - pos + 1))
            end
        -- Strings
        elseif peek() == '"' or peek() == "'" then
            local quote = peek()
            local startPos = pos
            advance()
            while pos <= len and peek() ~= quote do
                if peek() == "\\" then advance(2) else advance() end
            end
            advance()
            table.insert(tokens, {type = "STRING", value = source:sub(startPos, pos - 1)})
        -- Long strings
        elseif peek() == "[" and (peek(1) == "[" or peek(1) == "=") then
            local eqCount = 0
            local startPos = pos
            advance()
            while peek() == "=" do eqCount = eqCount + 1; advance() end
            if peek() == "[" then
                advance()
                local endPattern = "]" .. string.rep("=", eqCount) .. "]"
                local endPos = source:find(endPattern, pos, true)
                advance(endPos and (endPos - pos + #endPattern) or (len - pos + 1))
                table.insert(tokens, {type = "STRING", value = source:sub(startPos, pos - 1)})
            else
                table.insert(tokens, {type = "SYMBOL", value = "["})
            end
        -- Numbers
        elseif match("%d") or (peek() == "." and match("%.%d")) then
            local num = match("0[xX][%da-fA-F]+") or match("%d+%.?%d*[eE][+-]?%d+") or
                       match("%d+%.%d*") or match("%.%d+") or match("%d+")
            if num then
                table.insert(tokens, {type = "NUMBER", value = num})
                advance(#num)
            end
        -- Identifiers/Keywords
        elseif match("[%a_]") then
            local ident = match("[%a_][%w_]*")
            if ident then
                table.insert(tokens, {type = KEYWORDS[ident] and "KEYWORD" or "IDENTIFIER", value = ident})
                advance(#ident)
            end
        -- Symbols
        else
            local symbols = {"...", "..", "==", "~=", "<=", ">=", "<<", ">>", "//", "::",
                           "+", "-", "*", "/", "%", "^", "#", "&", "~", "|", "<", ">",
                           "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", "."}
            local matched = false
            for _, sym in ipairs(symbols) do
                if source:sub(pos, pos + #sym - 1) == sym then
                    table.insert(tokens, {type = "SYMBOL", value = sym})
                    advance(#sym)
                    matched = true
                    break
                end
            end
            if not matched then advance() end
        end
    end
    return tokens
end

-- ============================================================================
-- VM OPCODES
-- ============================================================================
local OP = {
    LOAD_CONST = 1, LOAD_VAR = 2, STORE_VAR = 3, LOAD_GLOBAL = 4,
    STORE_GLOBAL = 5, CALL = 6, RETURN = 7, ADD = 8, SUB = 9,
    MUL = 10, DIV = 11, MOD = 12, POW = 13, CONCAT = 14,
    EQ = 15, NE = 16, LT = 17, LE = 18, GT = 19, GE = 20,
    AND = 21, OR = 22, NOT = 23, NEG = 24, LEN = 25,
    JMP = 26, JMP_IF = 27, JMP_IF_NOT = 28, NEW_TABLE = 29,
    GET_TABLE = 30, SET_TABLE = 31, LOAD_NIL = 32, LOAD_TRUE = 33,
    LOAD_FALSE = 34, POP = 35, DUP = 36, CLOSURE = 37, NOP = 47,
}

-- ============================================================================
-- INSTRUCTION SUBSTITUTION
-- ============================================================================
local InstructionSubstitution = {}

-- Transform ADD instructions: a + b → a - (-b)
function InstructionSubstitution.transformAdd(bytecode)
    local result = {}
    for i, instr in ipairs(bytecode) do
        if instr.op == OP.ADD and math.random() > 0.5 then
            -- a + b → a - (-b)
            -- Stack: [a, b] → need to negate b then subtract
            table.insert(result, {op = OP.NEG, args = {}})  -- negate top (b → -b)
            table.insert(result, {op = OP.SUB, args = {}})  -- a - (-b)
        else
            table.insert(result, instr)
        end
    end
    return result
end

-- Transform SUB instructions: a - b → a + (-b)
function InstructionSubstitution.transformSub(bytecode)
    local result = {}
    for i, instr in ipairs(bytecode) do
        if instr.op == OP.SUB and math.random() > 0.5 then
            -- a - b → a + (-b)
            table.insert(result, {op = OP.NEG, args = {}})  -- negate top (b → -b)
            table.insert(result, {op = OP.ADD, args = {}})  -- a + (-b)
        else
            table.insert(result, instr)
        end
    end
    return result
end

-- Transform MUL by 2: a * 2 → a + a (when constant is 2)
function InstructionSubstitution.transformMul(bytecode)
    local result = {}
    local i = 1
    while i <= #bytecode do
        local instr = bytecode[i]
        -- Check for LOAD_CONST 2 followed by MUL
        if instr.op == OP.LOAD_CONST and i + 1 <= #bytecode and
           bytecode[i+1].op == OP.MUL and math.random() > 0.6 then
            -- Replace with DUP + ADD (a * 2 → a + a)
            table.insert(result, {op = OP.DUP, args = {}})
            table.insert(result, {op = OP.ADD, args = {}})
            i = i + 2  -- skip both instructions
        else
            table.insert(result, instr)
            i = i + 1
        end
    end
    return result
end

-- Apply all instruction substitutions
function InstructionSubstitution.apply(bytecode)
    if not CONFIG.INSTRUCTION_SUBSTITUTION then return bytecode end

    local result = bytecode
    result = InstructionSubstitution.transformAdd(result)
    result = InstructionSubstitution.transformSub(result)
    return result
end

-- ============================================================================
-- BOGUS CONTROL FLOW (Inject fake branches into bytecode)
-- ============================================================================
local BogusControlFlow = {}

function BogusControlFlow.inject(bytecode)
    if not CONFIG.BOGUS_CONTROL_FLOW then return bytecode end

    local result = {}
    local insertedCount = 0

    for i, instr in ipairs(bytecode) do
        -- Randomly insert bogus control flow before some instructions
        if math.random() < 0.15 and instr.op ~= OP.JMP and instr.op ~= OP.JMP_IF
           and instr.op ~= OP.JMP_IF_NOT and instr.op ~= OP.RETURN then
            -- Create opaque predicate: always true condition
            -- Push true (1==1), then JMP_IF_NOT to skip fake code
            local skipTarget = #result + 6  -- will be adjusted

            -- Generate fake block that never executes
            table.insert(result, {op = OP.LOAD_TRUE, args = {}})  -- push true
            table.insert(result, {op = OP.JMP_IF, args = {#result + 4}})  -- if true, skip fake

            -- Fake code (never reached)
            table.insert(result, {op = OP.LOAD_CONST, args = {1}})  -- fake operation
            table.insert(result, {op = OP.POP, args = {}})  -- cleanup

            insertedCount = insertedCount + 4
        end

        -- Adjust jump targets for inserted instructions
        local newInstr = {op = instr.op, args = {}}
        for j, arg in ipairs(instr.args) do
            if (instr.op == OP.JMP or instr.op == OP.JMP_IF or instr.op == OP.JMP_IF_NOT) and j == 1 then
                -- Adjust jump target
                newInstr.args[j] = arg + insertedCount
            else
                newInstr.args[j] = arg
            end
        end
        table.insert(result, newInstr)
    end

    return result
end

-- ============================================================================
-- BYTECODE COMPILER (same as before, omitted for brevity - copy from v2)
-- ============================================================================
local function compile(tokens)
    local bytecode = {}
    local constants = {}
    local constMap = {}
    local loopStack = {}

    local function addConst(value, ctype)
        local key = ctype .. ":" .. tostring(value)
        if constMap[key] then return constMap[key] end
        table.insert(constants, {type = ctype, value = value})
        constMap[key] = #constants
        return #constants
    end

    local function emit(op, ...)
        table.insert(bytecode, {op = op, args = {...}})
        return #bytecode
    end

    local function patchJump(idx, target)
        if bytecode[idx] then
            bytecode[idx].args[1] = target
        end
    end

    local pos = 1
    local function current() return tokens[pos] end
    local function peek(offset) return tokens[pos + (offset or 0)] end
    local function advance() pos = pos + 1; return tokens[pos - 1] end
    local function check(t, v)
        local tok = current()
        return tok and tok.type == t and (not v or tok.value == v)
    end
    local function consume(t, v)
        if check(t, v) then return advance() end
        return nil
    end

    local compileExpr, compileStmt, compilePrimary, compileUnary, compileArith, compileCompare

    -- Compile primary expression (atoms and postfix operations)
    compilePrimary = function()
        local t = current()
        if not t then return end

        if t.type == "NUMBER" then
            advance()
            emit(OP.LOAD_CONST, addConst(tonumber(t.value), "number"))
        elseif t.type == "STRING" then
            advance()
            local raw = t.value
            local str
            if raw:sub(1,1) == "[" then
                local eqCount = 0
                local i = 2
                while raw:sub(i,i) == "=" do eqCount = eqCount + 1; i = i + 1 end
                str = raw:sub(i + 1, -(i))
            else
                str = raw:sub(2, -2)
                str = str:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub("\\r", "\r")
                str = str:gsub("\\(.)", "%1")
            end
            emit(OP.LOAD_CONST, addConst(str, "string"))
        elseif t.type == "KEYWORD" then
            if t.value == "nil" then advance(); emit(OP.LOAD_NIL)
            elseif t.value == "true" then advance(); emit(OP.LOAD_TRUE)
            elseif t.value == "false" then advance(); emit(OP.LOAD_FALSE)
            elseif t.value == "function" then
                advance()
                emit(OP.LOAD_NIL)
                local depth = 1
                consume("SYMBOL", "(")
                while not check("SYMBOL", ")") and current() do advance() end
                consume("SYMBOL", ")")
                while depth > 0 and current() do
                    if check("KEYWORD", "function") or check("KEYWORD", "if") or
                       check("KEYWORD", "do") or check("KEYWORD", "while") or
                       check("KEYWORD", "for") then depth = depth + 1
                    elseif check("KEYWORD", "end") then depth = depth - 1 end
                    advance()
                end
            end
        elseif t.type == "IDENTIFIER" then
            advance()
            emit(OP.LOAD_GLOBAL, addConst(t.value, "string"))

            while current() do
                if check("SYMBOL", "(") then
                    advance()
                    local argc = 0
                    while not check("SYMBOL", ")") and current() do
                        compileExpr()
                        argc = argc + 1
                        if not consume("SYMBOL", ",") then break end
                    end
                    consume("SYMBOL", ")")
                    emit(OP.CALL, argc)
                elseif check("SYMBOL", ".") then
                    advance()
                    local field = advance()
                    if field and field.type == "IDENTIFIER" then
                        emit(OP.LOAD_CONST, addConst(field.value, "string"))
                        emit(OP.GET_TABLE)
                    end
                elseif check("SYMBOL", "[") then
                    advance()
                    compileExpr()
                    consume("SYMBOL", "]")
                    emit(OP.GET_TABLE)
                elseif check("SYMBOL", ":") then
                    advance()
                    local method = advance()
                    if method and method.type == "IDENTIFIER" then
                        emit(OP.DUP)
                        emit(OP.LOAD_CONST, addConst(method.value, "string"))
                        emit(OP.GET_TABLE)
                        if check("SYMBOL", "(") then
                            advance()
                            local argc = 1
                            while not check("SYMBOL", ")") and current() do
                                compileExpr()
                                argc = argc + 1
                                if not consume("SYMBOL", ",") then break end
                            end
                            consume("SYMBOL", ")")
                            emit(OP.CALL, argc)
                        end
                    end
                else
                    break
                end
            end
        elseif check("SYMBOL", "(") then
            advance()
            compileExpr()
            consume("SYMBOL", ")")
            while check("SYMBOL", "(") or check("SYMBOL", ".") or check("SYMBOL", "[") do
                if check("SYMBOL", "(") then
                    advance()
                    local argc = 0
                    while not check("SYMBOL", ")") and current() do
                        compileExpr()
                        argc = argc + 1
                        if not consume("SYMBOL", ",") then break end
                    end
                    consume("SYMBOL", ")")
                    emit(OP.CALL, argc)
                elseif check("SYMBOL", ".") then
                    advance()
                    local field = advance()
                    if field then
                        emit(OP.LOAD_CONST, addConst(field.value, "string"))
                        emit(OP.GET_TABLE)
                    end
                elseif check("SYMBOL", "[") then
                    advance()
                    compileExpr()
                    consume("SYMBOL", "]")
                    emit(OP.GET_TABLE)
                end
            end
        elseif check("SYMBOL", "{") then
            advance()
            emit(OP.NEW_TABLE)
            local idx = 1
            while not check("SYMBOL", "}") and current() do
                if check("SYMBOL", "[") then
                    advance()
                    emit(OP.DUP)
                    compileExpr()
                    consume("SYMBOL", "]")
                    consume("SYMBOL", "=")
                    compileExpr()
                    emit(OP.SET_TABLE)
                elseif peek(1) and peek(1).type == "SYMBOL" and peek(1).value == "=" then
                    local key = advance()
                    advance()
                    emit(OP.DUP)
                    emit(OP.LOAD_CONST, addConst(key.value, "string"))
                    compileExpr()
                    emit(OP.SET_TABLE)
                else
                    emit(OP.DUP)
                    emit(OP.LOAD_CONST, addConst(idx, "number"))
                    compileExpr()
                    emit(OP.SET_TABLE)
                    idx = idx + 1
                end
                consume("SYMBOL", ",")
                consume("SYMBOL", ";")
            end
            consume("SYMBOL", "}")
        end
    end

    -- Compile unary expressions (not, -, #)
    compileUnary = function()
        if check("KEYWORD", "not") then
            advance()
            compileUnary()
            emit(OP.NOT)
        elseif check("SYMBOL", "-") then
            advance()
            compileUnary()
            emit(OP.NEG)
        elseif check("SYMBOL", "#") then
            advance()
            compileUnary()
            emit(OP.LEN)
        else
            compilePrimary()
        end
    end

    -- Compile arithmetic/concat expressions (*, /, %, ^, +, -, ..)
    compileArith = function()
        compileUnary()

        local mulOps = {["*"] = OP.MUL, ["/"] = OP.DIV, ["%"] = OP.MOD, ["^"] = OP.POW}
        while current() and current().type == "SYMBOL" and mulOps[current().value] do
            local op = advance().value
            compileUnary()
            emit(mulOps[op])
        end

        local addOps = {["+"] = OP.ADD, ["-"] = OP.SUB, [".."] = OP.CONCAT}
        while current() and current().type == "SYMBOL" and addOps[current().value] do
            local op = advance().value
            compileUnary()
            -- Handle chained mul ops on right side
            while current() and current().type == "SYMBOL" and mulOps[current().value] do
                local op2 = advance().value
                compileUnary()
                emit(mulOps[op2])
            end
            emit(addOps[op])
        end
    end

    -- Compile comparison expressions (==, ~=, <, <=, >, >=)
    compileCompare = function()
        compileArith()

        local cmpOps = {
            ["=="] = OP.EQ, ["~="] = OP.NE,
            ["<"] = OP.LT, ["<="] = OP.LE, [">"] = OP.GT, [">="] = OP.GE,
        }

        while current() and current().type == "SYMBOL" and cmpOps[current().value] do
            local op = advance().value
            compileArith()
            emit(cmpOps[op])
        end
    end

    -- Compile full expression (and, or at lowest precedence)
    compileExpr = function()
        compileCompare()

        while current() and current().type == "KEYWORD" do
            if current().value == "and" then
                advance()
                compileCompare()
                emit(OP.AND)
            elseif current().value == "or" then
                advance()
                compileCompare()
                emit(OP.OR)
            else
                break
            end
        end
    end

    compileStmt = function()
        local t = current()
        if not t then return false end

        if t.type == "KEYWORD" then
            if t.value == "local" then
                advance()
                if check("KEYWORD", "function") then
                    advance()
                    local name = advance()
                    -- Extract full function source
                    local funcStart = pos
                    local funcParts = {"function("}
                    consume("SYMBOL", "(")
                    -- Get parameters
                    while not check("SYMBOL", ")") and current() do
                        local p = advance()
                        if p then table.insert(funcParts, p.value) end
                        if check("SYMBOL", ",") then
                            advance()
                            table.insert(funcParts, ",")
                        end
                    end
                    consume("SYMBOL", ")")
                    table.insert(funcParts, ")")
                    -- Get body
                    local depth = 1
                    while depth > 0 and current() do
                        local tok = current()
                        if check("KEYWORD", "function") or check("KEYWORD", "if") or
                           check("KEYWORD", "do") or check("KEYWORD", "while") or
                           check("KEYWORD", "for") or check("KEYWORD", "repeat") then
                            depth = depth + 1
                        elseif check("KEYWORD", "end") then
                            depth = depth - 1
                        end
                        if depth > 0 then
                            -- STRING tokens already include quotes from tokenizer, use directly
                            if tok.type == "NUMBER" then
                                table.insert(funcParts, tostring(tok.value))
                            else
                                table.insert(funcParts, tok.value)
                            end
                            table.insert(funcParts, " ")
                        end
                        advance()
                    end
                    table.insert(funcParts, "end")
                    local funcSource = table.concat(funcParts)
                    -- Store as function constant and emit CLOSURE
                    local funcIdx = addConst(funcSource, "function")
                    emit(OP.CLOSURE, funcIdx)
                    emit(OP.STORE_VAR, addConst(name.value, "string"))
                else
                    local vars = {}
                    repeat
                        local var = advance()
                        if var and var.type == "IDENTIFIER" then
                            table.insert(vars, var.value)
                        end
                    until not consume("SYMBOL", ",")

                    if consume("SYMBOL", "=") then
                        for i, v in ipairs(vars) do
                            if i > 1 then consume("SYMBOL", ",") end
                            compileExpr()
                            emit(OP.STORE_VAR, addConst(v, "string"))
                        end
                    else
                        for _, v in ipairs(vars) do
                            emit(OP.LOAD_NIL)
                            emit(OP.STORE_VAR, addConst(v, "string"))
                        end
                    end
                end

            elseif t.value == "function" then
                advance()
                local name = advance()
                local depth = 1
                consume("SYMBOL", "(")
                while not check("SYMBOL", ")") and current() do advance() end
                consume("SYMBOL", ")")
                while depth > 0 and current() do
                    if check("KEYWORD", "function") or check("KEYWORD", "if") or
                       check("KEYWORD", "do") or check("KEYWORD", "while") or
                       check("KEYWORD", "for") then depth = depth + 1
                    elseif check("KEYWORD", "end") then depth = depth - 1 end
                    advance()
                end

            elseif t.value == "if" then
                advance()
                local endJumps = {}
                compileExpr()
                consume("KEYWORD", "then")
                local jmpFalse = emit(OP.JMP_IF_NOT, 0)

                while not check("KEYWORD", "else") and not check("KEYWORD", "elseif") and
                      not check("KEYWORD", "end") and current() do
                    if not compileStmt() then break end
                end

                table.insert(endJumps, emit(OP.JMP, 0))
                patchJump(jmpFalse, #bytecode + 1)

                while check("KEYWORD", "elseif") do
                    advance()
                    compileExpr()
                    consume("KEYWORD", "then")
                    jmpFalse = emit(OP.JMP_IF_NOT, 0)

                    while not check("KEYWORD", "else") and not check("KEYWORD", "elseif") and
                          not check("KEYWORD", "end") and current() do
                        if not compileStmt() then break end
                    end

                    table.insert(endJumps, emit(OP.JMP, 0))
                    patchJump(jmpFalse, #bytecode + 1)
                end

                if consume("KEYWORD", "else") then
                    while not check("KEYWORD", "end") and current() do
                        if not compileStmt() then break end
                    end
                end

                consume("KEYWORD", "end")
                for _, jmp in ipairs(endJumps) do
                    patchJump(jmp, #bytecode + 1)
                end

            elseif t.value == "while" then
                advance()
                local loopStart = #bytecode + 1
                table.insert(loopStack, {start = loopStart, breaks = {}})

                compileExpr()
                consume("KEYWORD", "do")
                local jmpFalse = emit(OP.JMP_IF_NOT, 0)

                while not check("KEYWORD", "end") and current() do
                    if not compileStmt() then break end
                end

                emit(OP.JMP, loopStart)
                consume("KEYWORD", "end")
                patchJump(jmpFalse, #bytecode + 1)

                local loop = table.remove(loopStack)
                for _, breakIdx in ipairs(loop.breaks) do
                    patchJump(breakIdx, #bytecode + 1)
                end

            elseif t.value == "for" then
                advance()
                local var = advance()

                if consume("SYMBOL", "=") then
                    local varIdx = addConst(var.value, "string")
                    compileExpr()
                    emit(OP.STORE_VAR, varIdx)

                    consume("SYMBOL", ",")
                    compileExpr()
                    local limitIdx = addConst("__limit__" .. math.random(10000, 99999), "string")
                    emit(OP.STORE_VAR, limitIdx)

                    local stepIdx = addConst("__step__" .. math.random(10000, 99999), "string")
                    if consume("SYMBOL", ",") then
                        compileExpr()
                    else
                        emit(OP.LOAD_CONST, addConst(1, "number"))
                    end
                    emit(OP.STORE_VAR, stepIdx)

                    consume("KEYWORD", "do")

                    local loopStart = #bytecode + 1
                    table.insert(loopStack, {start = loopStart, breaks = {}})

                    emit(OP.LOAD_VAR, stepIdx)
                    emit(OP.LOAD_CONST, addConst(0, "number"))
                    emit(OP.GT)
                    local checkPos = emit(OP.JMP_IF_NOT, 0)

                    emit(OP.LOAD_VAR, varIdx)
                    emit(OP.LOAD_VAR, limitIdx)
                    emit(OP.LE)
                    local doneCheck1 = emit(OP.JMP, 0)

                    patchJump(checkPos, #bytecode + 1)
                    emit(OP.LOAD_VAR, varIdx)
                    emit(OP.LOAD_VAR, limitIdx)
                    emit(OP.GE)

                    patchJump(doneCheck1, #bytecode + 1)
                    local exitLoop = emit(OP.JMP_IF_NOT, 0)

                    while not check("KEYWORD", "end") and current() do
                        if not compileStmt() then break end
                    end

                    emit(OP.LOAD_VAR, varIdx)
                    emit(OP.LOAD_VAR, stepIdx)
                    emit(OP.ADD)
                    emit(OP.STORE_VAR, varIdx)

                    emit(OP.JMP, loopStart)
                    consume("KEYWORD", "end")
                    patchJump(exitLoop, #bytecode + 1)

                    local loop = table.remove(loopStack)
                    for _, breakIdx in ipairs(loop.breaks) do
                        patchJump(breakIdx, #bytecode + 1)
                    end
                else
                    local vars = {var.value}
                    while consume("SYMBOL", ",") do
                        local v = advance()
                        if v then table.insert(vars, v.value) end
                    end
                    consume("KEYWORD", "in")
                    compileExpr()
                    consume("KEYWORD", "do")

                    local depth = 1
                    while depth > 0 and current() do
                        if check("KEYWORD", "for") or check("KEYWORD", "while") or
                           check("KEYWORD", "if") or check("KEYWORD", "function") or
                           check("KEYWORD", "do") then depth = depth + 1
                        elseif check("KEYWORD", "end") then depth = depth - 1 end
                        if depth > 0 then advance() end
                    end
                    consume("KEYWORD", "end")
                end

            elseif t.value == "repeat" then
                advance()
                local loopStart = #bytecode + 1
                table.insert(loopStack, {start = loopStart, breaks = {}})

                while not check("KEYWORD", "until") and current() do
                    if not compileStmt() then break end
                end

                consume("KEYWORD", "until")
                compileExpr()
                emit(OP.JMP_IF_NOT, loopStart)

                local loop = table.remove(loopStack)
                for _, breakIdx in ipairs(loop.breaks) do
                    patchJump(breakIdx, #bytecode + 1)
                end

            elseif t.value == "return" then
                advance()
                if current() and not check("KEYWORD", "end") and not check("KEYWORD", "else") and
                   not check("KEYWORD", "elseif") and not check("KEYWORD", "until") then
                    local rc = 0
                    repeat
                        compileExpr()
                        rc = rc + 1
                    until not consume("SYMBOL", ",")
                    emit(OP.RETURN, rc)
                else
                    emit(OP.RETURN, 0)
                end

            elseif t.value == "break" then
                advance()
                if #loopStack > 0 then
                    local breakIdx = emit(OP.JMP, 0)
                    table.insert(loopStack[#loopStack].breaks, breakIdx)
                end

            elseif t.value == "do" then
                advance()
                while not check("KEYWORD", "end") and current() do
                    if not compileStmt() then break end
                end
                consume("KEYWORD", "end")

            else
                return false
            end

        elseif t.type == "IDENTIFIER" then
            local name = t.value
            advance()

            local accessors = {}
            while check("SYMBOL", ".") or check("SYMBOL", "[") do
                if consume("SYMBOL", ".") then
                    local f = advance()
                    if f then table.insert(accessors, {type = "field", value = f.value}) end
                elseif consume("SYMBOL", "[") then
                    table.insert(accessors, {type = "index"})
                    compileExpr()
                    consume("SYMBOL", "]")
                end
            end

            if consume("SYMBOL", "=") then
                local idx = addConst(name, "string")
                if #accessors == 0 then
                    compileExpr()
                    emit(OP.STORE_VAR, idx)
                else
                    emit(OP.LOAD_GLOBAL, idx)
                    for i = 1, #accessors - 1 do
                        local acc = accessors[i]
                        if acc.type == "field" then
                            emit(OP.LOAD_CONST, addConst(acc.value, "string"))
                            emit(OP.GET_TABLE)
                        end
                    end
                    local last = accessors[#accessors]
                    if last.type == "field" then
                        emit(OP.LOAD_CONST, addConst(last.value, "string"))
                    end
                    compileExpr()
                    emit(OP.SET_TABLE)
                end
            elseif check("SYMBOL", "(") then
                emit(OP.LOAD_GLOBAL, addConst(name, "string"))
                for _, acc in ipairs(accessors) do
                    if acc.type == "field" then
                        emit(OP.LOAD_CONST, addConst(acc.value, "string"))
                        emit(OP.GET_TABLE)
                    end
                end
                advance()
                local argc = 0
                while not check("SYMBOL", ")") and current() do
                    compileExpr()
                    argc = argc + 1
                    if not consume("SYMBOL", ",") then break end
                end
                consume("SYMBOL", ")")
                emit(OP.CALL, argc)
                emit(OP.POP)
            elseif check("SYMBOL", ":") then
                emit(OP.LOAD_GLOBAL, addConst(name, "string"))
                for _, acc in ipairs(accessors) do
                    if acc.type == "field" then
                        emit(OP.LOAD_CONST, addConst(acc.value, "string"))
                        emit(OP.GET_TABLE)
                    end
                end
                advance()
                local method = advance()
                if method and check("SYMBOL", "(") then
                    emit(OP.DUP)
                    emit(OP.LOAD_CONST, addConst(method.value, "string"))
                    emit(OP.GET_TABLE)
                    advance()
                    local argc = 1
                    while not check("SYMBOL", ")") and current() do
                        compileExpr()
                        argc = argc + 1
                        if not consume("SYMBOL", ",") then break end
                    end
                    consume("SYMBOL", ")")
                    emit(OP.CALL, argc)
                    emit(OP.POP)
                end
            elseif consume("SYMBOL", ",") then
                -- Multiple assignment: a, b = expr1, expr2
                -- Must evaluate ALL expressions first, then store in reverse order
                local vars = {name}
                repeat
                    local v = advance()
                    if v and v.type == "IDENTIFIER" then table.insert(vars, v.value) end
                until not consume("SYMBOL", ",")
                consume("SYMBOL", "=")
                -- First, evaluate ALL expressions (push to stack)
                local exprCount = 0
                repeat
                    compileExpr()
                    exprCount = exprCount + 1
                until not consume("SYMBOL", ",")
                -- Pad with nil if fewer expressions than variables
                while exprCount < #vars do
                    emit(OP.LOAD_NIL)
                    exprCount = exprCount + 1
                end
                -- Store in REVERSE order (stack is LIFO)
                for i = #vars, 1, -1 do
                    emit(OP.STORE_VAR, addConst(vars[i], "string"))
                end
            else
                return false
            end
        else
            return false
        end
        return true
    end

    while pos <= #tokens do
        if not compileStmt() then pos = pos + 1 end
    end

    emit(OP.RETURN, 0)
    return {bytecode = bytecode, constants = constants}
end

-- ============================================================================
-- STRING ENCRYPTION (Multi-layer with splitting)
-- ============================================================================
local function encryptStrings(constants, key)
    for _, const in ipairs(constants) do
        if const.type == "string" or const.type == "function" then
            local encrypted = const.value
            -- Layer 1: XOR
            encrypted = xorEncrypt(encrypted, key)
            -- Layer 2: Byte rotation
            if CONFIG.MULTI_LAYER_ENCRYPT then
                encrypted = rotateBytes(encrypted, 128)
            end
            -- Layer 3: Additional XOR with derived key
            if CONFIG.ENCRYPTION_LAYERS >= 3 then
                local derivedKey = {}
                for i = 1, 16 do
                    derivedKey[i] = (key[i] * 7 + 13) % 256
                end
                encrypted = xorEncrypt(encrypted, derivedKey)
            end
            const.encrypted = encrypted

            -- String splitting (only for strings, not functions)
            if const.type == "string" and CONFIG.STRING_SPLITTING and #const.value >= CONFIG.SPLIT_MIN_LENGTH then
                const.split = splitString(const.encrypted, 2, 4)
            end
        end
    end
end

-- ============================================================================
-- JUNK CODE WITH JUMP PRESERVATION
-- ============================================================================
local function injectJunkWithPreservation(bytecode, density)
    local result = {}
    local offsetMap = {}

    local offset = 0
    for i, instr in ipairs(bytecode) do
        offsetMap[i] = i + offset
        table.insert(result, instr)

        local isJump = instr.op == OP.JMP or instr.op == OP.JMP_IF or instr.op == OP.JMP_IF_NOT
        if not isJump and math.random() < density then
            local junkCount = math.random(1, 3)
            for _ = 1, junkCount do
                table.insert(result, {op = OP.NOP, args = {}})
                offset = offset + 1
            end
        end
    end
    offsetMap[#bytecode + 1] = #result + 1

    for _, instr in ipairs(result) do
        if instr.op == OP.JMP or instr.op == OP.JMP_IF or instr.op == OP.JMP_IF_NOT then
            local oldTarget = instr.args[1]
            if oldTarget and offsetMap[oldTarget] then
                instr.args[1] = offsetMap[oldTarget]
            end
        end
    end

    return result
end

-- ============================================================================
-- VM INTERPRETER GENERATOR (ULTIMATE)
-- ============================================================================
local function generateVM(bytecode, constants, key, options)
    options = options or {}
    local bcEncrypted = options.bytecodeEncrypted
    local bcKey = options.bytecodeKey or key

    local v = {}
    for i = 1, 30 do v[i] = randomString(math.random(6, 12)) end

    -- Random field names for bytecode structure (anti-pattern matching)
    local bcFieldOp = randomString(math.random(2, 4))   -- instead of "o"
    local bcFieldArgs = randomString(math.random(2, 4)) -- instead of "a"

    local keyStr = "{" .. table.concat(key, ",") .. "}"
    local bcKeyStr = "{" .. table.concat(bcKey, ",") .. "}"


    -- Build constants with optional splitting
    local constParts = {}
    for i, c in ipairs(constants) do
        if c.type == "number" then
            local numStr = obfuscateNumber(c.value)
            constParts[i] = "{t='n',v=" .. numStr .. "}"
        elseif c.type == "function" then
            -- Function source - encrypt it like a string
            if c.encrypted then
                constParts[i] = "{t='f',v=" .. escapeString(c.encrypted) .. ",e=1}"
            else
                constParts[i] = "{t='f',v=" .. string.format("%q", c.value) .. "}"
            end
        else
            if c.encrypted then
                if c.split and #c.split > 1 then
                    -- Split string encoding
                    local splitParts = {}
                    for _, part in ipairs(c.split) do
                        table.insert(splitParts, escapeString(part))
                    end
                    constParts[i] = "{t='s',v={" .. table.concat(splitParts, ",") .. "},e=1,sp=1}"
                else
                    constParts[i] = "{t='s',v=" .. escapeString(c.encrypted) .. ",e=1}"
                end
            else
                constParts[i] = "{t='s',v=" .. string.format("%q", c.value) .. "}"
            end
        end
    end
    local constStr = "{" .. table.concat(constParts, ",") .. "}"

    -- Build bytecode with obfuscated field names
    local bcParts = {}
    for i, instr in ipairs(bytecode) do
        local argsStr = "{" .. table.concat(instr.args, ",") .. "}"
        bcParts[i] = "{" .. bcFieldOp .. "=" .. instr.op .. "," .. bcFieldArgs .. "=" .. argsStr .. "}"
    end
    local bcStr = "{" .. table.concat(bcParts, ",") .. "}"

    local L, R = "[", "]"
    local lines = {}
    local function add(s) lines[#lines+1] = s end

    add("local function " .. v[1] .. "()")
    add("local " .. v[2] .. "=" .. keyStr)
    add("local " .. v[3] .. "=" .. constStr)
    add("local " .. v[4] .. "=" .. bcStr)

    -- Bytecode decryption key (if different from string key)
    if bcEncrypted and CONFIG.BYTECODE_ENCRYPTION then
        add("local " .. v[21] .. "=" .. bcKeyStr)
    end


    -- Derived key for layer 3
    if CONFIG.ENCRYPTION_LAYERS >= 3 then
        add("local " .. v[20] .. "={}")
        add("for i=1,16 do " .. v[20] .. "[i]=(" .. v[2] .. "[i]*7+13)%256 end")
    end

    -- Multi-layer decryption function
    add("local function " .. v[5] .. "(s,k)")
    add("local r={}")
    if CONFIG.ENCRYPTION_LAYERS >= 3 then
        -- Layer 3: Reverse XOR with derived key
        add("local t={}")
        add("for i=1,#s do t[i]=string.char((s:byte(i)~" .. v[20] .. "[((i-1)%#" .. v[20] .. ")+1])%256) end")
        add("s=table.concat(t)")
    end
    if CONFIG.MULTI_LAYER_ENCRYPT then
        -- Layer 2: Reverse rotation
        add("local t2={}")
        add("for i=1,#s do t2[i]=string.char((s:byte(i)-128)%256) end")
        add("s=table.concat(t2)")
    end
    -- Layer 1: XOR
    add("for i=1,#s do r[i]=string.char((s:byte(i)~k[((i-1)%#k)+1])%256) end")
    add("return table.concat(r)")
    add("end")

    -- OPAQUE STACK OPERATIONS - use indirect indexing via stack pointer
    local sp = randomString(4)  -- stack pointer
    local sd = randomString(5)  -- stack data array
    local st = randomString(5)  -- stack wrapper table with metamethods

    add("local " .. sd .. "={}")  -- actual stack data
    add("local " .. sp .. "=0")   -- stack pointer (top index)
    add("local " .. v[7] .. "={}")  -- variables
    add("local " .. v[8] .. "=1")   -- instruction pointer

    -- Create stack wrapper with metamethods for obfuscation
    add("local " .. st .. "=setmetatable({},{")
    add("__index=function(_,k)return " .. sd .. "[k]end,")
    add("__newindex=function(_,k,v)" .. sd .. "[k]=v end,")
    add("__len=function()return " .. sp .. " end")
    add("})")

    -- Obfuscated push - uses multiple indirection levels
    add("local function " .. v[9] .. "(x)")
    add("local p=" .. sp .. "+1")  -- increment pointer
    add(sp .. "=p")  -- update pointer
    add(st .. "[p]=x")  -- store via metamethod
    add("end")

    -- Obfuscated pop - uses wrapper and decrement
    add("local function " .. v[10] .. "()")
    add("local p=" .. sp)
    add("if p<1 then return nil end")  -- underflow protection
    add("local v=" .. st .. "[p]")  -- get via metamethod
    add(st .. "[p]=nil")  -- clear slot
    add(sp .. "=p-1")  -- decrement pointer
    add("return v")
    add("end")

    -- Alias for backward compatibility with handler references
    add("local " .. v[6] .. "=" .. st)

    -- Decrypt constants with split support
    add("for i,c in ipairs(" .. v[3] .. ")do")
    add("if c.t=='s' and c.e then")
    add("if c.sp then")
    -- First concatenate all parts, then decrypt the whole thing
    add("local f=''")
    add("for _,part in ipairs(c.v)do f=f..part end")
    add("c.v=" .. v[5] .. "(f," .. v[2] .. ")")
    add("else")
    add("c.v=" .. v[5] .. "(c.v," .. v[2] .. ")")
    add("end")
    add("elseif c.t=='f' and c.e then")
    -- Decrypt function source and compile with load()
    add("local src=" .. v[5] .. "(c.v," .. v[2] .. ")")
    add("c.v=load('return '..src)()")
    add("end")
    add("end")

    -- BYTECODE DECRYPTION (if encrypted)
    -- Note: No opcode remapping needed since handlers are at shuffled positions
    if bcEncrypted and CONFIG.BYTECODE_ENCRYPTION then
        add("-- Decrypt bytecode")
        add("local " .. v[23] .. "={}")
        add("for i,instr in ipairs(" .. v[4] .. ")do")
        add("local kb=" .. v[21] .. "[((i-1)%#" .. v[21] .. ")+1]")
        add("local op=(instr." .. bcFieldOp .. "~kb)%256")
        add("local args={}")
        add("for j,a in ipairs(instr." .. bcFieldArgs .. ")do")
        add("local ak=" .. v[21] .. "[((i+j)%#" .. v[21] .. ")+1]")
        add("args[j]=(a~ak)%65536")
        add("end")
        add(v[23] .. "[i]={" .. bcFieldOp .. "=op," .. bcFieldArgs .. "=args}")
        add("end")
        add(v[4] .. "=" .. v[23])
    end

    -- Main VM loop with handler table dispatch (anti-analysis)
    local hk = randomString(6)  -- handler key for encryption
    local hd = randomString(6)  -- handler decrypt function

    -- Get opcode mapping - if instruction mutation is enabled, use shuffled indices
    -- Otherwise create identity mapping
    local opMap = {}
    if options.forwardOpcodeMap then
        opMap = options.forwardOpcodeMap
    else
        for i = 1, 50 do opMap[i] = i end
    end

    -- RETURN opcode shuffled position (needed for return check in main loop)
    local returnOp = opMap[7] or 7

    -- Generate handler encryption key
    local handlerKey = generateKey(16)
    local handlerKeyStr = "{" .. table.concat(handlerKey, ",") .. "}"

    -- Handler encryption key and decrypt function
    add("local " .. hk .. "=" .. handlerKeyStr)

    -- Shorthand variable names for handler bodies (to keep encrypted strings shorter)
    local ps = randomString(2)  -- push shorthand
    local pp = randomString(2)  -- pop shorthand
    local cs = randomString(2)  -- consts shorthand
    local vs = randomString(2)  -- vars shorthand
    local env = randomString(4)  -- environment table

    -- Create environment table with all needed variables
    add("local " .. env .. "={" .. ps .. "=" .. v[9] .. "," .. pp .. "=" .. v[10] .. "," .. cs .. "=" .. v[3] .. "," .. vs .. "=" .. v[7] .. ",_G=_G,table=table}")
    add("setmetatable(" .. env .. ",{__index=_G})")

    -- Generate S-box for substitution cipher (random permutation of 0-255)
    local sbox = {}
    local sboxInv = {}
    for i = 0, 255 do sbox[i] = i end
    for i = 255, 1, -1 do
        local j = math.random(0, i)
        sbox[i], sbox[j] = sbox[j], sbox[i]
    end
    for i = 0, 255 do sboxInv[sbox[i]] = i end

    -- Generate S-box string for runtime
    local sboxStr = "{"
    for i = 0, 255 do
        sboxStr = sboxStr .. "[" .. i .. "]=" .. sboxInv[i]
        if i < 255 then sboxStr = sboxStr .. "," end
    end
    sboxStr = sboxStr .. "}"

    local sboxVar = randomString(4)
    add("local " .. sboxVar .. "=" .. sboxStr)

    -- Handler decrypt function - MULTI-ROUND with S-box substitution
    add("local function " .. hd .. "(s)")
    add("local r={}")
    -- Round 1: XOR with key
    add("for i=1,#s do")
    add("local b=s:byte(i)")
    add("local k=" .. hk .. "[((i-1)%#" .. hk .. ")+1]")
    add("b=(b~k)%256")
    -- Round 2: Inverse S-box substitution
    add("b=" .. sboxVar .. "[b]")
    -- Round 3: XOR with position-rotated key
    add("local k2=" .. hk .. "[((i*7+3)%#" .. hk .. ")+1]")
    add("b=(b~k2)%256")
    add("r[i]=string.char(b)")
    add("end")
    add("return load('return '..table.concat(r),nil,'t'," .. env .. ")()")
    add("end")

    -- Helper to encrypt a handler body string (multi-round)
    local function encryptHandler(body)
        local encrypted = {}
        for i = 1, #body do
            local b = body:byte(i)
            -- Round 3 (reverse): XOR with position-rotated key
            local k2 = handlerKey[((i * 7 + 3) % #handlerKey) + 1]
            b = (b ~ k2) % 256
            -- Round 2 (reverse): S-box substitution
            b = sbox[b]
            -- Round 1 (reverse): XOR with key
            local k = handlerKey[((i - 1) % #handlerKey) + 1]
            b = (b ~ k) % 256
            encrypted[i] = string.char(b)
        end
        return escapeString(table.concat(encrypted))
    end

    -- Helper to pick random variant
    local function pickVariant(variants)
        return variants[math.random(1, #variants)]
    end

    -- Random junk variable names for polymorphism
    local jv = {}
    for i = 1, 10 do jv[i] = randomString(2) end

    -- POLYMORPHIC handler bodies - each opcode has multiple equivalent implementations
    local handlers = {
        [1] = pickVariant({
            "function(a)" .. ps .. "(" .. cs .. "[a[1]].v)end",
            "function(a)local c=" .. cs .. "[a[1]];" .. ps .. "(c.v)end",
            "function(a)local idx=a[1];" .. ps .. "(" .. cs .. "[idx].v)end",
        }),  -- LOAD_CONST
        [2] = pickVariant({
            "function(a)" .. ps .. "(" .. vs .. "[" .. cs .. "[a[1]].v])end",
            "function(a)local n=" .. cs .. "[a[1]].v;" .. ps .. "(" .. vs .. "[n])end",
            "function(a)local k=" .. cs .. "[a[1]];" .. ps .. "(" .. vs .. "[k.v])end",
        }),  -- LOAD_VAR
        [3] = pickVariant({
            "function(a)" .. vs .. "[" .. cs .. "[a[1]].v]=" .. pp .. "()end",
            "function(a)local n=" .. cs .. "[a[1]].v;local v=" .. pp .. "();" .. vs .. "[n]=v end",
            "function(a)local x=" .. pp .. "();" .. vs .. "[" .. cs .. "[a[1]].v]=x end",
        }),  -- STORE_VAR
        [4] = pickVariant({
            "function(a)local n=" .. cs .. "[a[1]].v;local val=" .. vs .. "[n];if val==nil then val=_G[n]end;" .. ps .. "(val)end",
            "function(a)local k=" .. cs .. "[a[1]].v;local r=" .. vs .. "[k];if r==nil then r=_G[k]end;" .. ps .. "(r)end",
            "function(a)local nm=" .. cs .. "[a[1]].v;local v=" .. vs .. "[nm]or _G[nm];" .. ps .. "(v==nil and _G[nm]or v)end",
        }),  -- LOAD_GLOBAL
        [5] = pickVariant({
            "function(a)_G[" .. cs .. "[a[1]].v]=" .. pp .. "()end",
            "function(a)local n=" .. cs .. "[a[1]].v;local v=" .. pp .. "();_G[n]=v end",
            "function(a)local val=" .. pp .. "();_G[" .. cs .. "[a[1]].v]=val end",
        }),  -- STORE_GLOBAL
        [6] = pickVariant({
            "function(a)local n=a[1];local args={};for i=n,1,-1 do args[i]=" .. pp .. "()end;local f=" .. pp .. "();local r={f(table.unpack(args))};for i=#r,1,-1 do " .. ps .. "(r[i])end end",
            "function(a)local c=a[1];local t={};for j=c,1,-1 do t[j]=" .. pp .. "()end;local fn=" .. pp .. "();local res={fn(table.unpack(t))};for k=#res,1,-1 do " .. ps .. "(res[k])end end",
        }),  -- CALL
        [7] = pickVariant({
            "function(a)local n=a[1]or 0;local r={};for i=1,n do r[i]=" .. pp .. "()end;return table.unpack(r)end",
            "function(a)local cnt=a[1];if not cnt then cnt=0 end;local t={};for j=1,cnt do t[j]=" .. pp .. "()end;return table.unpack(t)end",
        }),  -- RETURN
        [8] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a+b)end",
            "function()local " .. jv[1] .. "=" .. pp .. "();local " .. jv[2] .. "=" .. pp .. "();" .. ps .. "(" .. jv[2] .. "+" .. jv[1] .. ")end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "(l+r)end",
            "function()local x,y=" .. pp .. "()," .. pp .. "();local s=y+x;" .. ps .. "(s)end",
            -- MBA: x + y = (x ~ y) + 2*(x & y)  (~ is XOR in Lua 5.4)
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "((a~b)+2*(a&b))end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "((l~r)+((l&r)<<1))end",
        }),  -- ADD
        [9] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a-b)end",
            "function()local " .. jv[3] .. "=" .. pp .. "();local " .. jv[4] .. "=" .. pp .. "();" .. ps .. "(" .. jv[4] .. "-" .. jv[3] .. ")end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "(l-r)end",
            -- MBA: x - y = x + (~y + 1)
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a+(~b+1))end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "(l+(~r+1))end",
        }),  -- SUB
        [10] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a*b)end",
            "function()local " .. jv[5] .. "=" .. pp .. "();local " .. jv[6] .. "=" .. pp .. "();" .. ps .. "(" .. jv[6] .. "*" .. jv[5] .. ")end",
            "function()local m2,m1=" .. pp .. "()," .. pp .. "();" .. ps .. "(m1*m2)end",
        }),  -- MUL
        [11] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a/b)end",
            "function()local d=" .. pp .. "();local n=" .. pp .. "();" .. ps .. "(n/d)end",
        }),  -- DIV
        [12] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a%b)end",
            "function()local m=" .. pp .. "();local v=" .. pp .. "();" .. ps .. "(v%m)end",
        }),  -- MOD
        [13] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a^b)end",
            "function()local e=" .. pp .. "();local b=" .. pp .. "();" .. ps .. "(b^e)end",
        }),  -- POW
        [14] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a..b)end",
            "function()local s2=" .. pp .. "();local s1=" .. pp .. "();" .. ps .. "(s1..s2)end",
        }),  -- CONCAT
        [15] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a==b)end",
            "function()local y=" .. pp .. "();local x=" .. pp .. "();" .. ps .. "(x==y)end",
        }),  -- EQ
        [16] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a~=b)end",
            "function()local y=" .. pp .. "();local x=" .. pp .. "();" .. ps .. "(x~=y)end",
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(not(a==b))end",
        }),  -- NE
        [17] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a<b)end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "(l<r)end",
        }),  -- LT
        [18] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a<=b)end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "(l<=r)end",
        }),  -- LE
        [19] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a>b)end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "(l>r)end",
        }),  -- GT
        [20] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a>=b)end",
            "function()local r=" .. pp .. "();local l=" .. pp .. "();" .. ps .. "(l>=r)end",
        }),  -- GE
        [21] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a and b)end",
            "function()local y=" .. pp .. "();local x=" .. pp .. "();" .. ps .. "(x and y)end",
        }),  -- AND
        [22] = pickVariant({
            "function()local b,a=" .. pp .. "()," .. pp .. "();" .. ps .. "(a or b)end",
            "function()local y=" .. pp .. "();local x=" .. pp .. "();" .. ps .. "(x or y)end",
        }),  -- OR
        [23] = pickVariant({
            "function()" .. ps .. "(not " .. pp .. "())end",
            "function()local v=" .. pp .. "();" .. ps .. "(not v)end",
            "function()local x=" .. pp .. "();local r=not x;" .. ps .. "(r)end",
        }),  -- NOT
        [24] = pickVariant({
            "function()" .. ps .. "(-" .. pp .. "())end",
            "function()local n=" .. pp .. "();" .. ps .. "(-n)end",
            "function()local v=" .. pp .. "();" .. ps .. "(0-v)end",
            -- MBA: -x = ~x + 1
            "function()local n=" .. pp .. "();" .. ps .. "(~n+1)end",
            "function()local v=" .. pp .. "();" .. ps .. "((v~-1)+1)end",
        }),  -- NEG
        [25] = pickVariant({
            "function()" .. ps .. "(#" .. pp .. "())end",
            "function()local t=" .. pp .. "();" .. ps .. "(#t)end",
        }),  -- LEN
        [26] = pickVariant({
            "function(a)return'J',a[1]end",
            "function(a)local t=a[1];return'J',t end",
        }),  -- JMP
        [27] = pickVariant({
            "function(a)if " .. pp .. "()then return'J',a[1]end end",
            "function(a)local c=" .. pp .. "();if c then return'J',a[1]end end",
        }),  -- JMP_IF
        [28] = pickVariant({
            "function(a)if not " .. pp .. "()then return'J',a[1]end end",
            "function(a)local c=" .. pp .. "();if not c then return'J',a[1]end end",
        }),  -- JMP_IF_NOT
        [29] = pickVariant({
            "function()" .. ps .. "({})end",
            "function()local t={};" .. ps .. "(t)end",
        }),  -- NEW_TABLE
        [30] = pickVariant({
            "function()local k,t=" .. pp .. "()," .. pp .. "();" .. ps .. "(t[k])end",
            "function()local key=" .. pp .. "();local tbl=" .. pp .. "();" .. ps .. "(tbl[key])end",
        }),  -- GET_TABLE
        [31] = pickVariant({
            "function()local x,k,t=" .. pp .. "()," .. pp .. "()," .. pp .. "();t[k]=x;" .. ps .. "(t)end",
            "function()local val=" .. pp .. "();local key=" .. pp .. "();local tbl=" .. pp .. "();tbl[key]=val;" .. ps .. "(tbl)end",
        }),  -- SET_TABLE
        [32] = pickVariant({
            "function()" .. ps .. "(nil)end",
            "function()local n=nil;" .. ps .. "(n)end",
        }),  -- LOAD_NIL
        [33] = pickVariant({
            "function()" .. ps .. "(true)end",
            "function()local t=true;" .. ps .. "(t)end",
            "function()" .. ps .. "(1==1)end",
        }),  -- LOAD_TRUE
        [34] = pickVariant({
            "function()" .. ps .. "(false)end",
            "function()local f=false;" .. ps .. "(f)end",
            "function()" .. ps .. "(1==0)end",
        }),  -- LOAD_FALSE
        [35] = pickVariant({
            "function()" .. pp .. "()end",
            "function()local _=" .. pp .. "()end",
        }),  -- POP
        [36] = pickVariant({
            "function()local x=" .. pp .. "();" .. ps .. "(x);" .. ps .. "(x)end",
            "function()local v=" .. pp .. "();" .. ps .. "(v);" .. ps .. "(v)end",
        }),  -- DUP
        [37] = pickVariant({
            "function(a)" .. ps .. "(" .. cs .. "[a[1]].v)end",
            "function(a)local f=" .. cs .. "[a[1]].v;" .. ps .. "(f)end",
        }),  -- CLOSURE
        [47] = pickVariant({
            "function()end",
            "function()local _=0 end",
            "function()local _=nil end",
        }),  -- NOP
    }

    -- SPLIT HANDLERS ACROSS LAYERS - distribute handlers into multiple tables
    local NUM_LAYERS = 4
    local layers = {}
    local layerNames = {}
    for i = 1, NUM_LAYERS do
        layerNames[i] = randomString(6)
        layers[i] = {}
        add("local " .. layerNames[i] .. "={}")
    end

    -- Layer lookup table (maps opcode to layer index)
    local layerMap = randomString(5)
    add("local " .. layerMap .. "={}")

    -- Distribute handlers randomly across layers
    local handlerList = {}
    for origOp, body in pairs(handlers) do
        table.insert(handlerList, {origOp = origOp, body = body})
    end

    -- Shuffle handler order for distribution
    for i = #handlerList, 2, -1 do
        local j = math.random(1, i)
        handlerList[i], handlerList[j] = handlerList[j], handlerList[i]
    end

    -- Assign handlers to layers
    for i, hInfo in ipairs(handlerList) do
        local layerIdx = ((i - 1) % NUM_LAYERS) + 1
        local shuffledOp = opMap[hInfo.origOp] or hInfo.origOp
        local encryptedBody = encryptHandler(hInfo.body)
        add(layerNames[layerIdx] .. "[" .. shuffledOp .. "]=" .. hd .. "(" .. encryptedBody .. ")")
        add(layerMap .. "[" .. shuffledOp .. "]=" .. layerIdx)
    end

    -- Add dummy handlers to random layers
    local usedOps = {}
    for i = 1, 50 do usedOps[opMap[i] or i] = true end
    usedOps[opMap[47] or 47] = true
    for i = 1, math.random(5, 10) do
        local dummyOp = math.random(51, 150)
        if not usedOps[dummyOp] then
            usedOps[dummyOp] = true
            local layerIdx = math.random(1, NUM_LAYERS)
            local dummyBodies = {
                "function()end",
                "function(a)return a end",
                "function()return nil end",
            }
            local dummyBody = dummyBodies[math.random(1, #dummyBodies)]
            add(layerNames[layerIdx] .. "[" .. dummyOp .. "]=" .. hd .. "(" .. encryptHandler(dummyBody) .. ")")
            add(layerMap .. "[" .. dummyOp .. "]=" .. layerIdx)
        end
    end

    -- Layer array for indirect lookup
    local layerArr = randomString(5)
    add("local " .. layerArr .. "={" .. table.concat(layerNames, ",") .. "}")

    -- ANTI-TAMPER CHECKSUM - verify bytecode integrity before execution
    local crcFunc = randomString(6)
    local expectedCrc = randomString(5)
    local actualCrc = randomString(5)

    -- Use pre-calculated CRC from options (calculated before encryption)
    local bcCrcValue = options.expectedCrc or 0

    -- CRC verification function with obfuscated algorithm
    add("local function " .. crcFunc .. "(bc)")
    add("local c=0x12345678")  -- non-zero seed
    add("for i,instr in ipairs(bc)do")
    add("c=((c~(instr." .. bcFieldOp .. "*0x1505))+(#instr." .. bcFieldArgs .. "*0x21))%0xFFFFFFFF")
    add("for j,a in ipairs(instr." .. bcFieldArgs .. ")do c=((c*33)~(a+i+j))%0xFFFFFFFF end")
    add("end")
    add("return c")
    add("end")

    -- Store expected CRC (obfuscated as complex expression)
    local crcPart1 = math.floor(bcCrcValue / 65536)
    local crcPart2 = bcCrcValue % 65536
    local crcObf = math.random(1000, 9999)
    add("local " .. expectedCrc .. "=((" .. (crcPart1 + crcObf) .. "-" .. crcObf .. ")*65536+(" .. (crcPart2 + crcObf) .. "-" .. crcObf .. "))")

    -- Verify at runtime with anti-debug timing
    add("local " .. actualCrc .. "=" .. crcFunc .. "(" .. v[4] .. ")")
    add("if " .. actualCrc .. "~=" .. expectedCrc .. " then")
    add("while true do end")
    add("end")

    -- HOOK DETECTION - verify critical functions haven't been tampered
    local hookCheck = randomString(6)
    local origPrint = randomString(5)
    local origLoad = randomString(5)
    local origType = randomString(5)

    add("local " .. origPrint .. "=tostring(print)")
    add("local " .. origLoad .. "=tostring(load)")
    add("local " .. origType .. "=tostring(type)")
    add("local " .. hookCheck)
    add(hookCheck .. "=function()")
    add("if tostring(print)~=" .. origPrint .. " then while true do end end")
    add("if tostring(load)~=" .. origLoad .. " then while true do end end")
    add("if tostring(type)~=" .. origType .. " then while true do end end")
    add("end")
    add(hookCheck .. "()")  -- initial check

    -- THREADED DISPATCH - each instruction calls next directly (no central loop)
    local dispatch = randomString(6)  -- dispatch function
    local ipVar = randomString(4)     -- ip parameter name

    -- Forward declare dispatch for recursive calls
    add("local " .. dispatch)

    -- Dispatch function with tail-call recursion
    add(dispatch .. "=function(" .. ipVar .. ")")
    add("if " .. ipVar .. ">#" .. v[4] .. " then return end")

    -- Runtime integrity check every N instructions
    add("if " .. ipVar .. "%17==0 then " .. hookCheck .. "()end")

    add("local instr=" .. v[4] .. "[" .. ipVar .. "]")
    add("local op=instr." .. bcFieldOp)
    add("local args=instr." .. bcFieldArgs)
    add("local li=" .. layerMap .. "[op]")
    add("local fn=li and " .. layerArr .. "[li][op]")
    add("if not fn then return " .. dispatch .. "(" .. ipVar .. "+1)end")

    -- Execute handler and get result
    add("local r1,r2=fn(args)")

    -- Handle jump
    add("if r1=='J' then return " .. dispatch .. "(r2)end")

    -- Handle return
    add("if op==" .. returnOp .. " then return r1,r2 end")

    -- Threaded: call next instruction directly (tail call optimization)
    add("return " .. dispatch .. "(" .. ipVar .. "+1)")
    add("end")

    -- Start execution from instruction 1
    add("return " .. dispatch .. "(1)")
    add("end")

    -- Opaque predicate wrapper
    if CONFIG.OPAQUE_PREDICATES then
        add("if " .. OpaquePredicates.alwaysTrue() .. " then")
        add("return " .. v[1] .. "()")
        add("else")
        add(OpaquePredicates.generateDeadCode())
        add("end")
    else
        add("return " .. v[1] .. "()")
    end

    return table.concat(lines, "\n")
end

-- ============================================================================
-- ANTI-DEBUG & ANTI-TAMPER (ULTIMATE)
-- ============================================================================
local function generateAntiDebug()
    local v = {}
    for i = 1, 10 do v[i] = randomString(6) end

    local code = "(function()\n"
    -- Debug hook disable
    code = code .. "local " .. v[1] .. "=debug\n"
    code = code .. "if " .. v[1] .. " then\n"
    code = code .. "if " .. v[1] .. ".sethook then " .. v[1] .. ".sethook(function()end,'',0)end\n"
    code = code .. "if " .. v[1] .. ".setmetatable then\n"
    code = code .. "pcall(function()" .. v[1] .. ".setmetatable(_G,{__index=function(t,k)return rawget(t,k)end})end)\n"
    code = code .. "end\n"
    code = code .. "end\n"

    -- Environment check
    code = code .. "local " .. v[2] .. "=os and os.getenv\n"
    code = code .. "if " .. v[2] .. " then\n"
    code = code .. "local " .. v[3] .. "=" .. v[2] .. "'LUA_DEBUG'\n"
    code = code .. "if " .. v[3] .. " then while true do end end\n"
    code = code .. "end\n"

    -- Timing anti-debug
    if CONFIG.TIMING_ANTI_DEBUG then
        code = code .. "local " .. v[4] .. "=os and os.clock\n"
        code = code .. "if " .. v[4] .. " then\n"
        code = code .. "local " .. v[5] .. "=" .. v[4] .. "()\n"
        code = code .. "for " .. v[6] .. "=1,1000 do end\n"
        code = code .. "local " .. v[7] .. "=" .. v[4] .. "()-" .. v[5] .. "\n"
        code = code .. "if " .. v[7] .. ">0.1 then while true do end end\n"
        code = code .. "end\n"
    end

    code = code .. "end)();\n"
    return code
end

local function generateAntiTamper(codeHash)
    local v = randomString(8)
    local v2 = randomString(8)
    local code = "local " .. v .. "='" .. codeHash .. "'\n"

    if CONFIG.CRC_CHECK then
        code = code .. "local " .. v2 .. "=function(s)local c=0xFFFFFFFF "
        code = code .. "for i=1,#s do local b=s:byte(i) c=c~b "
        code = code .. "for _=1,8 do local m=-(c&1) c=(c>>1)~(0xEDB88320&m)end end "
        code = code .. "return c~0xFFFFFFFF end\n"
    end

    return code
end

-- ============================================================================
-- ENVIRONMENT SANDBOX
-- ============================================================================
local function generateSandbox()
    if not CONFIG.ENVIRONMENT_SANDBOX then return "" end

    local v = {}
    for i = 1, 5 do v[i] = randomString(6) end

    local code = "local " .. v[1] .. "={}\n"
    code = code .. "setmetatable(" .. v[1] .. ",{__index=_G,__newindex=function(t,k,v)rawset(t,k,v)end})\n"
    return code
end

-- ============================================================================
-- METAMETHOD TRAPS
-- ============================================================================
local function generateMetamethodTraps()
    if not CONFIG.METAMETHOD_TRAPS then return "" end

    local v = {}
    for i = 1, 5 do v[i] = randomString(6) end

    local code = "local " .. v[1] .. "=setmetatable({},{\n"
    code = code .. "__index=function(t,k)return rawget(t,k)or _G[k]end,\n"
    code = code .. "__newindex=function(t,k,v)rawset(t,k,v)end,\n"
    code = code .. "__call=function(t,...)return(...)end\n"
    code = code .. "})\n"
    return code
end

-- ============================================================================
-- CONTROL FLOW FLATTENING
-- ============================================================================
local function flattenControlFlow(vmCode)
    if not CONFIG.CONTROL_FLOW_FLATTEN then
        return vmCode
    end

    local stateVar = randomString(6)
    local resultVar = randomString(6)
    local dispatcherVar = randomString(6)
    local funcVar = randomString(6)

    local wrapped = "local " .. stateVar .. "=1\n"
    wrapped = wrapped .. "local " .. resultVar .. "\n"
    wrapped = wrapped .. "local " .. dispatcherVar .. "={\n"
    wrapped = wrapped .. "[1]=function()\n"
    wrapped = wrapped .. resultVar .. "=(function()\n"
    wrapped = wrapped .. vmCode .. "\n"
    wrapped = wrapped .. "end)()\n"
    wrapped = wrapped .. stateVar .. "=0\n"
    wrapped = wrapped .. "end\n"
    wrapped = wrapped .. "}\n"
    wrapped = wrapped .. "while " .. stateVar .. ">0 do\n"
    wrapped = wrapped .. "local " .. funcVar .. "=" .. dispatcherVar .. "[" .. stateVar .. "]\n"
    wrapped = wrapped .. "if " .. funcVar .. " then " .. funcVar .. "() end\n"
    wrapped = wrapped .. "end\n"
    wrapped = wrapped .. "return " .. resultVar .. "\n"
    return wrapped
end

-- ============================================================================
-- SELF-DECRYPTING LAYERS
-- ============================================================================
local function wrapWithSelfDecrypt(code, layers)
    if layers <= 0 then return code end

    local result = code
    for layer = 1, layers do
        local key = generateKey(32)
        local encrypted = xorEncrypt(result, key)
        encrypted = rotateBytes(encrypted, 64)

        local v = {}
        for i = 1, 5 do v[i] = randomString(6) end

        local keyStr = "{" .. table.concat(key, ",") .. "}"

        local wrapper = "local " .. v[1] .. "=" .. escapeString(encrypted) .. "\n"
        wrapper = wrapper .. "local " .. v[2] .. "=" .. keyStr .. "\n"
        wrapper = wrapper .. "local " .. v[3] .. "={}\n"
        wrapper = wrapper .. "for i=1,#" .. v[1] .. " do\n"
        wrapper = wrapper .. "local b=(" .. v[1] .. ":byte(i)-64)%256\n"
        wrapper = wrapper .. v[3] .. "[i]=string.char((b~" .. v[2] .. "[((i-1)%#" .. v[2] .. ")+1])%256)\n"
        wrapper = wrapper .. "end\n"
        wrapper = wrapper .. "load(table.concat(" .. v[3] .. "))()\n"

        result = wrapper
    end
    return result
end

-- ============================================================================
-- MAIN OBFUSCATION
-- ============================================================================
function Obfuscator.obfuscate(source, options)
    options = options or {}
    math.randomseed(os.time() + math.random(1, 10000))

    for k, v in pairs(options) do
        if CONFIG[k] ~= nil then CONFIG[k] = v end
    end

    local tokens = tokenize(source)
    local compiled = compile(tokens)
    local bytecode = compiled.bytecode
    local constants = compiled.constants

    -- Generate base key
    local key = generateKey(32)

    -- DYNAMIC KEY DERIVATION - derive key from source hash
    if CONFIG.DYNAMIC_KEYS then
        key = deriveKeyFromCode(source, key)
    end

    if CONFIG.STRING_ENCRYPTION then
        encryptStrings(constants, key)
    end

    if CONFIG.JUNK_CODE then
        bytecode = injectJunkWithPreservation(bytecode, CONFIG.JUNK_DENSITY)
    end

    -- INSTRUCTION SUBSTITUTION - a+b → a-(-b), etc.
    if CONFIG.INSTRUCTION_SUBSTITUTION then
        bytecode = InstructionSubstitution.apply(bytecode)
    end

    -- BOGUS CONTROL FLOW - inject fake branches
    if CONFIG.BOGUS_CONTROL_FLOW then
        bytecode = BogusControlFlow.inject(bytecode)
    end

    -- INSTRUCTION MUTATION - shuffle opcodes
    local forwardOpcodeMap, reverseOpcodeMap = nil, nil
    if CONFIG.INSTRUCTION_MUTATION then
        forwardOpcodeMap, reverseOpcodeMap = generateOpcodeMapping()
        bytecode = mutateInstructions(bytecode, forwardOpcodeMap)
    end

    -- Calculate bytecode CRC BEFORE encryption (for anti-tamper)
    -- Must match runtime algorithm exactly
    local bcCrcValue = 0x12345678  -- same seed as runtime
    for i, instr in ipairs(bytecode) do
        bcCrcValue = ((bcCrcValue ~ (instr.op * 0x1505)) + (#instr.args * 0x21)) % 0xFFFFFFFF
        for j, arg in ipairs(instr.args) do
            bcCrcValue = ((bcCrcValue * 33) ~ (arg + i + j)) % 0xFFFFFFFF
        end
    end

    -- BYTECODE ENCRYPTION - encrypt the bytecode table
    local bytecodeKey = generateKey(32)
    local bytecodeEncrypted = false
    if CONFIG.BYTECODE_ENCRYPTION then
        bytecode = encryptBytecode(bytecode, bytecodeKey)
        bytecodeEncrypted = true
    end

    -- Generate VM with all options
    local vmCode
    local output

    -- If VM is disabled, just return the source code with minimal wrapper
    if not CONFIG.VM_ENABLED then
        local scriptKey = randomString(24)
        local header = "--[[ Laufuscator v3.0 | " .. scriptKey .. " ]]\n"
        output = header .. source
    else
        local vmOptions = {
            forwardOpcodeMap = forwardOpcodeMap,  -- For shuffled handler indices
            bytecodeEncrypted = bytecodeEncrypted,
            bytecodeKey = bytecodeKey,
            expectedCrc = bcCrcValue  -- Pre-calculated CRC for anti-tamper
        }
        vmCode = generateVM(bytecode, constants, key, vmOptions)

        if CONFIG.CONTROL_FLOW_FLATTEN then
            vmCode = flattenControlFlow(vmCode)
        end

        local antiDebug = CONFIG.ANTI_DEBUG and generateAntiDebug() or ""
        local antiTamper = CONFIG.ANTI_TAMPER and generateAntiTamper(randomString(32)) or ""
        local antiEmulation = CONFIG.ANTI_EMULATION and generateAntiEmulation() or ""
        local stringHiding = CONFIG.STRING_HIDE_RUNTIME and generateStringHiding() or ""
        local sandbox = CONFIG.ENVIRONMENT_SANDBOX and generateSandbox() or ""
        local metamethods = CONFIG.METAMETHOD_TRAPS and generateMetamethodTraps() or ""

        local scriptKey = randomString(24)
        local header = "--[[ Laufuscator v3.0 | " .. scriptKey .. " ]]\n"

        -- Add garbage code
        local garbageCode = ""
        if CONFIG.GARBAGE_CODE then
            for _ = 1, math.random(3, 6) do
                garbageCode = garbageCode .. generateGarbageCode() .. "\n"
            end
        end

        -- Add fake branches
        local fakeBranches = ""
        if CONFIG.FAKE_BRANCHES then
            for _ = 1, math.random(2, 4) do
                fakeBranches = fakeBranches .. OpaquePredicates.generateComplexFakeBranch()
            end
        end

        -- Add opaque predicates at the start
        local preamble = ""
        if CONFIG.OPAQUE_PREDICATES then
            preamble = "if " .. OpaquePredicates.alwaysFalse() .. " then " ..
                       OpaquePredicates.generateDeadCode() .. " end\n"
        end

        output = header .. antiDebug .. antiTamper .. antiEmulation .. stringHiding ..
                       sandbox .. metamethods .. garbageCode .. preamble .. fakeBranches .. vmCode
    end

    -- NESTED VM - wrap code in load() with extra obfuscation layer
    if CONFIG.NESTED_VM then
        local v1, v2, v3, v4 = randomString(6), randomString(6), randomString(6), randomString(6)
        local nestedKey = generateKey(24)
        local nestedKeyStr = "{" .. table.concat(nestedKey, ",") .. "}"

        -- Encrypt the output code
        local encrypted = xorEncrypt(output, nestedKey)
        local escapedCode = escapeString(encrypted)

        -- Build nested wrapper
        local nested = "--[[ Laufuscator NESTED VM ]]\n"
        nested = nested .. "local " .. v1 .. "=" .. escapedCode .. "\n"
        nested = nested .. "local " .. v2 .. "=" .. nestedKeyStr .. "\n"
        nested = nested .. "local " .. v3 .. "={}\n"
        nested = nested .. "for i=1,#" .. v1 .. " do\n"
        nested = nested .. v3 .. "[i]=string.char((" .. v1 .. ":byte(i)~" .. v2 .. "[((i-1)%#" .. v2 .. ")+1])%256)\n"
        nested = nested .. "end\n"
        nested = nested .. "local " .. v4 .. "=load(table.concat(" .. v3 .. "))\n"
        nested = nested .. "if " .. v4 .. " then " .. v4 .. "() end\n"

        output = nested
    end

    -- Self-decrypting layers
    if CONFIG.SELF_DECRYPT_LAYERS > 0 then
        output = wrapWithSelfDecrypt(output, CONFIG.SELF_DECRYPT_LAYERS)
    end

    return output
end

-- ============================================================================
-- CLI
-- ============================================================================
local VERSION = "3.0.0"

local function printHelp()
    print([[
Laufuscator v]] .. VERSION .. [[ - Advanced Lua Code Obfuscator

USAGE:
    lua src/obfuscator.lua [OPTIONS] <input.lua> <output.lua>

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show version information
    -c, --config <path>     Path to config.json (default: config/config.json)
    -q, --quiet             Suppress output messages

EXAMPLES:
    lua src/obfuscator.lua input.lua output.lua
    lua src/obfuscator.lua -c myconfig.json input.lua output.lua
    lua src/obfuscator.lua --quiet input.lua output.lua

CONFIGURATION:
    All obfuscation options are configured via config/config.json.
    See README.md for detailed configuration documentation.

For more information, visit: https://github.com/TheRemyyy/laufuscator
]])
end

local function printVersion()
    print("Laufuscator v" .. VERSION)
    print("Advanced Lua Code Obfuscator")
    print("Copyright (c) 2025 TheRemyyy")
end

local function parseArgs(args)
    local options = {
        configPath = nil,
        inputFile = nil,
        outputFile = nil,
        quiet = false,
        help = false,
        version = false,
    }

    local i = 1
    while i <= #args do
        local arg = args[i]
        if arg == "-h" or arg == "--help" then
            options.help = true
        elseif arg == "-v" or arg == "--version" then
            options.version = true
        elseif arg == "-q" or arg == "--quiet" then
            options.quiet = true
        elseif arg == "-c" or arg == "--config" then
            i = i + 1
            if i <= #args then
                options.configPath = args[i]
            else
                print("Error: --config requires a path argument")
                return nil
            end
        elseif arg:sub(1, 1) == "-" then
            print("Error: Unknown option '" .. arg .. "'")
            print("Use --help for usage information")
            return nil
        else
            if not options.inputFile then
                options.inputFile = arg
            elseif not options.outputFile then
                options.outputFile = arg
            else
                print("Error: Too many arguments")
                return nil
            end
        end
        i = i + 1
    end

    return options
end

local function main(args)
    local options = parseArgs(args)
    if not options then return 1 end

    if options.help then
        printHelp()
        return 0
    end

    if options.version then
        printVersion()
        return 0
    end

    if not options.inputFile or not options.outputFile then
        print("Error: Input and output files are required")
        print("Use --help for usage information")
        return 1
    end

    -- Determine config path
    local configPath = options.configPath
    if not configPath then
        -- Try to find config relative to script location
        local scriptDir = getScriptDir()
        configPath = scriptDir .. "../config/config.json"
        -- Normalize path separators
        configPath = configPath:gsub("\\", "/")
    end

    -- Load config
    local configOk, configErr = loadConfig(configPath)
    if not configOk then
        if not options.quiet then
            print("Warning: " .. configErr)
            print("Using default configuration")
        end
    elseif not options.quiet then
        print("Loaded config from: " .. configPath)
    end

    -- Read input file
    local f = io.open(options.inputFile, "r")
    if not f then
        print("Error: Cannot open input file '" .. options.inputFile .. "'")
        return 1
    end
    local source = f:read("*all")
    f:close()

    if not options.quiet then
        print("")
        print("╔═══════════════════════════════════════════════════════════════╗")
        print("║         Laufuscator v" .. VERSION .. " - Code Obfuscator             ║")
        print("╚═══════════════════════════════════════════════════════════════╝")
        print("")
        print("  Input:  " .. options.inputFile)
        print("  Output: " .. options.outputFile)
        print("")
        print("  Obfuscating...")
    end

    local startTime = os.clock()
    local obfuscated = Obfuscator.obfuscate(source)
    local endTime = os.clock()

    local out = io.open(options.outputFile, "w")
    if not out then
        print("Error: Cannot write to output file '" .. options.outputFile .. "'")
        return 1
    end
    out:write(obfuscated)
    out:close()

    if not options.quiet then
        print("")
        print("  ✓ Done in " .. string.format("%.3f", endTime - startTime) .. "s")
        print("")
        print("  ┌─────────────────────────────────────┐")
        print("  │  Original:   " .. string.format("%8d", #source) .. " bytes       │")
        print("  │  Obfuscated: " .. string.format("%8d", #obfuscated) .. " bytes       │")
        print("  │  Ratio:      " .. string.format("%8.1f", #obfuscated / #source) .. "x            │")
        print("  └─────────────────────────────────────┘")
        print("")
    end

    return 0
end

if arg and arg[0] then
    os.exit(main(arg) or 0)
end

return Obfuscator
