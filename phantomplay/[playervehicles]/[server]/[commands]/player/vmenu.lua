function openVehicleMenu(player, commandname)
    if not player or not isElement(player) then
        return
    end

    local character = Character.getFromPlayer(player)

    PlayerVehicle.getAllByOwner(character.id, function(vehicles)
        if not vehicles or #vehicles == 0 then
            outputChatBox("You have no vehicles.", player, 255, 0, 0)
            return
        end
        local vmenuItems = {}
        for _, vehicle in ipairs(vehicles) do
            local veh = {}
            veh.name = vehicle.alias
            veh.distance = math.floor(getDistanceBetweenPoints3D(player:getPosition(), vehicle.vehicle:getPosition()))
            veh.id = vehicle.id
            veh.vehicle = vehicle.vehicle
            table.insert(vmenuItems, veh)
        end
        triggerClientEvent(player, EVENTS.VEHICLES.ON_VEHICLE_MENU_OPENED, player, vmenuItems)
    end)
end


addCommandHandler("vmenu", openVehicleMenu)