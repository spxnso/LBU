local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new(chunk, env)
    local self = setmetatable({}, Interpreter)
    self.Chunk = chunk
    self.Env = env or getfenv(0)
    return self
end

function Interpreter:Wrap()
    local pc = 1
    local chunk = self.Chunk
    local env = self.Env
    while true do
        pc = pc + 1
        local Instruction = chunk["INSTRUCTIONS"][pc]
        if not Instruction then break end
        local Opcode = Instruction["OPCODE"]

        if (Opcode == 0) then
            --print("MOVE")
        elseif (Opcode == 1) then
            
        else
            --print("UNKNOWN")
        end
    end
end


return Interpreter
