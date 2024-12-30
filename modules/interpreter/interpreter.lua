-- I could not do this without the help of a-no-frills-introduction-to-lua-5.1-vm-instructions's pdf, Rerubi & Fiu.
-- Thanks to these amazing developers!
local Interpreter = {}
Interpreter.__index = Interpreter

local function _Returns(...) return select('#', ...), {...}; end

function Interpreter.new(chunk, env)
    local self = setmetatable({}, Interpreter)
    self.Chunk = chunk
    self.Env = env or getfenv(0) or _ENV or _G;
    return self
end

function Interpreter:Wrap()
    local mem = {}
    local pc = 1
    local chunk = self.Chunk
    local env = self.Env
    local stackTop = -1
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
        elseif (Opcode == 2) then -- (*) LOADBOOL
            mem[Instruction["REGISTERS"]["A"]] =
                (Instruction["REGISTERS"]["B"]["VALUE"] ~= 0)
            if Instruction["REGISTERS"]["C"]["VALUE"] ~= 0 then
                pc = pc + 1
            end
        elseif (Opcode == 3) then -- (*) LOADNIL
            for i = Instruction["REGISTERS"]["A"], Instruction["REGISTERS"]["B"]["VALUE"] do
                mem[i] = nil
            end
        elseif (Opcode == 5) then -- (*) GETGLOBAL
            mem[Instruction["REGISTERS"]["A"]] =
                env[Instruction["REGISTERS"]["Bx"]["CONSTANT"]["DATA"]]
        elseif (Opcode == 6) then -- (*) GETTABLE: R(A) := R(B)[RK(C)]
            mem[Instruction["REGISTERS"]["A"]] =
                mem[Instruction["REGISTERS"]["B"].VALUE][Instruction["REGISTERS"]["C"]["CONSTANT"]["DATA"] or
                    mem[Instruction["REGISTERS"]["C"]["VALUE"]]]
        elseif (Opcode == 7) then -- (*) SETGLOBAL
            env[Instruction["REGISTERS"]["Bx"]["CONSTANT"]["DATA"]] =
                mem[Instruction["REGISTERS"]["A"]]
        elseif (Opcode == 9) then -- (*) SETTABLE: R(A)[RK(B)] := RK(C)
            mem[Instruction["REGISTERS"]["A"]][Instruction["REGISTERS"]["B"]["CONSTANT"]["DATA"] or
                mem[Instruction["REGISTERS"]["B"]["VALUE"]]] =
                Instruction["REGISTERS"]["C"]["CONSTANT"]["DATA"] or
                    mem[Instruction["REGISTERS"]["C"]["VALUE"]]
        elseif (Opcode == 10) then -- (*) NEWTABLE
            mem[Instruction["REGISTERS"]["A"]] = {}
        elseif (Opcode == 28) then -- (*) CALL
            local results;
            local paramsCount;
            local saveLimit;
            local edx;
            local args;

            args = {}
            paramsCount = (Instruction["REGISTERS"]["B"]["VALUE"] == 0 and
                              stackTop - Instruction["REGISTERS"]["A"] or
                              Instruction["REGISTERS"]["B"]["VALUE"] - 1)

            if Instruction["REGISTERS"]["B"]["VALUE"] ~= 1 then
                
                results = { mem[Instruction["REGISTERS"]["A"]](unpack(mem, Instruction["REGISTERS"]["A"] + 1, Instruction["REGISTERS"]["A"] + paramsCount)) } -- Inspired from Fiu's CALL Opcode which was handled amazingly!
            else
                results = { mem[Instruction["REGISTERS"]["A"]]() }
            end

            stackTop = Instruction["REGISTERS"]["A"] + paramsCount - 1

            saveLimit = 0
            if Instruction["REGISTERS"]["C"]["VALUE"] ~= 1 then
                if Instruction["REGISTERS"]["C"]["VALUE"] ~= 0 then
                    saveLimit = Instruction["REGISTERS"]["A"] +
                                    Instruction["REGISTERS"]["C"]["VALUE"] - 2;
                else
                    saveLimit = paramsCount + Instruction["REGISTERS"]["A"] - 1
                end
                edx = 0
                for index = Instruction["REGISTERS"]["A"], saveLimit do
                    edx = edx + 1;
                    mem[index] = results[edx]
                end
            end
        elseif (Opcode == 30) then
            local returnsCount;
            local edx;
            local returnsOutput;

            returnOutput = {}
            if Instruction["REGISTERS"]["B"]["VALUE"] ~= 1 then
                if Instruction["REGISTERS"]["B"]["VALUE"] ~= 0 then
                    -- 2 or more
                    returnsCount = Instruction["REGISTERS"]["A"] +
                                       Instruction["REGISTERS"]["B"]["VALUE"] -
                                       2
                else
                    returnsCount = stackTop;
                end

                edx = 0
                returnsOutput = {}
                for index = Instruction["REGISTERS"]["A"], returnsCount do
                    edx = edx + 1;
                    returnsOutput[edx] = mem[index];
                end
                return returnOutput, edx
            else
                return;
            end
        end
    end
end

return Interpreter
