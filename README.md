<div align="center">

# Laufuscator

**Advanced Lua Code Obfuscator**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Lua 5.4](https://img.shields.io/badge/Lua-5.4-blue.svg?style=flat-square)](https://www.lua.org/)

*VM-Based Protection. Multi-Layer Encryption. Maximum Security.*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Configuration](#-configuration)

</div>

---

## Overview

Laufuscator is a powerful Lua code obfuscator that transforms your scripts into heavily protected bytecode using a custom virtual machine. It employs multiple layers of encryption, anti-tampering measures, and code transformation techniques to make reverse engineering extremely difficult.

### ⚡ Features

- **VM-Based Execution** — Compiles Lua to custom bytecode executed by an embedded virtual machine
- **🔐 Multi-Layer Encryption** — XOR + rotation + split encoding for strings and bytecode
- **🛡️ Anti-Tampering** — CRC checksums, hook detection, and integrity verification
- **🔄 Control Flow Flattening** — Dispatcher-based execution hides program logic
- **🎭 Polymorphic Handlers** — Multiple equivalent implementations for each operation
- **🧩 Opaque Predicates** — Always-true/false conditions that confuse decompilers
- **⏱️ Anti-Debug** — Timing checks and debug hook neutralization
- **📦 Nested VM** — Optional double-layer VM protection
- **🗑️ Junk Code Injection** — Dead code and fake branches obscure real logic

## 📦 Installation

1. **Requirements**: Lua 5.4+ (uses bitwise operators)

2. **Clone the repository**:

   ```bash
   git clone https://github.com/TheRemyyy/laufuscator.git
   cd laufuscator
   ```

3. **Verify installation**:

   ```bash
   lua src/obfuscator.lua --version
   ```

## ⚡ Usage

### Command Line Interface

```bash
lua src/obfuscator.lua [OPTIONS] <input.lua> <output.lua>
```

### Options

| Option | Description |
| ------ | ----------- |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version information |
| `-c`, `--config <path>` | Path to config.json (default: `config/config.json`) |
| `-q`, `--quiet` | Suppress output messages |

### Examples

```bash
# Basic usage
lua src/obfuscator.lua examples/basic.lua output.lua

# With custom config
lua src/obfuscator.lua -c my_config.json input.lua output.lua

# Quiet mode
lua src/obfuscator.lua --quiet input.lua output.lua
```

### Programmatic Usage

```lua
local Obfuscator = require("src.obfuscator")

local source = [[
    print("Hello, World!")
]]

local obfuscated = Obfuscator.obfuscate(source)
print(obfuscated)
```

## ⚙️ Configuration

All obfuscation options are configured via `config/config.json`. The configuration is organized into logical sections:

### Obfuscation

```json
{
    "obfuscation": {
        "vm_enabled": true,
        "nested_vm": true,
        "self_decrypt_layers": 2
    }
}
```

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `vm_enabled` | bool | `true` | Enable VM-based bytecode execution |
| `nested_vm` | bool | `true` | Wrap output in additional encryption layer |
| `self_decrypt_layers` | int | `2` | Number of self-decrypting wrappers |

### Encryption

```json
{
    "encryption": {
        "string_encryption": true,
        "string_splitting": true,
        "multi_layer_encrypt": true,
        "bytecode_encryption": true,
        "dynamic_keys": true,
        "encryption_layers": 3,
        "split_min_length": 4
    }
}
```

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `string_encryption` | bool | `true` | Encrypt all string constants |
| `string_splitting` | bool | `true` | Split encrypted strings into parts |
| `multi_layer_encrypt` | bool | `true` | Apply multiple encryption layers |
| `bytecode_encryption` | bool | `true` | Encrypt the bytecode table |
| `dynamic_keys` | bool | `true` | Derive keys from source code hash |
| `encryption_layers` | int | `3` | Number of string encryption layers |
| `split_min_length` | int | `4` | Minimum string length for splitting |

### Control Flow

```json
{
    "control_flow": {
        "control_flow_flatten": true,
        "opaque_predicates": true,
        "fake_branches": true,
        "bogus_control_flow": false,
        "real_cfg_flatten": false
    }
}
```

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `control_flow_flatten` | bool | `true` | Apply control flow flattening |
| `opaque_predicates` | bool | `true` | Insert opaque predicates |
| `fake_branches` | bool | `true` | Add fake code branches |
| `bogus_control_flow` | bool | `false` | Inject bogus control flow (experimental) |
| `real_cfg_flatten` | bool | `false` | Real CFG flattening (experimental) |

### Code Injection

```json
{
    "code_injection": {
        "junk_code": false,
        "garbage_code": true,
        "junk_density": 0.3
    }
}
```

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `junk_code` | bool | `false` | Inject NOP instructions (experimental) |
| `garbage_code` | bool | `true` | Add dead variable declarations |
| `junk_density` | float | `0.3` | Probability of junk code insertion (0.0-1.0) |

### Transformations

```json
{
    "transformations": {
        "variable_substitution": true,
        "constant_obfuscation": true,
        "instruction_mutation": true,
        "instruction_substitution": false,
        "function_outline": true,
        "variable_mangle": true,
        "mba_obfuscation": true
    }
}
```

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `variable_substitution` | bool | `true` | Substitute numbers with expressions |
| `constant_obfuscation` | bool | `true` | Obfuscate constant values |
| `instruction_mutation` | bool | `true` | Shuffle opcodes |
| `instruction_substitution` | bool | `false` | Substitute instructions (experimental) |
| `function_outline` | bool | `true` | Outline helper functions |
| `variable_mangle` | bool | `true` | Mangle variable names |
| `mba_obfuscation` | bool | `true` | Mixed Boolean-Arithmetic transformations |

### Protection

```json
{
    "protection": {
        "anti_debug": true,
        "anti_tamper": true,
        "anti_emulation": false,
        "crc_check": true,
        "timing_anti_debug": false
    }
}
```

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `anti_debug` | bool | `true` | Enable anti-debugging measures |
| `anti_tamper` | bool | `true` | Enable tamper detection |
| `anti_emulation` | bool | `false` | Detect sandbox/emulator (experimental) |
| `crc_check` | bool | `true` | CRC checksum verification |
| `timing_anti_debug` | bool | `false` | Timing-based debug detection (experimental) |

### Runtime

```json
{
    "runtime": {
        "environment_sandbox": true,
        "metamethod_traps": true,
        "string_hide_runtime": true
    }
}
```

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `environment_sandbox` | bool | `true` | Sandbox the execution environment |
| `metamethod_traps` | bool | `true` | Add metamethod-based traps |
| `string_hide_runtime` | bool | `true` | Hide strings at runtime |

## 📁 Project Structure

```text
laufuscator/
├── src/
│   └── obfuscator.lua     # Main obfuscator module
├── config/
│   └── config.json        # Configuration file
├── lua/                   # Lua runtime binaries (Windows)
│   ├── lua54.dll
│   ├── lua54.exe
│   └── ...
├── examples/              # Example Lua scripts
│   ├── basic.lua
│   ├── functions.lua
│   └── comprehensive.lua
├── LICENSE
├── README.md
└── CONTRIBUTING.md
```

## 🔧 How It Works

1. **Lexing** — Source code is tokenized into a stream of tokens
2. **Compilation** — Tokens are compiled to custom bytecode
3. **Encryption** — Strings and bytecode are encrypted with derived keys
4. **Transformation** — Control flow is flattened, junk code is injected
5. **VM Generation** — A polymorphic VM interpreter is generated
6. **Wrapping** — Output is wrapped in nested encryption layers

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
<sub>Built with ❤️ and Lua</sub>
</div>
