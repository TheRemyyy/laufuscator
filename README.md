<div align="center">

# Laufuscator

**Advanced Lua Code Obfuscator**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Lua 5.4](https://img.shields.io/badge/Lua-5.4-blue.svg?style=flat-square)](https://www.lua.org/)

*VM-Based Protection. Multi-Layer Encryption. Maximum Security.*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Documentation](#-documentation)

</div>

---

## Overview

Laufuscator is a powerful Lua code obfuscator that transforms your scripts into heavily protected bytecode using a custom virtual machine. It employs multiple layers of encryption, anti-tampering measures, and code transformation techniques to make reverse engineering extremely difficult.

### ⚡ Key Features

- **💻 VM-Based Execution** — Custom bytecode and polymorphic interpreter.
- **🔐 Multi-Layer Encryption** — XOR + rotation encoding for all assets.
- **🛡️ Anti-Tampering** — CRC checksums and integrity verification.
- **🔄 Control Flow Flattening** — Dispatcher-based logic hiding.
- **🧪 Advanced Transformations** — MBA, Junk Code, and Instruction Mutation.

## 📦 Installation

1. **Requirements**: Lua 5.4+
2. **Setup**:
   ```bash
   git clone https://github.com/TheRemyyy/laufuscator.git
   cd laufuscator
   ```

## ⚡ Usage

```bash
lua src/obfuscator.lua [OPTIONS] <input.lua> <output.lua>
```

---

## <a id="documentation"></a>📄 Documentation

For in-depth technical details and configuration guides, explore our documentation:

### Protection Features
- 💻 **[Virtual Machine (VM)](docs/features/virtual-machine.md)** — Core bytecode engine.
- 🔐 **[Encryption](docs/features/encryption.md)** — Data hiding and dynamic keys.
- 🔄 **[Control Flow](docs/features/control-flow.md)** — Flattening and opaque predicates.
- 🧪 **[Transformations](docs/features/transformations.md)** — MBA and code mutation.
- 🛡️ **[Security Measures](docs/features/security.md)** — Anti-debug and anti-tamper.

### Technical & Reference
- 📖 **[Documentation Overview](docs/overview.md)** — Start here.
- ⚙️ **[Configuration Guide](docs/technical/configuration.md)** — Full `config.json` reference.
- 🏗️ **[Internal Architecture](docs/technical/architecture.md)** — The obfuscation pipeline.
- 🚀 **[Performance Impact](docs/technical/performance.md)** — Security vs Speed trade-offs.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
<sub>Built with ❤️ and Lua</sub>
</div>