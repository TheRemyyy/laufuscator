# Performance & Size Impact

Obfuscation involves a trade-off between security and execution speed. Laufuscator's VM-based approach significantly impacts the script's performance and file size.

## 🚀 Execution Speed

The Virtual Machine introduces an interpreter overhead. Instead of Lua executing native bytecode, it executes custom bytecode through a Lua-based interpreter.

### Factors Affecting Speed:
1.  **Instruction Count**: Features like `InstructionSubstitution` (e.g., changing `add` to `neg + sub`) increase the total number of VM operations.
2.  **MBA Complexity**: Mixed Boolean-Arithmetic expressions are computationally more expensive than standard operators.
3.  **Nested VM**: Enabling `nested_vm` runs a VM inside another VM, multiplying the interpreter overhead.
4.  **Anti-Debug/Tamper**: Periodic runtime checks (CRC, Hook Detection) add minor pauses during execution.

**Typical performance overhead:**
- **Standard VM**: 2x - 5x slower than original Lua.
- **Nested VM**: 10x - 50x slower.

## 📦 File Size

Obfuscation significantly increases the final file size because it must include the VM interpreter, constant pool, and decryption logic.

### Size Factors:
- **Junk Density**: A `junk_density` of 0.3 means roughly 30% of the bytecode consists of NOPs.
- **Garbage Code**: Injected dead logic and fake branches add literal lines to the script.
- **Self-Decrypting Layers**: Each layer (`self_decrypt_layers`) adds a loader and an encrypted version of the previous layer.
- **Encryption Overheads**: Representing strings as escaped byte sequences (e.g., `\043\122...`) roughly triples the size of string constants.

## 💡 Optimization Best Practices

1.  **Targeted Obfuscation**: If your script has a performance-critical hot loop (e.g., complex math running 60 times per second), consider putting that logic in a separate file or using lower protection levels for that specific module.
2.  **Balanced Junk**: Keep `junk_density` around `0.1` to `0.2` for a good balance between size and security.
3.  **Layer Control**: Avoid more than 2 `self_decrypt_layers` unless your script is very small, as the recursive loading can become slow and bloat the file.