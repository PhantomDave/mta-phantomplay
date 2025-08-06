addEvent(EVENTS.VEHICLES.ON_PLAYER_TOGGLE_ENGINE, true)
addEvent(EVENTS.VEHICLES.ON_PLAYER_TOGGLE_LOCK, true)
addEvent(EVENTS.VEHICLES.ON_PLAYER_REFUEL_VEHICLE, true)
addEvent(EVENTS.VEHICLES.ON_VEHICLE_ACTIONS_MENU_OPENED, true)

addEventHandler(EVENTS.VEHICLES.ON_PLAYER_TOGGLE_ENGINE, root, function(vehicle)
    local playerVehicle = PlayerVehicle.getFromVehicle(vehicle)
    if playerVehicle then
        playerVehicle:toggleEngine(source)
    end
end)

addEventHandler(EVENTS.VEHICLES.ON_PLAYER_TOGGLE_LOCK, root, function(vehicle)
    local playerVehicle = PlayerVehicle.getFromVehicle(vehicle)
    if playerVehicle then
        playerVehicle:toggleLock(source)
    end
end)

addEventHandler(EVENTS.VEHICLES.ON_PLAYER_REFUEL_VEHICLE, root, function(vehicle)
    local playerVehicle = PlayerVehicle.getFromVehicle(vehicle)
    if playerVehicle then
        playerVehicle:refuel(source)
    end
end)
