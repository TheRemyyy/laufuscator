# Anti-Tamper & Security Measures

Laufuscator implements a multi-layered defense strategy to protect the Virtual Machine and the encrypted payload at runtime.

## 🛡️ Integrity Protection

### Bytecode CRC Verification
Laufuscator calculates a specific CRC value for the bytecode stream:
`c = ((c ~ (op * 0x1505)) + (#args * 0x21)) % 0xFFFFFFFF`
If any instruction or argument is modified, the VM will enter an infinite loop or crash, preventing unauthorized modification of logic (like license checks). Enabled by `crc_check` and `anti_tamper`.

### Hook Detection
The VM periodically checks if standard Lua functions have been replaced by hooks:
```lua
if tostring(print) ~= origPrintStr then while true do end end
```
This detects many common "dumpers" that try to intercept `print` or `load` to see the original code or constants.

## ⏱️ Anti-Debugging & Timing

### Timing Analysis
Laufuscator uses `os.clock()` to measure the time taken for a simple loop. If the execution takes longer than 0.1 seconds, it assumes a debugger is attached or the environment is heavily throttled/emulated (enabled by `timing_anti_debug`).

### Debug Hook Clearing
If `anti_debug` is enabled, the protection calls `debug.sethook(function()end, '', 0)` to neutralize any external debuggers attempting to step through the VM execution.

## 🕵️ Anti-Emulation & Sandbox Detection

Laufuscator's `generateAntiEmulation` function (controlled by `anti_emulation`) checks for:
- Existence of `collectgarbage` and `coroutine.create`.
- Consistency of the `_VERSION` global (must be Lua 5.x).
- Presence of critical libraries like `math` and `table`.
- Abnormal timing spikes during simple operations.

## 🔒 Environment Sandboxing

If `environment_sandbox` is enabled, the VM runs within a proxy environment:
- It creates a new table for the script's globals.
- It uses a metatable to control access to the real `_G`.
- This prevents the obfuscated script from easily polluting the global space or being inspected by parent scripts.

## Configuration

Security settings in `config.json`:
```json
"protection": {
    "anti_debug": true,
    "anti_tamper": true,
    "anti_emulation": true,
    "crc_check": true,
    "timing_anti_debug": true
},
"runtime": {
    "environment_sandbox": true,
    "metamethod_traps": true
}
```
