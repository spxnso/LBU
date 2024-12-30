# Lua Bytecode Utility's CheatSheet

Yes, we provide an interpreter and a decompiler. But we also provide a "cheatsheet" on how Lua 5.1.5's bytecode works! In this file, you're going to learn about the bytecode format and how to manipulate and understand the underlying structure of Lua bytecode files.

---

## 🔍 Understanding Lua 5.1.5 Bytecode

Lua bytecode is a low-level representation of Lua source code that is produced when a Lua script is compiled. The bytecode is a sequence of instructions, each corresponding to an operation that Lua can execute. Here’s a breakdown of how the bytecode is structured:

### 1. **Bytecode Format Overview**
Lua bytecode is divided into two parts:

| Part Name          | Description                                                                 | Size       |
|--------------------|-----------------------------------------------------------------------------|------------|
| **Header**         | Contains metadata about the bytecode, such as version and entry point.      | 12 bytes   |
| **Chunk**          | The other part that contains instructions, constants, protos.               | Dynamic Size |

#### 1. The Header
The Header section holds metadata about the Lua bytecode, including the Lua version used for compilation, the entry point, and other crucial information that enables the Lua interpreter to correctly process the bytecode. The header has a fixed size of 12 bytes and is divided into 10 parts. Most of the values in the header are static and remain unchanged on **a x86 platform**.

| Part Name          | Description                                                                 | Size       | Value       |
|--------------------|-----------------------------------------------------------------------------|------------|-------------|
| **Signature**      | A unique identifier that marks the file as Lua bytecode.                    | 4 bytes    | 0x1b4c7561  |
| **Version**        | Lua version number                                                          | 1 byte     | 0x81        |
| **Format Version** | Lua format version (0=official version)                                     | 1 byte     | 0           |
| **Endianness Flag**| Indicates the byte order used (little-endian or big-endian) in the bytecode.| 1 byte     | 0 (little-endian) |
| **Size of Ints**   | Specifies the size (in bytes) of Lua integers.                              | 1 byte     | 4           |
| **Size of Size_T** | Specifies the size (in bytes) of size_t.                                    | 1 byte     | 4           |
| **Size of Instruction** | Specifies the size (in bytes) of Instruction.                          | 1 byte     | 4           |
| **Size of Lua_Number**| Specifies the size (in bytes) of Lua_Number.                             | 1 byte     | 8           |
| **Integral Flag**| The number of prototype functions included in the bytecode.                | 1 byte     | 1           |
| **Entry Point**    | A reference to the function that will be executed first in the bytecode.    | Varies     | Address of the entry function |

### 2. **Common Lua Instructions**
Each Lua instruction consists of a set of opcodes that correspond to operations in Lua's virtual machine. Here are some of the most common opcodes:

- **LOADK**: Load a constant value (number or string) into a register.
- **MOVE**: Move data between registers.
- **ADD**: Perform addition on two values.
- **SUB**: Perform subtraction.
- **MUL**: Perform multiplication.
- **DIV**: Perform division.
- **JMP**: Jump to a specific instruction (used for loops and conditional branching).
- **CALL**: Call a function with a specific number of arguments and results.

Each opcode has a specific structure in the bytecode. For example, the `LOADK` instruction will typically have the following format:
```
LOADK A Bx
```
Where `A` is the register to load the constant into, and `Bx` is the index of the constant in the constant pool.

### 3. **Register and Stack Operations**
Lua's virtual machine uses registers to hold intermediate values during execution. The number of registers depends on the function, and the bytecode can access them using the following operations:

- **MOVE**: Copies the value from one register to another.
- **LOADK**: Loads a constant into a register.
- **GETGLOBAL**: Loads a global variable into a register.
- **SETGLOBAL**: Sets the value of a global variable from a register.

The stack is used for function calls and argument passing, while registers are used for temporary data manipulation.

### 4. **Understanding the Constant Pool**
The constant pool contains all the constants used in the bytecode. Constants can be numbers, strings, or function references. The `LOADK` instruction refers to an index in the constant pool.

For example:
```
LOADK 0 1
```
This instruction loads the constant at index `1` from the constant pool into register `0`.

---

## 🛠️ Working with Lua Bytecode

When dealing with Lua bytecode, you often need to perform specific tasks like disassembling or decompiling. Below is a list of some common operations:

### 1. **Disassembling Bytecode**
To understand the bytecode, you might need to disassemble it, which involves converting the raw bytecode into human-readable instructions. This can be done using the provided decompiler tool.

### 2. **Decompiling Bytecode**
To decompile a Lua bytecode file, use the following command:
```bash
lua decompiler.lua <path_to_bytecode_file>
```
This will output a readable version of the Lua script that was compiled into bytecode.

---

## ⚙️ Lua Bytecode Utilities

The `Lua Bytecode Utility` package includes tools to help you interact with Lua bytecode. Below is a list of the tools provided:

- **Decompiler**: Converts compiled Lua bytecode back into source code.
- **Interpreter**: Executes Lua bytecode directly, allowing you to test bytecode scripts without needing to recompile them.

You can use these tools to inspect, execute, and modify Lua bytecode.

---

## 📝 Additional Resources

- **Official Lua Documentation**: [https://www.lua.org/manual/5.1/](https://www.lua.org/manual/5.1/)
- **Lua VM Reference Manual**: [https://www.lua.org/docs/manual/5.1/lua-VM.html](https://www.lua.org/docs/manual/5.1/lua-VM.html)

These resources will help you dive deeper into how Lua bytecode works and how to use it effectively.

---

## 🤝 Contributing

If you'd like to contribute to this project, here’s how you can help:

1. **Fork the repository** and create a feature branch:
   ```bash
   git checkout -b feature-name
   ```
2. **Commit changes**:
   ```bash
   git commit -m "Add feature-name"
   ```
3. **Push your branch** and submit a pull request.

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

---

## 👏 Special Thanks

A special thanks to the Lua community and the contributors who helped make this project a reality. Their work and dedication to Lua’s development and documentation were instrumental in creating this utility. 

Thank you to everyone who has contributed to the open-source world.
