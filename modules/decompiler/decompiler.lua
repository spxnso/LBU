local Decompiler = {}
local bit = require("modules.utils.bit32")
Decompiler.__index = Decompiler

local floor = math.floor
local char = string.char
local cprint;

local colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m",
    bold = "\27[1m"
}

local function cPrint(color, text)
    if cprint == true then print(color .. text .. colors.reset) end
end

function chunkPrint(chunk)
    cPrint(colors["yellow"],
           "\n================ " .. "Instructions" .. " ================")
    cPrint(colors["magenta"], "Mnemonic   Opcode   Type   Opmode   A   B   C")

    for k, Instruction in pairs(chunk["INSTRUCTIONS"]) do
        local mode = Instruction["REGISTERS"].B and
                         Instruction["REGISTERS"].B.MODE or
                         (Instruction["REGISTERS"].Bx and
                             Instruction["REGISTERS"].Bx.MODE or
                             (Instruction["REGISTERS"].sBx and
                                 Instruction["REGISTERS"].sBx.MODE or "N/A"))
        local b = Instruction["REGISTERS"].B and
                      Instruction["REGISTERS"].B.VALUE or
                      (Instruction["REGISTERS"].Bx and
                          Instruction["REGISTERS"].Bx.VALUE or
                          (Instruction["REGISTERS"].sBx and
                              Instruction["REGISTERS"].sBx.VALUE or "N/A"))
        cPrint(colors["green"],
               string.format("%-12s %-7s %-6s %-7s %-3d %-3s %-3s",
                             Instruction["MNEMONIC"], Instruction["OPCODE"],
                             Instruction["TYPE"], mode,
                             Instruction["REGISTERS"].A, b,
                             Instruction["REGISTERS"].C and
                                 Instruction["REGISTERS"].C.VALUE or "-1"))

    end
    cPrint(colors["yellow"],
           "\n================ " .. "Constants" .. " ================")
    cPrint(colors["magenta"],
           string.format("%-8s %-8s %-8s", "Type", "Pos", "Value"))
    for k, Constant in pairs(chunk["CONSTANTS"]) do
        local constant_t = Constant["TYPE"]
        local data = Constant["DATA"]
        cPrint(colors["green"], string.format("%-8s %-8s %-8s",
                                              constant_t == 1 and "Boolean" or
                                                  constant_t == 3 and "Double" or
                                                  constant_t == 4 and "String" or
                                                  "Unknown", k, data or "N/A"))
    end
end

function Decompiler.new(bytecode, p)
    bytecode = {string.byte(bytecode, 1, #bytecode)}
    local self = setmetatable({}, Decompiler)
    self.bytecode = bytecode
    self.index = 0
    cprint = p or false
    return self
end

function Decompiler:getByte()
    local bytecode = self.bytecode
    local index = self.index
    local b = bytecode[index + 1]
    index = index + 1
    self.index = index
    return b
end
function Decompiler:getInt32()
    local bytecode = self.bytecode
    local index = self.index
    local b1, b2, b3, b4 = bytecode[index + 1], bytecode[index + 2],
                           bytecode[index + 3], bytecode[index + 4]
    index = index + 4
    self.index = index
    return bit.bor(bit:lshift(b1, 0), bit:lshift(b2, 8), bit:lshift(b3, 16),
                   bit:lshift(b4, 24))
end

function Decompiler:getInt()
    local i = 0
    for j = 4, 1, -1 do i = i * 256 + self.bytecode[self.index + j] end
    self.index = self.index + 4
    return i
end

function Decompiler:getDouble()
    local lowInt = self:getInt()
    local highInt = self:getInt()

    local sign = (bit:band(highInt, 0x80000000) ~= 0) and -1 or 1
    local exponent = bit:band(bit:rshift(highInt, 20), 0x7FF)
    local fraction = (bit:band(highInt, 0xFFFFF) * 4294967296.0 + lowInt) /
                         (2 ^ 52)
    local double = sign * (2 ^ (exponent - 1023)) * (1 + fraction)

    return double
end
function Decompiler:getString(size)
    size = self:getInt()
    if size == 0 then return "" end

    local s = ""
    for i = self.index + 1, self.index + size do
        s = s .. char(self.bytecode[i])
    end

    self.index = self.index + size
    return s:sub(1, -2)
end

function getOpcodeInfo(opcode)
    local info = {
        [0] = {type = "ABC", mnemonic = "MOVE", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABx", mnemonic = "LOADK", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "LOADBOOL", b = 'OpArgU', c = 'OpArgU'},
        {type = "ABC", mnemonic = "LOADNIL", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "GETUPVAL", b = 'OpArgU', c = 'OpArgN'},
        {type = "ABx", mnemonic = "GETGLOBAL", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "GETTABLE", b = 'OpArgR', c = 'OpArgK'},
        {type = "ABx", mnemonic = "SETGLOBAL", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "SETUPVAL", b = 'OpArgR', c = 'OpArgK'},
        {type = "ABC", mnemonic = "SETTABLE", b = 'OpArgK', c = 'OpArgK'},
        {type = "ABC", mnemonic = "NEWTABLE", b = 'OpArgU', c = 'OpArgU'},
        {type = "ABC", mnemonic = "SELF", b = 'OpArgK', c = 'OpArgK'},
        {type = "ABC", mnemonic = "ADD", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "SUB", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "MUL", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "DIV", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "MOD", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "POW", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "UNM", b = 'OpArgR', c = 'OpArgR'},
        {type = "ABC", mnemonic = "NOT", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "LEN", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "CONCAT", b = 'OpArgU', c = 'OpArgN'},
        {type = "AsBx", mnemonic = "JMP", b = 'OpArgR', c = 'OpArgU'},
        {type = "ABC", mnemonic = "EQ", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "LT", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "LE", b = 'OpArgR', c = 'OpArgR'},
        {type = "ABC", mnemonic = "TEST", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "TESTSET", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "CALL", b = 'OpArgK', c = 'OpArgK'},
        {type = "ABC", mnemonic = "TAILCALL", b = 'OpArgK', c = 'OpArgK'},
        {type = "ABC", mnemonic = "RETURN", b = 'OpArgR', c = 'OpArgK'},
        {type = "AsBx", mnemonic = "FORLOOP", b = 'OpArgR', c = 'OpArgN'},
        {type = "AsBx", mnemonic = "FORPREP", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "TFORLOOP", b = 'OpArgU', c = 'OpArgN'},
        {type = "ABC", mnemonic = "SETLIST", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "CLOSE", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABx", mnemonic = "CLOSURE", b = 'OpArgU', c = 'OpArgN'},
        {type = "ABC", mnemonic = "VARARG", b = 'OpArgR', c = 'OpArgK'}
    }

    return info[opcode]
end

function Decompiler:Decompile()
    local header = self:DecodeHeader()

    local chunk = self:DecodeChunk()

    cPrint(colors["cyan"],
           "\n======================================== " .. "Chunk" ..
               " ========================================")

    cPrint(colors["yellow"],
           "\n================ " .. "Metadata" .. " ================")
    cPrint(colors["magenta"],
           "Name: " .. colors["green"] .. chunk["NAME"] .. colors["reset"])
    cPrint(colors["magenta"], "First Line: " .. colors["green"] ..
               chunk["FIRST_LINE"] .. colors["reset"])
    cPrint(colors["magenta"], "Last Line: " .. colors["green"] ..
               chunk["LAST_LINE"] .. colors["reset"])
    cPrint(colors["magenta"], "Upvalues: " .. colors["green"] ..
               chunk["UPVALUES"] .. colors["reset"])
    cPrint(colors["magenta"], "Arguments: " .. colors["green"] ..
               chunk["ARGUMENTS"] .. colors["reset"])
    cPrint(colors["magenta"],
           "VARG: " .. colors["green"] .. chunk["VARG"] .. colors["reset"])
    cPrint(colors["magenta"],
           "Stack: " .. colors["green"] .. chunk["STACK"] .. colors["reset"])
    chunkPrint(chunk)
    if (#chunk["PROTOS"] ~= 0) then
        cPrint(colors["cyan"],
               "\n================================ " .. "Prototypes" ..
                   " ================================")
    end
    for k, v in pairs(chunk["PROTOS"]) do
        cPrint(colors["red"], "\n==================== " .. "Proto: " .. k ..
                   " ====================")
        chunkPrint(v)
    end
    return {header, chunk}
end

function Decompiler:DecodeHeader()
    local header = {}
    self.index = 4

    header["VM_VERSION"] = self:getByte()
    header["FORMAT"] = self:getByte()
    header["ENDIANNESS"] = self:getByte()
    header["INT_SIZE"] = self:getByte()
    header["SIZE_T"] = self:getByte()
    header["INSTRUCTION_SIZE"] = self:getByte()
    header["L_NUMBER_SIZE"] = self:getByte()
    header["INTEGRAL_FLAG"] = self:getByte()

    cPrint(colors["cyan"],
           "\n======================================== " .. "Header" ..
               " ========================================")
    cPrint(colors["magenta"], "Version: " .. colors["green"] ..
               (header["VM_VERSION"] == 0x51 and "Lua 5.1" or "Not Lua") ..
               colors["reset"])
    cPrint(colors["magenta"],
           "Format: " .. colors["green"] .. header["FORMAT"] .. colors["reset"])
    cPrint(colors["magenta"], "Endianness: " .. colors["green"] ..
               (header["ENDIANNESS"] == 1 and "Little Endian" or "Big Endian") ..
               colors["reset"])
    cPrint(colors["magenta"], "IntSize: " .. colors["green"] ..
               header["INT_SIZE"] .. colors["reset"])
    cPrint(colors["magenta"],
           "SizeT: " .. colors["green"] .. header["SIZE_T"] .. colors["reset"])
    cPrint(colors["magenta"],
           "InstructionSize: " .. colors["green"] .. header["INSTRUCTION_SIZE"] ..
               colors["reset"])
    cPrint(colors["magenta"],
           "LNumberSize: " .. colors["green"] .. header["L_NUMBER_SIZE"] ..
               colors["reset"])
    cPrint(colors["magenta"],
           "IntegralFlag: " .. colors["green"] .. header["INTEGRAL_FLAG"] ..
               colors["reset"])
    return header
end

function Decompiler:DecodeChunk()
    local chunk = {}
    local num;

    chunk["NAME"] = self:getString()
    chunk['FIRST_LINE'] = self:getInt()
    chunk['LAST_LINE'] = self:getInt()

    chunk['UPVALUES'] = self:getByte()
    chunk['ARGUMENTS'] = self:getByte()
    chunk['VARG'] = self:getByte()
    chunk['STACK'] = self:getByte()

    chunk["INSTRUCTIONS"] = {}
    chunk["CONSTANTS"] = {}
    chunk["PROTOS"] = {}
    chunk["DEBUG"] = {}

    num = self:getInt()
    local tc = 1
    for i = 1, num do
        local Instruction = {}

        local instr = self:getInt()
        local opcode = instr % 64
        local opinfo = getOpcodeInfo(opcode)
        Instruction["OPCODE"] = opcode
        Instruction["MNEMONIC"] = opinfo.mnemonic
        Instruction["TYPE"] = opinfo.type
        local a = floor(instr / (2 ^ 6)) % 256
        if opinfo.type == "ABC" then
            Instruction["REGISTERS"] = {
                A = a,
                B = {VALUE = floor(instr / (2 ^ 23)) % 512, MODE = opinfo.b},
                C = {VALUE = floor(instr / (2 ^ 14)) % 512, MODE = opinfo.c}
            }
        elseif opinfo.type == "ABx" then
            Instruction["REGISTERS"] = {
                A = a,
                Bx = {VALUE = floor(instr / (2 ^ 14)), MODE = opinfo.b}
            }
        else
            local Bx = floor(instr / (2 ^ 14))
            Instruction["REGISTERS"] = {
                A = a,
                sBx = {VALUE = Bx - 131071, MODE = opinfo.b}
            }
        end

        --[[
        Instruction 1: opcode = 5, mnemonic = GETGLOBAL, type = ABx, a = 0, b = 0, c = 0
        Instruction 2: opcode = 1, mnemonic = LOADK, type = ABx, a = 1, b = 0, c = 1
        Instruction 3: opcode = 28, mnemonic = CALL, type = ABC, a = 0, b = 2, c = 1
        Instruction 4: opcode = 30, mnemonic = RETURN, type = ABC, a = 0, b = 1, c = 0
        --]]

        table.insert(chunk["INSTRUCTIONS"], Instruction)
    end

    num = self:getInt()
    for i = 1, num do
        local constant_t = self:getByte()

        local data;
        if constant_t == 1 then
            data = (self:getByte() ~= 0)
        elseif constant_t == 3 then
            data = self:getDouble()
        elseif constant_t == 4 then
            data = self:getString()
        end

        chunk["CONSTANTS"][i - 1] = {["TYPE"] = constant_t, ["DATA"] = data}

    end

    num = self:getInt()
    for i = 1, num do chunk["PROTOS"][i] = self:DecodeChunk() end

    num = self:getInt()
    for i = 1, num do self:getInt32() end

    num = self:getInt()
    for i = 1, num do
        self:getString()
        self:getInt32()
        self:getInt32()
    end
    num = self:getInt()
    for i = 1, num do self:getString() end

    for k, Instruction in pairs(chunk["INSTRUCTIONS"]) do
        if Instruction["TYPE"] == "ABC" then
            if Instruction["REGISTERS"]["B"].MODE == "OpArgK" then
                if Instruction["REGISTERS"]["B"].VALUE >= 256 then
                    local ConstantRef = Instruction["REGISTERS"]["B"].VALUE -
                                            256
                    Instruction["REGISTERS"]["B"].CONSTANT =
                        chunk["CONSTANTS"][ConstantRef]
                else
                    Instruction["REGISTERS"]["B"].CONSTANT =
                        chunk["CONSTANTS"][Instruction["REGISTERS"]["B"].VALUE]
                end
            end

            if Instruction["REGISTERS"]["C"].MODE == "OpArgK" then
                if Instruction["REGISTERS"]["C"].VALUE >= 256 then
                    local ConstantRef = Instruction["REGISTERS"]["C"].VALUE -
                                            256
                    Instruction["REGISTERS"]["C"].CONSTANT =
                        chunk["CONSTANTS"][ConstantRef]

                else
                    Instruction["REGISTERS"]["C"].CONSTANT =
                        chunk["CONSTANTS"][Instruction["REGISTERS"]["C"].VALUE]
                end
            end
        elseif Instruction["TYPE"] == "ABx" then
            if Instruction["REGISTERS"]["B"].MODE == "OpArgK" then
                if Instruction["REGISTERS"]["B"].VALUE >= 256 then
                    local ConstantRef = Instruction["REGISTERS"]["B"].VALUE -
                                            256
                    Instruction["REGISTERS"]["B"].CONSTANT =
                        chunk["CONSTANTS"][ConstantRef]
                else
                    Instruction["REGISTERS"]["B"].CONSTANT =
                        chunk["CONSTANTS"][Instruction["REGISTERS"]["B"].VALUE]
                end
            end
        end
    end

    return chunk
end
-- self = self.new(bytecode)
return Decompiler
