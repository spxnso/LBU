local Decompiler = {}
local bit = require("modules.utils.bit32")
Decompiler.__index = Decompiler

function Decompiler.new(bytecode)
    if type(bytecode) == "string" then
        bytecode = {string.byte(bytecode, 1, #bytecode)}
    end
    local self = setmetatable({}, Decompiler)
    self.bytecode = bytecode
    self.index = 0
    self.bigEndian = false
    self.sizeT = 1
    self.intSize = 1
    return self
end

function Decompiler:getByte()
    local b = self.bytecode[self.index + 1]
    self.index = self.index + 1
    return b
end

function Decompiler:getInt32()
    local i = 0
    if self.bigEndian then
        i = (self.bytecode[self.index + 1] * 256 ^ 3) +
                (self.bytecode[self.index + 2] * 256 ^ 2) +
                (self.bytecode[self.index + 3] * 256) +
                self.bytecode[self.index + 4]
    else
        i = (self.bytecode[self.index + 1]) +
                (self.bytecode[self.index + 2] * 256) +
                (self.bytecode[self.index + 3] * 256 ^ 2) +
                (self.bytecode[self.index + 4] * 256 ^ 3)
    end
    self.index = self.index + 4
    return i
end

function Decompiler:getInt()
    local i = 0
    if self.bigEndian then
        for j = 1, self.intSize do
            i = i * 256 + self.bytecode[self.index + j]
        end
    else
        for j = self.intSize, 1, -1 do
            i = i * 256 + self.bytecode[self.index + j]
        end
    end
    self.index = self.index + self.intSize
    return i
end

function Decompiler:getSizeT()
    local s = 0
    if self.bigEndian then
        for j = 1, self.sizeT do
            s = s * 256 + self.bytecode[self.index + j]
        end
    else
        for j = self.sizeT, 1, -1 do
            s = s * 256 + self.bytecode[self.index + j]
        end
    end
    self.index = self.index + self.sizeT
    return s
end

function Decompiler:getDouble()
    local lowInt = self:getInt()
    local highInt = self:getInt()

    local sign = bit:band(highInt, 0x80000000) ~= 0 and -1 or 1
    local exponent = bit:band(bit:rshift(highInt, 20), 0x7FF)
    local fraction = (bit:band(highInt, 0xFFFFF) * 4294967296.0 + lowInt) /
                         (2 ^ 52)
    local double = sign * (2 ^ (exponent - 1023)) * (1 + fraction)

    return double
end

function Decompiler:getString(size)
    size = self:getSizeT()
    if size == 0 then return "" end

    local s = ""
    for i = self.index + 1, self.index + size do
        s = s .. string.char(self.bytecode[i])
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

    return {header, chunk}
end

function Decompiler:DecodeHeader()
    self.index = 4 -- skipping the signature
    local header = {}

    header["VM_VERSION"] = self:getByte()
    header["FORMAT"] = self:getByte()
    header["ENDIANNESS"] = self:getByte()
    header["INT_SIZE"] = self:getByte()
    header["SIZE_T"] = self:getByte()
    header["INSTRUCTION_SIZE"] = self:getByte()
    header["L_NUMBER_SIZE"] = self:getByte()
    header["INTEGRAL_FLAG"] = self:getByte()

    self.intSize = header["INT_SIZE"]
    self.sizeT = header["SIZE_T"]

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
        if opinfo.type == "ABC" then
            Instruction["REGISTERS"] = {
                A = math.floor(instr / (2 ^ 6)) % 256,
                B = {
                    VALUE = math.floor(instr / (2 ^ 23)) % 512,
                    MODE = opinfo.b
                },
                C = {
                    VALUE = math.floor(instr / (2 ^ 14)) % 512,
                    MODE = opinfo.c
                }
            }
        elseif opinfo.type == "ABx" then
            Instruction["REGISTERS"] = {
                A = math.floor(instr / (2 ^ 6)) % 256,
                Bx = {VALUE = math.floor(instr / (2 ^ 14)), MODE = opinfo.b}
            }
        else
            local Bx = math.floor(instr / (2 ^ 14))
            Instruction["REGISTERS"] = {
                A = math.floor(instr / (2 ^ 6)) % 256,
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
        table.insert(chunk["CONSTANTS"],
                     {["TYPE"] = constant_t, ["DATA"] = data})
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

    return chunk
end
-- self = self.new(bytecode)
return Decompiler
