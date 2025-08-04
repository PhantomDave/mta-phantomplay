function onVehicleParkCommand(player, commandName, vehicle)
    if vehicle == nil then
        vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            outputChatBox("You are not in a vehicle.", player, 255, 0, 0)
            return
        end
    end
    
    local character = Character.getFromPlayer(player)
    local playerVehicle = PlayerVehicle.getFromVehicle(vehicle)
    if not playerVehicle or not playerVehicle:ownedByPlayer(player) then
        outputChatBox("This vehicle is not registered to you.", player, 255, 0, 0)
        return
    end

    local position = vehicle:getPosition()
    local rotation = vehicle:getRotation()

    playerVehicle:park(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, function(success)
        if success then
            outputChatBox("Your vehicle has been parked successfully.", player, 0, 255, 0)
        else
            outputChatBox("Failed to park your vehicle. Please try again later.", player, 255, 0, 0)
        end
    end)
end

addCommandHandler("park", onVehicleParkCommand)