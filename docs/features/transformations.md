# Code Transformations

Laufuscator performs low-level mutations to the Lua logic, turning simple operations into complex, incomprehensible expressions.

## 🧮 Mixed Boolean-Arithmetic (MBA)

The engine can automatically substitute standard arithmetic operations with complex bitwise equivalents. These are implemented both in the compiler and within the VM handlers.

### Addition Transformation
- **Original**: `a + b`
- **MBA**: `(a ~ b) + 2 * (a & b)` (where `~` is XOR)

### Subtraction Transformations
Laufuscator randomly selects between multiple variants:
1.  `(a ~ b) - 2 * (~a & b)`
2.  `a + (~b + 1)` (Two's complement)
3.  `(a | b) - (a & b) - b`

### Bitwise Logic
- `a | b` → `(a & ~b) + b`
- `a & b` → `(a | b) - (a ~ b)`

## 🧩 Instruction Substitution

During compilation, Laufuscator applies **Instruction Substitution** to the bytecode stream:
- **Arithmetic folding**: `a * 2` is replaced by `DUP + ADD` (duplicate top of stack and add).
- **Negation folding**: `a - b` is replaced by `NEG + ADD` (negate `b` and add to `a`).

## 🗑️ Junk Code & NOP Insertion

The engine injects "No-Operation" (`NOP`) instructions throughout the bytecode. 
- **Density**: Controlled by `junk_density` (default 0.3).
- **Control Flow Preservation**: Jump targets are automatically recalculated to account for the shifted instruction offsets.
- **Garbage code**: Randomized Lua statements (e.g., `local x = 432 * 12`) are injected between VM initialization steps.

## 🎭 Opaque Predicates

Laufuscator inserts "Opaque Predicates" — logical checks that always evaluate to a constant value but look complex:
- **Always True**: `(math.pi > 3)`, `(type('') == 'string')`, `(7 * 7 == 49)`.
- **Always False**: `(math.pi < 3)`, `(#{} ~= 0)`, `(1 == 0)`.

These are used to wrap the VM execution or to create **Bogus Control Flow** (fake branches that appear to lead to valid code but are unreachable).