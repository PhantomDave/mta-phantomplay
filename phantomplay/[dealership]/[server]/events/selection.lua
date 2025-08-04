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
            local x, y, z = getElementPosition(player)
           -- Create vehicle data table for ServerVehicle:new()
           local vehicleData = {
               model = dealershipVehicle.model,
               owner = Character.getFromPlayer(player).id,
               x = x,
               y = y,
               z = z,
               rx = 0,
               ry = 0,
               rz = 0,
               plate = "NONE",
               alias = dealershipVehicle.name or Vehicle.getNameFromModel(dealershipVehicle.model),
               health = 1000,
               fuelType = "petrol",
               fuelLevel = 100,
               isLocked = false,
               isEngineOn = false
           }
           
           local vehicle = PlayerVehicle:new(vehicleData)
           vehicle:insert(function(success)
               if success then
                   outputDebugString("[DEBUG] Vehicle purchased successfully: " .. tostring(vehicleData.alias))
                   player:outputChat("You have purchased a " .. (dealershipVehicle.name or Vehicle.getNameFromModel(dealershipVehicle.model)) .. " for $" .. dealershipVehicle.price)
                   triggerClientEvent(player, EVENTS.GUI.CLEAR_VEHICLE_SELECTION_WINDOW, player)
               else
                   outputDebugString("[ERROR] Failed to purchase vehicle: " .. tostring(vehicleData.alias))
                   player:outputChat("Failed to purchase vehicle.")
               end
           end)
       else
           outputChatBox("Failed to retrieve vehicle information.", player)
       end
   end)
end


addEvent(EVENTS.VEHICLES.ON_VEHICLE_SELECTED, true)
addEventHandler(EVENTS.VEHICLES.ON_VEHICLE_SELECTED, root, onDealershipVehicleSelected)