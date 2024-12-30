            args = {}
            paramsCount = 0
            local params = (Instruction["REGISTERS"]["B"]["VALUE"] == 0 and stackTop - Instruction["REGISTERS"]["A"] or Instruction["REGISTERS"]["B"]["VALUE"] - 1)
                               
            if Instruction["REGISTERS"]["B"]["VALUE"] ~= 1 then
                results = { mem[Instruction["REGISTERS"]["A"]]           }
                end 
            else
            results = {mem[Instruction["REGISTERS"]["A"]]()}
            end