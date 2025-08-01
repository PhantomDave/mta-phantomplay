function addToDealershipCommand(player, command, model, price, dealershipId)

    local account = Account.getFromPlayer(player)

    if not account or account:getAdminLevel() < 2 then
        outputChatBox("You do not have permission to create a dealership.", player, 255, 0, 0)
        return
    end

    if not model or model == "" then
        outputChatBox("Usage: /" .. command .. " [model] [price] [dealershipId]", player, 255, 255, 0)
        return
    end

    if not price or price == "" then
        outputChatBox("Usage: /" .. command .. " [model] [price] [dealershipId]", player, 255, 255, 0)
        return
    end

    if not dealershipId or dealershipId == "" then
        outputChatBox("Usage: /" .. command .. " [model] [price] [dealershipId]", player, 255, 255, 0)
        return
    end

    local dealership = Dealership.getFromId(dealershipId, function(dealership)
        if not dealership then
            outputChatBox("Dealership with ID " .. dealershipId .. " does not exist.", player, 255, 0, 0)
            return
        end

        local dealershipVehicle = DealershipVehicle:create({
            model = model,
            price = tonumber(price),
            dealershipId = dealershipId,
        })
    
        dealershipVehicle:save(function(success)
            if success then
                outputChatBox("Vehicle added to dealership successfully!", player, 0, 255, 0)
            else
                outputChatBox("Failed to add vehicle to dealership. Please try again.", player, 255, 0, 0)
            end
        end)
    end)
end

addCommandHandler("addtodealership", addToDealershipCommand)