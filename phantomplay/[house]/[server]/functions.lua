function buyHouseCommand(player, commandName, house)

    if not house then
        outputChatBox("House broken ", player)
        return
    end

    if house.owner then
        outputChatBox("This house is already owned by someone else.", player)
        return
    end

    local price = house.price
    if getPlayerMoney(player) < price then
        outputChatBox("You do not have enough money to buy this house. Price: $" .. price, player)
        return
    end

    house:setOwner(player)

    outputChatBox("You have successfully bought the house for $" .. price, player)
end