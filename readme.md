
# Lua Bytecode Utility

A high-performance Lua Bytecode Decompiler & Interpreter for Lua 5.1.5, designed to help developers analyze and execute compiled Lua scripts efficiently.

[![Forks](https://img.shields.io/github/forks/spxnso/lbu?style=social)](https://github.com/spxnso/lbu/forks)
[![Stars](https://img.shields.io/github/stars/spxnso/lbu?style=social)](https://github.com/spxnso/lbu/stars)
[![Issues](https://img.shields.io/github/issues/spxnso/lbu)](https://github.com/spxnso/lbu/issues)
[![License](https://img.shields.io/github/license/spxnso/lbu)](https://github.com/spxnso/lbu/blob/main/LICENSE)

---

## Features

- **Optimized Performance**: Fast decompilation & interpretation for complex Lua bytecode files.
- **Opcode Support**: Handles all Lua opcodes.

## TODOS

- **Handle larger file size**: When the file size contains too much bytes, the decompiler gets broken:  
   ```lua 
      local bytecode = {string.byte(bytecode, 1, #bytecode)}
   ```

---

## Requirements

- **Lua Version**: Compatible with Lua 5.1 bytecode.
- **Dependencies**:
  - `luac` (to generate Lua bytecode files)

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/spxnso/lbu.git
   cd lbu
   ```
2. Ensure `luac` is installed:
   ```bash
   luac -v
   ```

---

## Usage

### Decompiling & Interpreting a Lua Script

1. Create a Lua script (e.g., `input.lua`):
   ```lua
   -- input.lua
   print("Hello, world!")
   ```

2. Run LBU:
   ```bash
   lua index.lua
   ```

---

## Contributing

Contributions are always welcome! To contribute:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature-name"
   ```
4. Push your changes and create a pull request.

---

## Special Thanks

- **[Lua Community](https://www.lua.org/)**: For creating and maintaining Lua, which powers this tool.
- **[Fiu](https://github.com/rce-incorporated/Fiu)**: For some opcodes interpretation.
- **[GitHub](https://github.com/)**: For providing a platform for open-source collaboration.
- **[Contributors](https://github.com/spxnso/lbu/graphs/contributors)**: For improving this project through valuable contributions.
- **oxidaneofficial**: For teaching me Lua 5.1.5's VM structure.
- **[Rerubi](https://github.com/Rerumu/Rerubi)**: For the inspiration

---

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/spxnso/lbu/blob/main/LICENSE) file for details.
