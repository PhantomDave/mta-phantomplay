function createHouseForPlayer(thePlayer, command, price, x, y, z)
    if not x or not y or not z then
        x, y, z = getElementPosition(thePlayer)
    end

    if not price or tonumber(price) <= 0 then
        outputChatBox("Invalid price specified. Please provide a valid number greater than 0.", thePlayer, 255, 0, 0)
        return
    end

    createHouse(x, y, z, tonumber(price), function(result)
        if result then
            outputChatBox("House created successfully at (" .. x .. ", " .. y .. ", " .. z .. ") for $" .. price .. ".", thePlayer, 0, 255, 0)
            updateHouseRadar()
        else
            outputChatBox("Failed to create house. Please try again later.", thePlayer, 255, 0, 0)
        end
    end)
end


addCommandHandler("createhouse", createHouseForPlayer)

