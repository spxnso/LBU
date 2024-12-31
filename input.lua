function getOpcodeInfo(opcode)
    local info = {
        [0] = { type = "ABC", mnemonic = "MOVE", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABx", mnemonic = "LOADK", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "LOADBOOL", b = 'OpArgU', c = 'OpArgU'},
        {type = "ABC", mnemonic = "LOADNIL", b = 'OpArgR', c = 'OpArgN'},
        {type = "ABC", mnemonic = "GETUPVAL", b = 'OpArgU', c = 'OpArgN'},
        {type = "ABx", mnemonic = "GETGLOBAL", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "GETTABLE", b = 'OpArgR', c = 'OpArgK'},
        {type = "ABx", mnemonic = "SETGLOBAL", b = 'OpArgK', c = 'OpArgN'},
        {type = "ABC", mnemonic = "SETUPVAL", b = 'OpArgU', c = 'OpArgN'},
        {type = "ABC", mnemonic = "SETTABLE", b = 'OpArgK', c = 'OpArgK'},
        {type = "ABC", mnemonic = "NEWTABLE", b = 'OpArgU', c = 'OpArgU'},
        {type = "ABC", mnemonic = "SELF", b = 'OpArgR', c = 'OpArgK'},
        {type = "ABC", mnemonic = "ADD", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "SUB", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "MUL", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "DIV", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "MOD", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "POW", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "UNM", b = 'OpArgR', c = 'OpArgR'},
        {type = "ABC", mnemonic = "NOT", b = 'OpArgR', c = 'OpArgR'}, -- Fixed
        {type = "ABC", mnemonic = "LEN", b = 'OpArgR', c = 'OpArgR'}, -- Fixed
        {type = "ABC", mnemonic = "CONCAT", b = 'OpArgR', c = 'OpArgR'}, -- Fixed
        {type = "AsBx", mnemonic = "JMP", b = 'OpArgN', c = 'OpArgN'}, -- Fixed
        {type = "ABC", mnemonic = "EQ", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "LT", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "LE", b = 'OpArgR', c = 'OpArgK'}, -- Fixed
        {type = "ABC", mnemonic = "TEST", b = 'OpArgN', c = 'OpArgU'}, -- Fixed
        {type = "ABC", mnemonic = "TESTSET", b = 'OpArgR', c = 'OpArgU'}, -- Fixed
        {type = "ABC", mnemonic = "CALL", b = 'OpArgU', c = 'OpArgU'}, -- Fixed
        {type = "ABC", mnemonic = "TAILCALL", b = 'OpArgU', c = 'OpArgU'}, -- Fixed
        {type = "ABC", mnemonic = "RETURN", b = 'OpArgU', c = 'OpArgN'}, -- Fixed
        {type = "AsBx", mnemonic = "FORLOOP", b = 'OpArgR', c = 'OpArgN'},
        {type = "AsBx", mnemonic = "FORPREP", b = 'OpArgR', c = 'OpArgN'}, -- Fixed
        {type = "ABC", mnemonic = "TFORLOOP", b = 'OpArgN', c = 'OpArgU'}, -- Fixed
        {type = "ABC", mnemonic = "SETLIST", b = 'OpArgU', c = 'OpArgU'}, -- Fixed
        {type = "ABC", mnemonic = "CLOSE", b = 'OpArgN', c = 'OpArgN'}, -- Fixed
        {type = "ABx", mnemonic = "CLOSURE", b = 'OpArgU', c = 'OpArgN'},
        {type = "ABC", mnemonic = "VARARG", b = 'OpArgU', c = 'OpArgU'} -- Fixed
    }

    return info[opcode]
end