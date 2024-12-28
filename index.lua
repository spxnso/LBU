-- MIT License
-- Copyright (c) 2024 spxnso
package.path = package.path ..
                   ";./modules/utils/?.lua;./modules/interpreter/?.lua;./modules/decompiler/?.lua"
os.execute("luac -o output.luac input.lua")
local fs = require("fs")
local Decompiler = require("decompiler")
local Interpreter = require("interpreter")

local decompilationStart = os.clock()
local bytecode, file = fs:readFile(fs:openFile("output.luac", "rb"))
Decompiler = Decompiler.new(bytecode, true) -- the second argument enables colored prints.
local result = Decompiler:Decompile(bytecode)
local decompilationEnd = os.clock()
local decompilationTotal = decompilationEnd - decompilationStart
local size = file:seek("end")

local interpretationStart = os.clock()
Interpreter = Interpreter.new(result[2], getfenv(0))
local r = Interpreter:Wrap()
local interpretationEnd = os.clock()
local intepreationTotal = interpretationEnd - interpretationStart


fs:closeFile("output.luac")
print("\n----------------------")
print(string.format("Succesfully decompiled & interpreted your code!"))
print("----------------------")
print(string.format("Decompilation Time: %.6f seconds", decompilationTotal))
print(string.format("Interpretation Time: %.6f seconds", intepreationTotal))
print(string.format("Bytecode File Size: %d bytes", size))
print("----------------------")
