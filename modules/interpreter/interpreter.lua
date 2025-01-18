-- For more precisions about instructions, check lopcodes.h.lua
local Interpreter = {};
Interpreter.__index = Interpreter;
function Interpreter.new(chunk, env, upvalues)
    local self = setmetatable({}, Interpreter);
    self.Chunk = chunk;
    self.Upvalues = upvalues;
    self.Env = env or getfenv(0) or _ENV or _G;
    return self;
end
function Interpreter:ResolveRK(reg)
    if reg >= 256 then
        return self.Chunk.Constants[reg - 256].Value
    else
        return self.Stk[reg]
    end
end
function Interpreter:Wrap()
    self.Stk = {};
    local Chunk, Env, Upvalues, Constants, Stk = self.Chunk, self.Env,
                                                 self.Upvalues,
                                                 self.Chunk.Constants, self.Stk
    local pc = 1;
    local Top = -1;
    while true do
        local Instruction = Chunk.Instructions[pc];
        local Opcode = Instruction.OP;
        if (Opcode == 0) then -- MOVE
            Stk[Instruction.A] = Stk[Instruction.B];
        elseif (Opcode == 1) then -- LOADK 
            Stk[Instruction.A] = Constants[Instruction.Bx].Value;
        elseif (Opcode == 2) then -- LOADBOOL
            Stk[Instruction.A] = (Instruction.B ~= 0);
            pc = pc + Instruction.C;
        elseif (Opcode == 3) then -- LOADNIL
            for i = Instruction.A, Instruction.B do Stk[i] = nil; end
        elseif (Opcode == 4) then -- GETUPVAL
            Stk[Instruction.A] = Upvalues[Instruction.B];
        elseif (Opcode == 5) then -- GETGLOBAL 
            Stk[Instruction.A] = Env[Constants[Instruction.Bx].Value];
        elseif (Opcode == 6) then -- GETTABLE 
            Stk[Instruction.A] =
                Stk[Instruction.B][self:ResolveRK(Instruction.C)]
        elseif (Opcode == 7) then -- SETGLOBAL
            Env[Constants[Instruction.Bx].Value] = Stk[Instruction.A];
        elseif (Opcode == 8) then -- SETUPVAL
            Upvalues[Instruction.B] = Stk[Instruction.A];
        elseif (Opcode == 9) then -- SETTABLE
            Stk[Instruction.A][self:ResolveRK(Instruction.B)] = self:ResolveRK(
                                                                    Instruction.C)
        elseif (Opcode == 10) then -- NEWTABLE
            Stk[Instruction.A] = {};
        elseif (Opcode == 11) then -- SELF
            Stk[Instruction.A + 1] = Stk[Instruction.B];
            Stk[Instruction.A] =
                Stk[Instruction.B][self:ResolveRK(Instruction.C)]
        elseif (Opcode == 12) then -- ADD
            Stk[Instruction.A] = self:ResolveRK(Instruction.B) +
                                     self:ResolveRK(Instruction.C)
        elseif (Opcode == 13) then -- SUB
            Stk[Instruction.A] = self:ResolveRK(Instruction.B) -
                                     self:ResolveRK(Instruction.C)
        elseif (Opcode == 14) then -- MUL
            Stk[Instruction.A] = self:ResolveRK(Instruction.B) *
                                     self:ResolveRK(Instruction.C)
        elseif (Opcode == 15) then -- DIV
            Stk[Instruction.A] = self:ResolveRK(Instruction.B) /
                                     self:ResolveRK(Instruction.C)
        elseif (Opcode == 16) then -- MOD
            Stk[Instruction.A] = self:ResolveRK(Instruction.B) %
                                     self:ResolveRK(Instruction.C)
        elseif (Opcode == 17) then -- POW
            Stk[Instruction.A] = self:ResolveRK(Instruction.B) ^
                                     self:ResolveRK(Instruction.C)
        elseif (Opcode == 18) then -- UNM
            Stk[Instruction.A] = -Stk[Instruction.B]
        elseif (Opcode == 19) then -- NOT
            Stk[Instruction.A] = not Stk[Instruction.B]
        elseif (Opcode == 20) then -- LEN
            Stk[Instruction.A] = #Stk[Instruction.B]
        elseif (Opcode == 21) then -- CONCAT
            for i = Instruction.B + 1, Instruction.C do
                Stk[Instruction.B] = Stk[Instruction.B] .. Stk[i]
            end
        elseif (Opcode == 22) then -- JMP
            pc = pc + Instruction.sBx
        elseif (Opcode == 23) then -- EQ
            if (self:ResolveRK(Instruction.B) == self:ResolveRK(Instruction.C)) ~=
                (Instruction.A ~= 0) then pc = pc + 1 end
        elseif (Opcode == 24) then -- LT
            if (self:ResolveRK(Instruction.B) < self:ResolveRK(Instruction.C)) ~=
                (Instruction.A ~= 0) then pc = pc + 1 end
        elseif (Opcode == 25) then -- LE
            if (self:ResolveRK(Instruction.B) <= self:ResolveRK(Instruction.C)) ~=
                (Instruction.A ~= 0) then pc = pc + 1 end
        elseif (Opcode == 26) then -- TEST
            if not (Stk[Instruction.A] == (Instruction.C ~= 0)) then
                pc = pc + 1
            end
        elseif (Opcode == 27) then -- TESTSET
            if (Stk[Instruction.B] == (Instruction.C ~= 0)) then
                Stk[Instruction.A] = Stk[Instruction.B]
            else
                pc = pc + 1
            end
        elseif (Opcode == 28) then -- CALL
            local func = Stk[Instruction.A]
            local args = {}
            local limit;

            if (Instruction.B ~= 0) then
                limit = Instruction.A + Instruction.B - 1
            else
                limit = Top
            end
            for i = Instruction.A + 1, limit do
                args[#args + 1] = Stk[i]
            end
            local results = {func(unpack(args, 1, limit))}

            Top = Instruction.A;
            if (Instruction.C ~= 0) then
                limit = Instruction.A + Instruction.C - 2
            else
                limit = limit + Instruction.A - 1;
            end
            for i = Instruction.A, limit do
                Stk[i] = results[i - Instruction.A + 1]
            end
        elseif (Opcode == 29) then -- TAILCALL
            local func = Stk[Instruction.A]
            local args = {}
            for i = Instruction.A + 1, Instruction.A + Instruction.B - 1 do
                args[#args + 1] = Stk[i]
            end
            return func(unpack(args))
        elseif (Opcode == 30) then --  RETURN
            return unpack(Stk, Instruction.A, (Instruction.A + Instruction.B - 2))
        elseif (Opcode == 31) then -- FORLOOP
            Stk[Instruction.A] = Stk[Instruction.A] + Stk[Instruction.A + 2]
            if Stk[Instruction.A] <= Stk[Instruction.A + 1] then
                pc = pc + Instruction.sBx;
                Stk[Instruction.A + 3] = Stk[Instruction.A]
            end
        elseif (Opcode == 32) then -- FORPREP
            Stk[Instruction.A] = Stk[Instruction.A] - Stk[Instruction.A + 2];
            pc = pc + Instruction.sBx;
        elseif (Opcode == 33) then -- TFORLOOP
            local func = Stk[Instruction.A]
            local results = {
                func(Stk[Instruction.A + 1], Stk[Instruction.A + 2])
            };
            for i = 1, Instruction.C do
                Stk[Instruction.A + 2 + i] = results[i]
            end
            if Stk[Instruction.A + 3] ~= nil then
                Stk[Instruction.A + 2] = Stk[Instruction.A + 3]
            else
                pc = pc + 1;
            end
        elseif (Opcode == 34) then -- SETLIST
            local FPF = 50;

            for i = 1, Instruction.B do
                Stk[Instruction.A][(Instruction.C - 1) * FPF + i] =
                    Stk[Instruction.A + i]
            end
        elseif (Opcode == 35) then -- CLOSE
            for i = Stk[Instruction.A], #Stk do Stk[i] = nil; end
        elseif (Opcode == 36) then -- CLOSURE
            local Proto = Chunk.Protos[Instruction.Bx]
            local closureInterpreter = Interpreter.new(Proto, getfenv(0))
            -- TODO: Handle upvalues
            Stk[Instruction.A] = function(...)
                return closureInterpreter:Wrap()
            end;
        end
        self.Stk = Stk;
        pc = pc + 1;
    end
end
return Interpreter;
