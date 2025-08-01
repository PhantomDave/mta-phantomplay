function buyHouseFunction(player, house)

    if not house then
        outputChatBox("House broken ", player)
        return
    end

    if house.owner then
        outputChatBox("This house is already owned by someone else.", player)
        return
    end

    local character = Character.getFromPlayer(player)
    if not character then
        return
    end

    local price = house.price
    if not character:hasBankMoney(price) then
        outputChatBox("You do not have enough money to buy this house. Price: $" .. price .. " You have: $" .. (character:getBankMoney()), player)
        return
    end

    house:setOwner(character)

    outputChatBox("You have successfully bought the house for $" .. price, player)
end