# Virtual Machine (VM) Protection

Laufuscator's Virtual Machine (VM) is a custom interpreter written entirely in Lua. It replaces the standard Lua execution flow with a secure, randomized instruction set.

## Instruction Set Architecture

The VM uses a stack-based architecture with approximately 37 core opcodes (shuffled and mutated for each session).

### Key Opcodes
- `LOAD_CONST (1)`: Pushes a constant from the encrypted pool onto the stack.
- `LOAD_VAR / STORE_VAR (2/3)`: Manages local variable access via an obfuscated mapping.
- `CALL (6)`: Executes functions with dynamic argument counts.
- `CLOSURE (37)`: Handles function definitions by compiling source strings on-the-fly.
- `JMP / JMP_IF / JMP_IF_NOT (26-28)`: Controls program flow using relative offsets.

## Polymorphic Handlers

One of Laufuscator's strongest features is its **Polymorphic Handler Table**. Each opcode in the VM does not have a static implementation. Instead, it is selected from a pool of equivalent variants:

- **Variant A**: Direct implementation using standard Lua operators.
- **Variant B**: Indirect implementation using helper functions and proxy variables.
- **Variant C**: Obfuscated implementation using Mixed Boolean-Arithmetic (MBA).

During obfuscation, the engine randomly picks one variant for each instruction, ensuring that the interpreter's source code is different every single time.

## Bytecode Security

### 1. Opcode Shuffling
Laufuscator performs a Fisher-Yates shuffle on the opcode mapping. An `ADD` instruction in one script may be opcode `8`, while in another it becomes `42`.

### 2. Encryption Layers
The bytecode table is encrypted using a session-specific key. Each instruction is decrypted using a bitwise XOR transition:
`op = (instr.op ~ keyByte) % 256`

### 3. Field Mangling
Internal bytecode fields (opcode and arguments) use randomized identifiers (e.g., `instr.xY2` instead of `instr.op`) to prevent pattern-matching attacks.

## Virtual Machine Dispatcher

The VM uses a **Threaded Dispatch** mechanism. Instead of a large central `while-true-switch` loop (which is easy to analyze), each handler calls the next instruction directly via tail-call recursion:
```lua
local function dispatch(ip)
    local instr = bc[ip]
    local fn = handlers[instr.op]
    local r1, r2 = fn(instr.args)
    if r1 == 'J' then return dispatch(r2) end -- Handle Jump
    return dispatch(ip + 1) -- Next instruction
end
```
This flattens the execution flow and makes traditional debugging nearly impossible.