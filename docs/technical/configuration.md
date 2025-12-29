# Configuration Reference

Laufuscator is controlled by a central `config/config.json` file. Below is the complete list of available options, their types, and default values as defined in the engine.

## 🛠️ Obfuscation Settings (`obfuscation`)

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `vm_enabled` | `bool` | `true` | Enables the Virtual Machine execution engine. |
| `nested_vm` | `bool` | `true` | Wraps the output in an additional layer of virtualization. |
| `self_decrypt_layers`| `int` | `2` | Number of recursive self-decryption wrappers. |

## 🔐 Encryption Settings (`encryption`)

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `string_encryption` | `bool` | `true` | Encrypt all string literals. |
| `string_splitting` | `bool` | `true` | Break long strings into fragments. |
| `multi_layer_encrypt`| `bool` | `true` | Apply byte rotation (Layer 2) to constants. |
| `bytecode_encryption`| `bool` | `true` | Encrypt the custom VM bytecode table. |
| `dynamic_keys` | `bool` | `true` | Derive keys from the source code hash. |
| `encryption_layers` | `int` | `3` | Total number of encryption rounds (max 3). |
| `split_min_length` | `int` | `4` | Minimum string length required for splitting. |

## 🔄 Control Flow Settings (`control_flow`)

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `control_flow_flatten`| `bool` | `true` | Apply dispatcher-based control flow flattening. |
| `real_cfg_flatten` | `bool` | `true` | Advanced basic-block level flattening. |
| `opaque_predicates` | `bool` | `true` | Insert always true/false conditional checks. |
| `fake_branches` | `bool` | `true` | Add logic branches that lead to junk code. |
| `bogus_control_flow` | `bool` | `true` | Inject fake execution paths into the bytecode. |

## 🧪 Transformations (`transformations`)

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `variable_substitution`| `bool` | `true` | Replace numbers with complex calculations. |
| `constant_obfuscation` | `bool` | `true` | Obfuscate constant values in the pool. |
| `instruction_mutation` | `bool` | `true` | Randomize the opcode mapping (shuffling). |
| `instruction_substitution`| `bool` | `true` | Substitute instructions (e.g., `add` -> `neg+sub`). |
| `function_outline` | `bool` | `true` | Move logic into separate helper functions. |
| `variable_mangle` | `bool` | `true` | Mangle internal VM variable names. |
| `mba_obfuscation` | `bool` | `true` | Apply Mixed Boolean-Arithmetic transformations. |

## 🛡️ Protection Settings (`protection`)

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `anti_debug` | `bool` | `true` | Enable debug hook detection and clearing. |
| `anti_tamper` | `bool` | `true` | Enable runtime integrity verification. |
| `anti_emulation` | `bool` | `true` | Detect sandboxes and emulators via timing/env. |
| `crc_check` | `bool` | `true` | Bytecode-level CRC32 integrity check. |
| `timing_anti_debug` | `bool` | `true` | Measure execution time to detect stepping. |

## 📦 Code Injection (`code_injection`)

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `junk_code` | `bool` | `true` | Inject NOP instructions into the bytecode. |
| `garbage_code` | `bool` | `true` | Add dead variable declarations and logic. |
| `junk_density` | `float`| `0.3` | Probability of junk insertion (0.0 to 1.0). |

## ⚙️ Runtime Settings (`runtime`)

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `environment_sandbox`| `bool` | `true` | Isolate the execution environment via proxy `_G`. |
| `metamethod_traps` | `bool` | `true` | Use `__index` and `__call` traps for obfuscation. |
| `string_hide_runtime`| `bool` | `true` | Hide strings from memory after first use. |
