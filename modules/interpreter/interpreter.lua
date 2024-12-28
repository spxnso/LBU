-- This is fucked up, I am working on a fix.
local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new(chunk, env)
    local self = setmetatable({}, Interpreter)
    self.Chunk = chunk
    self.Env = env or getfenv(0)
    return self
end

function Interpreter:Wrap()
    local mem = {}
    local pc = 1
    local chunk = self.Chunk
    local env = self.Env
    local top_idx = -1 -- gyat
    while true do
        local Instruction = chunk["INSTRUCTIONS"][pc]
        pc = pc + 1
        if not Instruction then break end
        local Opcode = Instruction["OPCODE"]

        if (Opcode == 0) then -- (*) MOVE
            mem[Instruction["REGISTERS"]["A"]] =
                mem[Instruction["REGISTERS"]["B"]["VALUE"]]
        elseif (Opcode == 1) then -- (*) LOADK
            mem[Instruction["REGISTERS"]["A"]] =
                Instruction["REGISTERS"]["Bx"]["CONSTANT"]["DATA"]
        elseif (Opcode == 5) then -- (*) GETGLOBAL
            mem[Instruction["REGISTERS"]["A"]] =
                env[Instruction["REGISTERS"]["Bx"]["CONSTANT"]["DATA"]]
        elseif (Opcode == 9) then -- (*) SETTABLE
            mem[Instruction["REGISTERS"]["A"]][Instruction["REGISTERS"]["B"]["CONSTANT"]["DATA"]] =
                Instruction["REGISTERS"]["C"]["CONSTANT"]["DATA"]
        elseif (Opcode == 10) then -- (*) NEWTABLE
            mem[Instruction["REGISTERS"]["A"]] = {}
        elseif (Opcode == 28) then -- (*) CALL
            return mem[Instruction["REGISTERS"]["A"]](mem[Instruction["REGISTERS"]["B"]["VALUE"]])
        elseif (Opcode == 30) then
            local length
            if mem[Instruction["REGISTER"]["B"]] == 1 then return end

            if mem[Instruction["REGISTER"]["B"]] == 0 then
                length = top_idx - mem[Instruction["REGISTER"]["A"]] + 1
            else
                length = mem[Instruction["REGISTER"]["B"]] - 1
            end

            local ret = {}
            local index = 0
            for i = mem[Instruction["REGISTER"]["A"]], length do
                index = index + 1
                ret[index] = mem[i]
            end

            return ret, index
        end
    end
end

return Interpreter
