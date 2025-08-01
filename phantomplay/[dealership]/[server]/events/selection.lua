function onDealershipVehicleSelected(dealershipId, selectedVehicleId)
    local player = client
    if not player or not isElement(player) then
        return
    end

    if not selectedVehicleId or not dealershipId then
        outputChatBox("Invalid vehicle selection.")
        return
    end

    -- Assuming DealershipVehicle is a predefined class that handles vehicle data
   DealershipVehicle.getFromId(selectedVehicleId, dealershipId, function(dealershipVehicle)
       if dealershipVehicle then
        local x, y, z = player:getPosition()
        local vehicle = Vehicle(dealershipVehicle.model, x, y, z)
        vehicle:spawn(x, y, z)
        player:outputChat("You have purchased a " .. vehicle:getName() .. " for $" .. dealershipVehicle.price)
        triggerClientEvent(player, EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, player)
       else
           outputChatBox("Failed to retrieve vehicle information.", player)
       end
   end)
end


addEvent(EVENTS.VEHICLES.ON_VEHICLE_SELECTED, true)
addEventHandler(EVENTS.VEHICLES.ON_VEHICLE_SELECTED, root, onDealershipVehicleSelected)