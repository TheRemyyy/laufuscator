<div align="center">

# Contributing to Laufuscator

**Help us build the most advanced Lua obfuscator**

</div>

---

## Introduction

Thank you for your interest in contributing to Laufuscator! We welcome contributions from everyone, whether it's fixing a bug, improving documentation, or proposing new obfuscation techniques.

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:

    ```bash
    git clone https://github.com/YOUR_USERNAME/laufuscator.git
    cd laufuscator
    ```

3. **Create a branch** for your feature or fix:

    ```bash
    git checkout -b feature/amazing-feature
    ```

## Development

### Requirements

- Lua 5.4+ (required for bitwise operators)
- A text editor with Lua support

### Testing Your Changes

Run the obfuscator on the example files to verify your changes work correctly:

```bash
lua obfuscator.lua examples/basic.lua test_output.lua
lua test_output.lua
```

### Code Style

- Use 4-space indentation
- Keep functions focused and single-purpose
- Add comments for complex obfuscation techniques
- Use descriptive variable names (except in generated obfuscated code)

## Pull Requests

1. Ensure your changes work with all example files
2. Update documentation if you're adding new features
3. Add comments explaining any new obfuscation techniques
4. Submit a Pull Request to the `main` branch

### Commit Messages

Use clear, descriptive commit messages:

```
feat: add new MBA transformation for XOR operations
fix: correct jump target calculation in control flow flattening
docs: update configuration options in README
```

## Ideas for Contributions

- New opaque predicate patterns
- Additional MBA (Mixed Boolean-Arithmetic) transformations
- Improved anti-analysis techniques
- Performance optimizations
- Better error messages and debugging output
- Support for additional Lua versions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

<div align="center">
<sub>Built with ❤️ and Lua</sub>
</div>
