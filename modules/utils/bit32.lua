local bit32 = {}

function bit32:lshift(a, b)
     return a * 2 ^ b 
end

function bit32:rshift(a, b) return 
    math.floor(a / 2 ^ b) 
end

function bit32:band(a, b)
    local result = 0
    local shift = 1
    for i = 0, 31 do
        if (a % 2 == 1 and b % 2 == 1) then result = result + shift end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        shift = shift * 2
    end
    return result
end

function bit32:bor(a, b)
    local result = 0
    local shift = 1
    for i = 0, 31 do
        if (a % 2 == 1 or b % 2 == 1) then result = result + shift end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        shift = shift * 2
    end
    return result
end

function bit32:bxor(a, b)
    local result = 0
    local shift = 1
    for i = 0, 31 do
        if (a % 2 ~= b % 2) then result = result + shift end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        shift = shift * 2
    end
    return result
end


return bit32
