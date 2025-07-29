function GetMoneyByNumberOfCharacters(numCharacters)
    if not numCharacters or numCharacters > 5 then return 0 end
    local baseMoney = 50000
    return baseMoney / numCharacters
end
