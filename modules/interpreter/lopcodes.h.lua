-- MIT License
-- Copyright (c) 2024 spxnso


-- MOVE:
Stk[Instruction.A] = Stk[Instruction.B]

-- LOADK:
Stk[Instruction.A] = Constants[Instruction.Bx].Value

-- LOADBOOL:
Stk[Instruction.A] = (Instruction.B ~= 0); pc = pc + Instruction.C

-- LOADNIL:
for i = Instruction.A, Instruction.B do
    Stk[i] = nil;
end

-- GETUPVAL:
Stk[Instruction.A] = Upvalues[Instruction.B]

-- GETGLOBAL:
Stk[Instruction.A] = Env[Constants[Instruction.Bx].Value]

-- GETTABLE:
Stk[Instruction.A] = Stk[Instruction.B][self:ResolveRK(Instruction.C)]

-- SETGLOBAL:
Env[Constants[Instruction.Bx].Value] = Stk[Instruction.A]

-- SETUPVAL:
Upvalues[Instruction.B] = Stk[Instruction.A]

-- SETTABLE:
Stk[Instruction.A][self:ResolveRK(Instruction.B)] = self:ResolveRK(Instruction.C)

-- NEWTABLE:
Stk[Instruction.A] = {};

-- SELF:
Stk[Instruction.A + 1] = Stk[Instruction.B]
Stk[Instruction.A] = Stk[Instruction.B][self:ResolveRK(Instruction.C)]

-- ADD:
Stk[Instruction.A] = self:ResolveRK(Instruction.B) + self:ResolveRK(Instruction.C)

-- SUB:
Stk[Instruction.A] = self:ResolveRK(Instruction.B) - self:ResolveRK(Instruction.C)

-- MUL:
Stk[Instruction.A] = self:ResolveRK(Instruction.B) * self:ResolveRK(Instruction.C)

-- DIV:
Stk[Instruction.A] = self:ResolveRK(Instruction.B) / self:ResolveRK(Instruction.C)

-- MOD:
Stk[Instruction.A] = self:ResolveRK(Instruction.B) % self:ResolveRK(Instruction.C)

-- POW:
Stk[Instruction.A] = self:ResolveRK(Instruction.B) ^ self:ResolveRK(Instruction.C)

-- UNM:
Stk[Instruction.A] = -Stk[Instruction.B]

-- NOT:
Stk[Instruction.A] = not Stk[Instruction.B]

-- LEN:
Stk[Instruction.A] = #Stk[Instruction.B]

-- CONCAT:
for i = Instruction.B + 1, Instruction.C do
    Stk[Instruction.B] = Stk[Instruction.B] .. Stk[i]
end

-- JMP: 
pc = pc + Instruction.sBx

-- EQ:
if (self:ResolveRK(Instruction.B) == self:ResolveRK(Instruction.C)) ~= (Instruction.A ~= 0) then pc = pc + 1 end

-- LT:
if (self:ResolveRK(Instruction.B) < self:ResolveRK(Instruction.C)) ~= (Instruction.A ~= 0) then pc = pc + 1 end

-- LE:
if not (Stk[Instruction.A] == (Instruction.C ~= 0)) then pc = pc + 1 end

-- TEST: 
if not (Stk[Instruction.A] == (Instruction.C ~= 0)) then pc = pc + 1 end

-- TESTSET:
if (Stk[Instruction.B] == (Instruction.C ~= 0)) then Stk[Instruction.A] = Stk[Instruction.B] else pc = pc + 1 end;

-- CALL:
local func = Stk[Instruction.A]
local args = {}
for i = Instruction.A + 1, Instruction.A + Instruction.B - 1 do
    args[#args + 1] = Stk[i]
end
local results = {func(unpack(args))}
for i = Instruction.A, Instruction.A + Instruction.C - 2 do
    Stk[i] = results[i - Instruction.A + 1]
end

-- TAILCALL: 
local func = Stk[Instruction.A]
local args = {}
for i = Instruction.A + 1, Instruction.A + Instruction.B - 1 do
    args[#args + 1] = Stk[i]
end

-- RETURN:
return unpack(Stk, Instruction.A, (Instruction.A + Instruction.B - 2))

-- FORLOOP:
Stk[Instruction.A] = Stk[Instruction.A] + Stk[Instruction.A + 2]
if Stk[Instruction.A] <= Stk[Instruction.A + 1] then
    pc = pc + Instruction.sBx;
    Stk[Instruction.A + 3] = Stk[Instruction.A]
end

-- FORPREP:
Stk[Instruction.A] = Stk[Instruction.A] - Stk[Instruction.A + 2]
pc = pc + Instruction.sBx;                    

-- TFORLOOP
local func = Stk[Instruction.A]
local results = {func(Stk[Instruction.A + 1], Stk[Instruction.A] + 2)};
for i = 1, Instruction.C do
    Stk[Instruction.A + 2 + i] = results[i]
end
if Stk[Instruction.A + 3] ~= nil then
    Stk[Instruction.A+2] = Stk[Instruction.A + 3]
else
    pc = pc + 1;
end

-- SETLIST
local FPF = 50;

for i = 1, Instruction.B do
     Stk[Instruction.A][(Instruction.C - 1) * FPF + i] =  Stk[Instruction.A + i]
end

-- CLOSE
for i = Stk[Instruction.A], #Stk do
    Stk[i] = nil;
end