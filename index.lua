-- MIT License
-- Copyright (c) 2024 spxnso
package.path = package.path ..
                   ";./modules/utils/?.lua;./modules/interpreter/?.lua;./modules/decompiler/?.lua"
os.execute("luac -o output.luac input.lua")
local fs = require("fs")
local json = require("json")
local Decompiler = require("decompiler")

local s = os.clock()
local bytecode, file = fs:readFile(fs:openFile("output.luac", "rb"))
Decompiler = Decompiler.new(bytecode)
local result = Decompiler:Decompile(bytecode)
-- print(json.encode(result))

local e = os.clock()
local total = e - s
local size = file:seek("end")
fs:closeFile("output.luac")
print("\n----------------------")
print(string.format("Succesfully decompiled your code!"))
print("----------------------")
print(string.format("Decompilation Time: %.3f seconds", total))
print(string.format("Bytecode File Size: %d bytes", size))
print("----------------------")
