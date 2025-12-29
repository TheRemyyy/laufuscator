# Internal Architecture

Laufuscator is a self-contained obfuscation engine implemented in a single Lua module (`src/obfuscator.lua`). It follows a classic compiler-compiler pipeline tailored for security.

## The Obfuscation Pipeline

### 1. Lexical Analysis (`tokenize`)
Converts raw source code into tokens. Handles standard Lua 5.4 syntax, including bitwise operators and complex escape sequences.

### 2. Compilation (`compile`)
A custom compiler that builds an Abstract Syntax Tree (AST) and generates Laufuscator's internal bytecode. It maps Lua logic to 37+ custom opcodes.

### 3. Transformation Passes
Multiple passes are applied to the intermediate bytecode and constants:
- **InstructionSubstitution**: Replaces simple math with bitwise logic (e.g., `add` -> `neg` + `sub`).
- **BogusControlFlow**: Injects unreachable logic paths using opaque predicates.
- **JunkInjection**: Injects `NOP` instructions and garbage code.
- **MBA Transformation**: Rewrites arithmetic into bitwise identities.
- **Opcode Shuffling**: Randomizes the opcode mapping for the current session.

### 4. VM Synthesis (`generateVM`)
Generates the unique interpreter. It includes:
- **Polymorphic Handlers**: Multiple randomized implementations for each opcode.
- **S-Box Encryption**: The handler logic is encrypted using a substitution cipher.
- **Integrity Layer**: Injects CRC32 and hook detection logic.

### 5. Final Packaging
- **Nested VM**: Wraps the result in an additional layer of virtualization.
- **Self-Decrypting Layers**: Recursive XOR/Rotation wrappers are applied to the final output.

## Core Data Structures

| Structure | Description |
| :--- | :--- |
| **Bytecode Table** | Encrypted list of `{op, args}` instructions. |
| **Constant Pool** | Encrypted table of strings, numbers, and sub-functions. |
| **Handler Table** | Session-unique opcode implementations distributed across multiple layers. |
| **S-Box** | Random permutation table used for handler encryption. |

## Technical Implementation Details

- **Tail-Call Dispatch**: The VM uses recursive tail-calls for instruction dispatching to avoid the detection of a central loop.
- **Environment Proxy**: A sandbox environment (`_G` proxy) is used to isolate the script and trap metamethod calls.
- **Weak Table Runtime**: Decrypted strings are managed via weak tables to minimize their lifespan in system memory.
