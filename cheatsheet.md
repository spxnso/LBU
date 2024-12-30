# Lua Bytecode Utility's CheatSheet

Yes, we provide an interpreter and a decompiler. But we also provide a "cheatsheet" on how Lua 5.1.5's bytecode works! In this file, you're going to learn about the bytecode format and how to manipulate and understand the underlying structure of Lua bytecode files.

---

## 🔍 Understanding Lua 5.1.5 Bytecode

Are you new to Lua 5.1.5's Bytecode? Let me teach you!

Lua bytecode is a **low-level** representation of Lua source code that is produced when a Lua script is **compiled**. The bytecode is a sequence of instructions, each corresponding to an operation that Lua can execute. Here’s a breakdown of how the bytecode is structured:

### 1. **Bytecode Format Overview**
Lua bytecode is divided into two parts:

| Part Name          | Description                                                                 | Size       |
|--------------------|-----------------------------------------------------------------------------|------------|
| **Header**         | Contains metadata about the bytecode, such as version and entry point.      | 12 bytes   |
| **Chunk**          | The other part that contains instructions, constants, protos.               | Dynamic Size |

#### 1. The Header
The Header section holds **metadata** about the Lua bytecode, including the Lua version used for compilation, the endianness flag, and other crucial information that enables the Lua interpreter to correctly process the bytecode. The header is **divided into 10 parts**. Most of the values in the header are **static** and remain **unchanged** on **a x86 platform**.

| Part Name          | Description                                                                 | Size       | Value       |
|--------------------|-----------------------------------------------------------------------------|------------|-------------|
| **Signature**      | A unique identifier that marks the file as Lua bytecode.                    | 4 bytes    | 0x1b4c7561 or ESC Lua  |
| **Version**        | Lua version number                                                          | 1 byte     | 0x81 (= 51)        |
| **Format Version** | Lua format version (0=official version)                                     | 1 byte     | 0           |
| **Endianness Flag**| Indicates the byte order used (little-endian or big-endian) in the bytecode.| 1 byte     | 0 (little-endian) |
| **Size of Ints**   | Specifies the size (in bytes) of Lua integers.                              | 1 byte     | 4           |
| **Size of Size_T** | Specifies the size (in bytes) of size_t.                                    | 1 byte     | 4           |
| **Size of Instruction** | Specifies the size (in bytes) of Instruction.                          | 1 byte     | 4           |
| **Size of Lua_Number**| Specifies the size (in bytes) of Lua_Number.                             | 1 byte     | 8           |
| **Integral Flag**| The number of prototype functions included in the bytecode.                   | 1 byte     | 1           |

#### 1. The Chunk

The Chunk is the most **intriguing part** so far! It contains all the **essential data** required to execute Lua 5.1.5 bytecode. Its values are dynamic and depend on the code being used.
In this section, I will guide you on how to parse the information stored within the chunk.

The chunk is organized as follows:
   - **Metadata** → Dynamic size
   - **Instructions** → Dynamic size
   - **Constants** → Dynamic size
   - **Protos** → Dynamic size
   - **Debug Informations** → Dynamic size

Well! Quite a few new terms for you, right? Don't worry, I'll break them down step by step. Here's a brief overview of what each component means:
   - The **metadata** is "kinda" similar to the header except that it contains **data about the file**, and not about the actual bytecode  (e.g., the file name).
   - The **instructions** are like the **step-by-step commands** that Lua follows to run your code. Each instruction tells Lua **what action to perform**, like adding numbers, showing a message, or calling a function.
   - The **constants** are the values in your Lua code. These can be things like **numbers**, **strings** (text), or **boolean** values (true/false).
   - The **protos** are your **functions**. They have a **similar structure to the chunk** itself, meaning they contain **metadata**, **instructions**, **constants**, **protos** (for nested functions), and **debug informations**. In other words, each function is treated like a **small chunk**, with its own set of data and bytecode instructions.
   - The **debug informations** are some optional informations that I won't present in this cheatsheet.

Now that you understand the chunk's structure, I am going tell you how to parse each component!

##### 1. The Metadata
   | Part Name          | Description                                                                 | Size       | Value       |
   |--------------------|-----------------------------------------------------------------------------|------------|-------------|
   | **Name**           | The input file's name.                                                      | String     | @{filename} |
   | **First Line**     | The script's first line                                                     | Integer    | {Dynamic}   |
   | **Last Line**      | The script's last line                                                      | Integer    | {Dynamic}   |
   | **Upvalues Number**| The number of upvalues in the code.                                         | 1 byte     | {Dynamic}   |
   | **Arguments Number**| The number of arguments in the code.                                       | 1 byte     | {Dynamic}   |
   | **VAR_ARG FLAG**   | The VAR_ARG FLAG ( I might explain it later ).                              | 1 byte     | 1, 2 or 4   |
   | **Stack Size**     | The number of used registers, the maximum stack size                        | 1 byte     | {Dynamic}   |

##### 2. The Instructions List
   Before we begin, let me explain the content of an instruction in detail. As mentioned earlier, an instruction is like a **command** that Lua follows to run your code. 