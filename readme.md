<h1 align="center">
  <br>
  <a href="https://github.com/spxnso/LBU">
    <img src="https://www.lua.org/images/luaa.gif" alt="LBU" width="200">
  </a>
  <br>
  LBU
  <br>
  <h4 align="center">
    A high-performance Bytecode Deserializer and Interpreter designed for
    <a href="https://www.lua.org/manual/5.1/" target="_blank">Lua 5.1.5</a>.
  </h4>
</h1>
<!-- this is a comment -->
<p align="center">
  <a href="https://github.com/spxnso/LBU/stargazers">
    <img src="https://img.shields.io/github/stars/spxnso/LBU?color=%232C2D72" alt="Stars">
  </a>
  <a href="https://github.com/spxnso/LBU/readme.md">
    <img src="https://img.shields.io/badge/version-1.0.1-%232C2D72" alt="Version">
  </a>
  <a href="https://github.com/spxnso/LBU/LICENSE">
    <img src="https://img.shields.io/github/license/spxnso/LBU?color=%232C2D72" alt="License">
  </a>
</p>

<p align="center">
  <h4 align="center">
    Enjoyed this project? Consider
    <a href="https://github.com/spxnso/LBU/stargazers">giving us a star</a> ⭐ on GitHub!
  </h4>
</p>

<h4 align="left">
  <details open="open">
    <summary>Table of Contents</summary>
    <ul>
      <li><a href="#updates">Updates</a>
      <li><a href="#about">About</a>
        <ul>
          <li><a href="#built-with">Built with</a></li>
        </ul>
      </li>
      <li><a href="#getting-started">Getting Started</a>
        <ul>
          <li><a href="#prerequisites">Prerequisites</a></li>
          <li><a href="#usage">How to Use</a></li>
          <li><a href="#options">Available Options</a></li>
        </ul>
      </li>
      <li><a href="#roadmap">Roadmap</a></li>
      <li><a href="#contributing">How to Contribute</a></li>
      <li><a href="#acknowledgements">Acknowledgements</a></li>
      <li><a href="#license">License</a></li>
    </ul>
  </details>
</h4>

---

## Updates
   - Removed useless constant lookup in deserializer.

--- 

## About

<table>
  <tr>
    <td>
      LBU (pronounced "el-bee-you") is a utility for Lua bytecode. Its aim is to make bytecode parsing and
      interpretation as user-friendly as possible. LBU is built for testing, debugging, and interacting with the `luac`
      compiler. The deserialization and interpretation features enable parsing and execution of bytecode with simple,
      intuitive syntax, providing neatly formatted and colorized output.
    </td>
  </tr>
</table>


### Built with:
- [Lua 5.1](https://www.lua.org/manual/5.1/)
- [Love ❤️](https://c.tenor.com/kq7GyBPPIj0AAAAd/tenor.gif)
- [Knowledge 🎓](https://chatgpt.com)

### Current problems:
 - Upvalues are not supported. I may update the interpreter soon!

## Getting Started

### Prerequisites

1. Ensure `lua` is installed:
   ```bash
   lua -v
   ```

2. Ensure `luac` is installed:
   ```bash
   luac -v
   ```
3. Make sure that you're using **Lua 5.1** and not other versions.

### Usage

1. Run the following command to execute LBU:
   ```bash
   lua index.lua
   ```

### Options

LBU has currently **one** available option. Please take a look at [this file](index.lua) for more.

## Roadmap

See the [open issues](https://github.com/spxnso/LBU/issues) for a list of proposed features (and known issues).

- Improved...

## Contributing

We welcome contributions to LBU! Here are a few ways you can help:

1. **Report Bugs** – If you find any issues, please report them on the [Issues page](https://github.com/spxnso/LBU/issues).
2. **Submit a Pull Request** – Fork the repository, create a branch, and submit a pull request with your improvements or fixes.
3. **Improve Documentation** – Help us improve the documentation by submitting suggestions or corrections.

### Steps to Contribute:

1. Fork the repository on GitHub.
2. Clone your fork to your local machine.
3. Create a new branch for your feature or fix.
4. Make your changes.
5. Test your changes locally.
6. Push your changes to your forked repository.
7. Open a pull request with a description of the changes.

## Acknowledgements

I'd like to express my gratitude to the following:

- [Lua](https://www.lua.org/) for providing the powerful and lightweight scripting language that inspired this project.
- [The Lua community](https://www.lua.org/community.html) for their valuable support and contributions.
- [All contributors](https://github.com/spxnso/LBU/graphs/contributors) who have helped make this project better through their code, ideas, and feedback.
- Kein-Hong Man for writing [a-no-frills-introduction-to-lua-5.1-vm-instructions.pdf](https://github.com/Ty-Chen/Reading-List/blob/master/a-no-frills-introduction-to-lua-5.1-vm-instructions.pdf)
- [Jeremiah-Jahnke](https://github.com/Jeremiah-Jahnke) for helping me with `l.opcodes.h`
- Special thanks to those who contributed in ways large and small to ensure the success of this project.

Your help and collaboration are greatly appreciated!

## License

This project is licensed under the **MIT license**.
See [LICENSE](LICENSE) for more information.
