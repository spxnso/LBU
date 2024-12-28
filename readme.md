
<div align="center">

# Lua Bytecode Utility

A high-performance Lua Bytecode Decompiler & Interpreter that helps you read and understand and execute bytecode. Designed for Lua 5.1.5, this tool makes it easy for developers to analyze compiled Lua scripts.

---

## ⚡️ Features

- **Fast Performance**: Optimized for quick decompilation & interpretation of complex bytecode files.
- **Opcode Support**: Supports a wide range of Lua opcodes, including `ABC`, `ABx`, and `AsBx` types.

---

## 📋 Requirements

- **Lua Version**: Compatible with Lua 5.1 bytecode.
- **Dependencies**:
  - `luac` (for generating bytecode files)
  - Lua modules:
    - `json` (For structured data output)

---

## 📥 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/spxnso/lbu.git
   cd lbu
   ```

2. Install dependencies:
   ```bash
   luarocks install json
   ```

3. Verify `luac` is installed:
   ```bash
   luac -v
   ```

---

## 🛠️ Usage

### Decompiling a Lua Script

1. Create a Lua script to decompile:
   ```lua
   -- input.lua
   print("Hello, world!")
   ```

2. Run the index file:
   ```bash
   lua index.lua
   ```

---

## 🤝 Contributing

Contributions are welcome! Follow these steps to contribute:

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit changes:
   ```bash
   git commit -m "Add feature-name"
   ```
4. Push and submit a pull request.

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

</div>
