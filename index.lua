local s = os.clock()
package.path = package.path ..
                   ";./modules/utils/?.lua;./modules/interpreter/?.lua;./modules/decompiler/?.lua"

local fs = require("fs")
local json = require("json")
local Decompiler = require("decompiler")

os.execute("luac -o output.luac input.lua")

local bytecode = fs:readFile(fs:openFile("output.luac", "rb"))
Decompiler = Decompiler.new(bytecode)
local result = Decompiler:Decompile(bytecode)
-- print(json.encode(result))


local e = os.clock()
local total = e - s
fs:closeFile("output.luac")
print(string.format("Succesfully decompiled your code in: %.3f seconds", total))