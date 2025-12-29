# Control Flow Obfuscation

Control Flow obfuscation hides the logical structure of your program, making it impossible to follow the "story" of your code.

## Techniques

### 1. Control Flow Flattening (CFF)
Laufuscator supports two levels of flattening (both enabled by default):
- **Dispatcher-based** (`control_flow_flatten`): Wraps the VM execution in a `while` loop with a state-based dispatcher.
- **Real CFG Flattening** (`real_cfg_flatten`): Operates at the bytecode level, splitting instructions into blocks and inserting jumps to randomized offsets with NOP padding.

### 2. Opaque Predicates
These are conditional statements that Laufuscator knows the result of, but an analyzer does not.

**Real examples from `obfuscator.lua`:**
- `alwaysTrue`: `((7*7)==49)`, `(type('')=='string')`, `(math.pi>3)`
- `alwaysFalse`: `((7*7)==50)`, `(type('')=='number')`, `(math.pi<3)`

These are used to wrap critical logic or to guard "Dead Code" that would otherwise be removed by minifiers.

### 3. Bogus Control Flow
Enabled by `bogus_control_flow`. Laufuscator injects **Fake Branches** into the bytecode. It pushes a `true` value and then uses a `JMP_IF` to skip a block of "fake code" that looks like valid logic but is never executed.

### 4. MBA (Mixed Boolean-Arithmetic)
MBA transformations replace arithmetic with bitwise identities found in `MBA.transformAdd` and `MBA.transformSub`.

**Example:**
- `a + b` becomes `((a~b)+2*(a&b))`
- `a - b` becomes `((a~b)-2*(~a&b))`

## Configuration

Control flow settings in `config/config.json`:
```json
"control_flow": {
    "control_flow_flatten": true,
    "real_cfg_flatten": true,
    "opaque_predicates": true,
    "fake_branches": true,
    "bogus_control_flow": true
}
```
