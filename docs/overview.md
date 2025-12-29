# Laufuscator Documentation

Welcome to the comprehensive documentation for **Laufuscator v3.0** — the ultimate Lua code protection system.

Laufuscator is a professional-grade obfuscator that virtualizes your Lua code into a custom, secure representation. By combining a unique Virtual Machine architecture with multi-layer encryption and mathematical transformations, it provides the highest level of security for your Lua assets.

## 🔑 Key Protection Features

- 💻 **[Virtual Machine (VM)](features/virtual-machine.md)** — Custom bytecode execution with randomized opcodes and polymorphic handlers.
- 🔐 **[Multi-Layer Encryption](features/encryption.md)** — XOR, Rotation, and S-Box substitution for strings, bytecode, and interpreter logic.
- 🔄 **[Control Flow Obfuscation](features/control-flow.md)** — Flattening, bogus paths, and opaque predicates to hide program logic.
- 🧪 **[Code Transformations](features/transformations.md)** — Mixed Boolean-Arithmetic (MBA) and instruction mutation.
- 🛡️ **[Security Measures](features/security.md)** — Anti-debug, anti-tamper (CRC32), and anti-emulation protections.

## 📖 How to use this documentation

If you are new to Laufuscator, start with the **[Overview](overview.md)** and the **[Configuration Guide](technical/configuration.md)**. 

If you want to understand the hiearchy and technical depth:
1.  Read about the **[Architecture](technical/architecture.md)** to see how the pipeline works.
2.  Explore the **[Features](features/)** section to understand specific protection techniques.
3.  Consult the **[Performance Impact](technical/performance.md)** guide to optimize your obfuscated scripts.

## 🚀 Quick Start

1.  Place your source code in the `examples/` directory.
2.  Configure your protection levels in `config/config.json`.
3.  Run the obfuscator:
    ```bash
    lua src/obfuscator.lua input.lua output.lua
    ```
4.  Distribute the resulting `output.lua` — your code is now protected!

---
*Built for Lua 5.4. Maximum Security. Zero Compromises.*
