package.path = package.path .. ";./modules/utils/?.lua;./modules/interpreter/?.lua;./modules/deserializer/?.lua";
os.execute("luac -o output.luac input.lua");
local fs = require("fs");
local Decompiler = require("deserializer");
local Interpreter = require("interpreter");
local bytecode, file = fs:readFile(fs:openFile("output.luac", "rb"));
local bytet = {};
local Decompiler = Decompiler.new(bytecode, true); -- 2nd argument will enable debug prints, useful if you want to understand bytecode. Will slow down performances.

local deserializationStart = os.clock();
local result = Decompiler:Decompile(bytecode);
local deserializationEnd = os.clock();
local deserializationTotal = deserializationEnd - deserializationStart;

print("\n----------------------");
local interpretationStart = os.clock();
Interpreter = Interpreter.new(result[2], getfenv(0));
local t = Interpreter:Wrap();
local interpretationEnd = os.clock();
local interpretationTotal = interpretationEnd - interpretationStart;
print("----------------------");
local size = file:seek("end");
fs:closeFile("input.lua")
fs:closeFile("output.luac");

print("\n----------------------");
print(string.format("Succesfully decompiled your code!"));
print("----------------------");
print(string.format("Deserialization Time: %.6f seconds", deserializationTotal));
print(string.format("Interpretation Time: %.6f seconds", interpretationTotal));
print(string.format("Bytecode File Size: %d bytes", size));
print("----------------------");
