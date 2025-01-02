-- MIT License
-- Copyright (c) 2024 spxnso
-- The interpreter has been discontinued. Expect a faster, better rewrite soon!
package.path = package.path ..
                   ";./modules/utils/?.lua;./modules/interpreter/?.lua;./modules/decompiler/?.lua"
os.execute("luac -o output.luac input.lua")
local fs = require("fs")
local Decompiler = require("decompiler")
local Rerubi = require("rerubi")
local decompilationStart = os.clock()
local bytecode, file = fs:readFile(fs:openFile("output.luac", "rb"))
Decompiler = Decompiler.new(bytecode, true) -- the second argument enables colored prints.
local result = Decompiler:Decompile(bytecode)
local decompilationEnd = os.clock()
local decompilationTotal = decompilationEnd - decompilationStart
local size = file:seek("end")


fs:closeFile("output.luac")
print("\n----------------------")
print(string.format("Succesfully decompiled your code!"))
print("----------------------")
print(string.format("Decompilation Time: %.6f seconds", decompilationTotal))
print(string.format("Bytecode File Size: %d bytes", size))
print("----------------------")
