
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
- **[GitHub](https://github.com/)**: For providing a platform for open-source collaboration.
- **[Contributors](https://github.com/spxnso/lbu/graphs/contributors)**: For improving this project through valuable contributions.
- **oxidaneofficial**: For teaching me Lua 5.1.5's VM structure.
- **[Rerubi](https://github.com/Rerumu/Rerubi)**: For the inspiration

---

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/spxnso/lbu/blob/main/LICENSE) file for details.

-- The first CALL will be tostring

            local paramsCount = 0
            if Instruction["REGISTERS"]["B"]["VALUE"] >= 2 then
                -- B - 1 arguments
                
                paramsCount = Instruction["REGISTERS"]["B"]["VALUE"] - 1
                print(paramsCount==1)
            elseif Instruction["REGISTERS"]["B"]["VALUE"] == 0 then
                for index = Instruction["REGISTERS"]["A"] + 1, stackTop do
                    paramsCount = paramsCount + 1
                end
            end

            stackTop = Instruction["REGISTERS"]["A"] - 1
            local edx = 0
            local args = {}

            if paramsCount ~= 0 then
                for index = Instruction["REGISTERS"]["A"] + 1, paramsCount do
                    edx = edx + 1;
                    args[edx] = mem[index];
                end;
            end
            
            print(paramsCount, mem[Instruction["REGISTERS"]["A"]]==tostring)
            local limit, results = paramsCount, mem[Instruction["REGISTERS"]["A"]](unpack(args, 1))
            if Instruction["REGISTERS"]["C"]["VALUE"] >= 2 then
                -- C - 1 saved results
                
            elseif Instruction["REGISTERS"]["B"]["VALUE"] == 0 then
                for index = Instruction["REGISTERS"]["A"] + 1, stackTop do
                    paramsCount = paramsCount + 1
                end
            end