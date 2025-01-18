local Deserializer = {};
local bit = require("bit32");
Deserializer.__index = Deserializer;
local floor = math.floor;
local char = string.char;
local cprint;
local colors = {
    reset = "\027[0m",
    red = "\027[31m",
    green = "\027[32m",
    yellow = "\027[33m",
    blue = "\027[34m",
    magenta = "\027[35m",
    cyan = "\027[36m",
    white = "\027[37m",
    bold = "\027[1m"
};
local function cPrint(color, text)
    if cprint == true then
        print(color .. text .. colors.reset);
    end
end
function ChunkPrint(Chunk)
    cPrint(colors.yellow, "\n================ " .. "Instructions" .. " ================");
    cPrint(colors.magenta, "Mnemonic   Opcode   Type   Opmode   A   B   C");
    for k, Instruction in pairs(Chunk.Instructions) do
        local mode = Instruction.Metadata.Regs.B and Instruction.Metadata.Regs.B.Mode or
            (Instruction.Metadata.Regs.Bx and Instruction.Metadata.Regs.Bx.Mode or
            (Instruction.Metadata.Regs.sBx and Instruction.Metadata.Regs.sBx.Mode or "N/A"));
        local b = Instruction.B or Instruction.Bx or Instruction.sBx or "N/A";
        cPrint(colors.green,
            string.format("%-12s %-7s %-6s %-7s %-3d %-3s %-3s", Instruction.Metadata.Mnemonic,
                Instruction.Metadata.Opcode, Instruction.Metadata.Type, mode, Instruction.A, b, Instruction.C));
    end
    cPrint(colors.yellow, "\n================ " .. "Constants" .. " ================");
    cPrint(colors.magenta, string.format("%-8s %-8s %-8s", "Type", "Pos", "Value"));
    for k, Constant in pairs(Chunk.Constants) do
        local constant_t = Constant.Type;
        constant_t = tostring(constant_t or "N/A")
        k = tostring(k or "N/A")
        local value = Constant and Constant.Value or "N/A"
        
        cPrint(colors.green, string.format("%-8s %-8s %-8s", constant_t, k, tostring(value)))
    
    end
end
function Deserializer.new(bytecode, p)
    local btable = {};
    for i = 1, #bytecode do
        btable[i] = string.byte(bytecode, i, i);
    end
    bytecode = btable;
    local self = setmetatable({}, Deserializer);
    self.bytecode = bytecode;
    self.index = 0;
    cprint = p or false;
    return self;
end
function Deserializer:getByte()
    local bytecode = self.bytecode;
    local index = self.index;
    local b = bytecode[index + 1];
    index = index + 1;
    self.index = index;
    return b;
end
function Deserializer:getInt32()
    local bytecode = self.bytecode;
    local index = self.index;
    local b1, b2, b3, b4 = bytecode[index + 1], bytecode[index + 2], bytecode[index + 3], bytecode[index + 4];
    index = index + 4;
    self.index = index;
    return bit.bor(bit:lshift(b1, 0), bit:lshift(b2, 8), bit:lshift(b3, 16), bit:lshift(b4, 24));
end
function Deserializer:getInt()
    local i = 0;
    for j = 4, 1, -1 do
        i = i * 256 + self.bytecode[(self.index + j)];
    end
    self.index = self.index + 4;
    return i;
end
function Deserializer:getDouble()
    local lowInt = self:getInt();
    local highInt = self:getInt();
    local sign = bit:band(highInt, 2147483648) ~= 0 and (-1) or 1;
    local exponent = bit:band(bit:rshift(highInt, 20), 2047);
    local fraction = bit:band(highInt, 1048575) * 4294967296 + lowInt;
    if exponent == 0 then
        fraction = fraction / 2 ^ 52;
        return sign * fraction;
    end
    local double = sign * 2 ^ (exponent - 1023) * (1 + fraction / 2 ^ 52);
    return double;
end
function Deserializer:getString(size)
    size = self:getInt();
    if size == 0 then
        return "";
    end
    local s = "";
    for i = self.index + 1, self.index + size do
        s = s .. char(self.bytecode[i]);
    end
    self.index = self.index + size;
    return s:sub(1, -2);
end
function getOpcodeInfo(opcode)
    local Opmode = {{
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgK",
        c = "OpArgN"
    }, {
        b = "OpArgU",
        c = "OpArgU"
    }, {
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgU",
        c = "OpArgN"
    }, {
        b = "OpArgK",
        c = "OpArgN"
    }, {
        b = "OpArgR",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgN"
    }, {
        b = "OpArgU",
        c = "OpArgN"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgU",
        c = "OpArgU"
    }, {
        b = "OpArgR",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgR",
        c = "OpArgR"
    }, {
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgK",
        c = "OpArgK"
    }, {
        b = "OpArgR",
        c = "OpArgU"
    }, {
        b = "OpArgR",
        c = "OpArgU"
    }, {
        b = "OpArgU",
        c = "OpArgU"
    }, {
        b = "OpArgU",
        c = "OpArgU"
    }, {
        b = "OpArgU",
        c = "OpArgN"
    }, {
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgR",
        c = "OpArgN"
    }, {
        b = "OpArgN",
        c = "OpArgU"
    }, {
        b = "OpArgU",
        c = "OpArgU"
    }, {
        b = "OpArgN",
        c = "OpArgN"
    }, {
        b = "OpArgU",
        c = "OpArgN"
    }, {
        b = "OpArgU",
        c = "OpArgN"
    }};
    local info = {
        [0] = {
            type = "ABC",
            mnemonic = "MOVE",
            b = "OpArgR",
            c = "OpArgN"
        },
        {
            type = "ABx",
            mnemonic = "LOADK",
            b = "OpArgK",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "LOADBOOL",
            b = "OpArgU",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "LOADNIL",
            b = "OpArgR",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "GETUPVAL",
            b = "OpArgU",
            c = "OpArgN"
        },
        {
            type = "ABx",
            mnemonic = "GETGLOBAL",
            b = "OpArgK",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "GETTABLE",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABx",
            mnemonic = "SETGLOBAL",
            b = "OpArgK",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "SETUPVAL",
            b = "OpArgU",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "SETTABLE",
            b = "OpArgK",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "NEWTABLE",
            b = "OpArgU",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "SELF",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "ADD",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "SUB",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "MUL",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "DIV",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "MOD",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "POW",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "UNM",
            b = "OpArgR",
            c = "OpArgR"
        },
        {
            type = "ABC",
            mnemonic = "NOT",
            b = "OpArgR",
            c = "OpArgR"
        },
        {
            type = "ABC",
            mnemonic = "LEN",
            b = "OpArgR",
            c = "OpArgR"
        },
        {
            type = "ABC",
            mnemonic = "CONCAT",
            b = "OpArgR",
            c = "OpArgR"
        },
        {
            type = "AsBx",
            mnemonic = "JMP",
            b = "OpArgN",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "EQ",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "LT",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "LE",
            b = "OpArgR",
            c = "OpArgK"
        },
        {
            type = "ABC",
            mnemonic = "TEST",
            b = "OpArgN",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "TESTSET",
            b = "OpArgR",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "CALL",
            b = "OpArgU",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "TAILCALL",
            b = "OpArgU",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "RETURN",
            b = "OpArgU",
            c = "OpArgN"
        },
        {
            type = "AsBx",
            mnemonic = "FORLOOP",
            b = "OpArgR",
            c = "OpArgN"
        },
        {
            type = "AsBx",
            mnemonic = "FORPREP",
            b = "OpArgR",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "TFORLOOP",
            b = "OpArgN",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "SETLIST",
            b = "OpArgU",
            c = "OpArgU"
        },
        {
            type = "ABC",
            mnemonic = "CLOSE",
            b = "OpArgN",
            c = "OpArgN"
        },
        {
            type = "ABx",
            mnemonic = "CLOSURE",
            b = "OpArgU",
            c = "OpArgN"
        },
        {
            type = "ABC",
            mnemonic = "VARARG",
            b = "OpArgU",
            c = "OpArgU"
        }
    };
    info[opcode].b = Opmode[opcode + 1].b;
    info[opcode].c = Opmode[opcode + 1].c;
    return info[opcode];
end
function Deserializer:Decompile()
    local header = self:DecodeHeader();
    local Chunk = self:DecodeChunk();
    cPrint(colors.cyan,
        "\n======================================== " .. "Chunk" .. " ========================================");
    cPrint(colors.yellow, "\n================ " .. "Metadata" .. " ================");
    cPrint(colors.magenta, "Name: " .. colors.green .. Chunk.Metadata.Name .. colors.reset);
    cPrint(colors.magenta, "First Line: " .. colors.green .. Chunk.Metadata.FirstLine .. colors.reset);
    cPrint(colors.magenta, "Last Line: " .. colors.green .. Chunk.Metadata.LastLine .. colors.reset);
    cPrint(colors.magenta, "Upvalues: " .. colors.green .. Chunk.Metadata.Upvalues .. colors.reset);
    cPrint(colors.magenta, "Arguments: " .. colors.green .. Chunk.Metadata.Arguments .. colors.reset);
    cPrint(colors.magenta, "VARG: " .. colors.green .. Chunk.Metadata.VarArg .. colors.reset);
    cPrint(colors.magenta, "Stack: " .. colors.green .. Chunk.Metadata.StackSize .. colors.reset);
    ChunkPrint(Chunk);
    if #Chunk.Protos ~= 0 then
        cPrint(colors.cyan, "\n================================ " .. "Prototypes" .. " ================================");
    end
    for k, v in pairs(Chunk.Protos) do
        cPrint(colors.red, "\n==================== " .. "Proto: " .. k .. " ====================");
        ChunkPrint(v);
    end
    return {header, Chunk};
end
function Deserializer:DecodeHeader()
    local header = {};
    self.index = 4;
    header.VM_VERSION = self:getByte();
    header.FORMAT = self:getByte();
    header.ENDIANNESS = self:getByte();
    header.INT_SIZE = self:getByte();
    header.SIZE_T = self:getByte();
    header.INSTRUCTION_SIZE = self:getByte();
    header.L_NUMBER_SIZE = self:getByte();
    header.INTEGRAL_FLAG = self:getByte();
    cPrint(colors.cyan,
        "\n======================================== " .. "Header" .. " ========================================");
    cPrint(colors.magenta,
        "Version: " .. colors.green .. (header.VM_VERSION == 81 and "Lua 5.1" or "Not Lua") .. colors.reset);
    cPrint(colors.magenta, "Format: " .. colors.green .. header.FORMAT .. colors.reset);
    cPrint(colors.magenta, "Endianness: " .. colors.green ..
        (header.ENDIANNESS == 1 and "Little Endian" or "Big Endian") .. colors.reset);
    cPrint(colors.magenta, "IntSize: " .. colors.green .. header.INT_SIZE .. colors.reset);
    cPrint(colors.magenta, "SizeT: " .. colors.green .. header.SIZE_T .. colors.reset);
    cPrint(colors.magenta, "InstructionSize: " .. colors.green .. header.INSTRUCTION_SIZE .. colors.reset);
    cPrint(colors.magenta, "LNumberSize: " .. colors.green .. header.L_NUMBER_SIZE .. colors.reset);
    cPrint(colors.magenta, "IntegralFlag: " .. colors.green .. header.INTEGRAL_FLAG .. colors.reset);
    return header;
end
function Deserializer:DecodeChunk()
    local Chunk = {};
    Chunk.Metadata = {};
    Chunk.Metadata.Name = self:getString();
    Chunk.Metadata.FirstLine = self:getInt();
    Chunk.Metadata.LastLine = self:getInt();
    Chunk.Metadata.Upvalues = self:getByte();
    Chunk.Metadata.Arguments = self:getByte();
    Chunk.Metadata.VarArg = self:getByte();
    Chunk.Metadata.StackSize = self:getByte();
    Chunk.Instructions = {};
    Chunk.Constants = {};
    Chunk.Protos = {};
    Chunk.Debug = {};
    for i = 1, self:getInt() do
        local Instruction = {};
        local instr = self:getInt();
        local opcode = instr % 64;
        local opinfo = getOpcodeInfo(opcode);
        Instruction.Metadata = {
            Opcode = opcode,
            Mnemonic = opinfo.mnemonic,
            Type = opinfo.type,
            Regs = {}
        };
        local a = floor(instr / 2 ^ 6) % 256;
        Instruction.Metadata.Regs.A = a;
        Instruction.OP = opcode;
        Instruction.A = a;
        if opinfo.type == "ABC" then
            Instruction.B = floor(instr / (2 ^ 23)) % 512;
            Instruction.C = floor(instr / (2 ^ 14)) % 512;
            Instruction.Metadata.Regs.B = {
                Value = Instruction.B,
                Mode = opinfo.b
            };
            Instruction.Metadata.Regs.C = {
                Value = Instruction.C,
                Mode = opinfo.c
            };
        elseif opinfo.type == "ABx" then
            Instruction.Bx = floor(instr / 2 ^ 14);
            Instruction.C = -1;
            Instruction.Metadata.Regs.Bx = {
                Value = Instruction.Bx,
                Mode = opinfo.b
            };
        else
            Instruction.sBx = floor(instr / 2 ^ 14) - 131071;
            Instruction.C = -1;
            Instruction.Metadata.Regs.sBx = {
                Value = Instruction.sBx,
                Mode = opinfo.b
            };
        end
        table.insert(Chunk.Instructions, Instruction);
    end
    for i = 1, self:getInt() do
        local constant_t = self:getByte();
        local Types = {
            [1] = "Boolean",
            [3] = "Number",
            [4] = "String"
        };
        local data;
        if constant_t == 1 then
            data = self:getByte() ~= 0;
        elseif constant_t == 3 then
            data = self:getDouble();
        elseif constant_t == 4 then
            data = self:getString();
        end
        Chunk.Constants[i - 1] = {
            Value = data,
            Type = Types[constant_t]
        };
    end
    for i = 1, self:getInt() do
        Chunk.Protos[i - 1] = self:DecodeChunk();
    end
    for i = 1, self:getInt() do
        self:getInt32();
    end
    for i = 1, self:getInt() do
        self:getString();
        self:getInt32();
        self:getInt32();
    end
    for i = 1, self:getInt() do -- Upvalues
        local s = self:getString(); -- Upvalue name
        print(s)
    end
    return Chunk;
end
return Deserializer;
