
# 🔍 Lua Bytecode Decompiler

A high-performance Lua Bytecode Decompiler that transforms compiled Lua bytecode back into human-readable Lua source code. This tool is designed for educational purposes, helping developers understand and analyze compiled Lua scripts.

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
   luarocks install fs
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

3. Run the decompiler:
   ```bash
   lua index.lua
   ```


---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

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

---

## ⚠️ Disclaimer

This tool is for educational and research purposes only. The authors are not responsible for any misuse of the software.