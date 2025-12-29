# Encryption & Data Hiding

Laufuscator employs a multi-round, symmetric encryption system to protect constants, bytecode, and even the VM's own logic.

## 🛡️ Multi-Layer Constant Encryption

Constants (strings and function sources) are protected by three distinct layers:

1.  **Bitwise XOR**: Initial encryption with a 32-byte dynamic key.
2.  **Byte Rotation**: Rotating byte values by 128 to shift the character set (enabled by `multi_layer_encrypt`).
3.  **Derived Key XOR**: A third layer using a key derived from the base key using the formula `(key[i] * 7 + 13) % 256`.

### String Splitting
For strings longer than **4 characters** (configurable via `split_min_length`), Laufuscator splits the encrypted payload into 2-4 random fragments. These fragments are concatenated and decrypted only at the moment the VM loads them into the constant pool.

## 🌀 S-Box Handler Encryption

The VM's instruction handlers (the logic that executes bytecode) are themselves encrypted using a complex **Multi-Round Substitution Cipher**:

1.  **Round 1**: XOR with a 16-byte handler key.
2.  **Round 2**: **S-Box Substitution** — Every byte is passed through a randomized 256-byte substitution table (permutation).
3.  **Round 3**: XOR with a position-rotated key `(key[(i*7+3)%16]+1)`.

This ensures that the "source code" of the handlers is never stored in plain text, even within the obfuscated script.

## 🔑 Dynamic Key Derivation

Encryption keys are not static. Laufuscator generates a unique 32-byte base key for every session. 

If **Dynamic Keys** are enabled, the key is further modified based on the CRC32 hash of the original source code. If the source is modified, the key derivation will fail, leading to an immediate crash or garbage output when the VM attempts to decrypt constants.

## 🌫️ Runtime Hiding

Laufuscator can use **Weak Metatable Traps** to prevent strings from lingering in memory (enabled by `string_hide_runtime`):
- Strings are stored in a table with the `__mode = 'v'` (weak values) metatag.
- This allows the Lua Garbage Collector to remove decrypted strings as soon as they are no longer in active use, making memory dumps less effective.
