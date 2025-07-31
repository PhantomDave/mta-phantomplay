function createHouseCommand(player, commandname, price)

    local account = Account.getFromPlayer(player)
    if not account or not account:isAdmin() then
        outputChatBox("You don't have permission to use this command.", player)
        return
    end

    local x, y, z = getElementPosition(player)

    if not price or price == "" then
        outputChatBox("Usage: /createhouse <price>", player)
        outputChatBox("Price must be a valid positive number.", player)
        return
    end
    
    House.createNew(x, y, z, price, function(house)
        if house then
            house:createVisuals()
            table.insert(houses, house)
            outputChatBox("House created successfully at (" .. x .. ", " .. y .. ", " .. z .. ") for $" .. price, player)
        else
            outputChatBox("Failed to create house.", player)
        end
    end)
end

addCommandHandler("createhouse", createHouseCommand)

