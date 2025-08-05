-- Vehicle Actions Menu
local wdwVehicleActions = nil
local btnGridList = nil
local currentVehicle = nil

-- Define vehicle actions
local vehicleActions = {
    {name = "Open/Close Doors", action = "doors", icon = "🚪"},
    {name = "Open/Close Bonnet", action = "bonnet", icon = "🔧"},
    {name = "Open/Close Trunk", action = "trunk", icon = "📦"},
    {name = "Turn Engine On/Off", action = "engine", icon = "🔑"},
    {name = "Toggle Lights", action = "lights", icon = "💡"},
    {name = "Lock/Unlock Vehicle", action = "lock", icon = "🔒"},
    {name = "Sound Horn", action = "horn", icon = "📯"},
    {name = "Toggle Siren", action = "siren", icon = "🚨"},
    {name = "Repair Vehicle", action = "repair", icon = "🔨"},
    {name = "Flip Vehicle", action = "flip", icon = "🔄"},
    {name = "Refuel Vehicle", action = "refuel", icon = "⛽"},
    {name = "Wash Vehicle", action = "wash", icon = "🧽"}
}

function createVehicleActionsMenu()
    wdwVehicleActions = GuiWindow(350, 200, 320, 450, "Vehicle Actions", false)
    wdwVehicleActions:setSizable(false)
    
    -- Create grid list for actions
    btnGridList = GuiGridList(10, 30, 300, 380, false, wdwVehicleActions)
    btnGridList:addColumn("Action", 0.7)
    btnGridList:addColumn("Status", 0.3)
    
    -- Add close button
    local btnClose = GuiButton(10, 415, 100, 25, "Close", false, wdwVehicleActions)
    
    -- Add refresh button
    local btnRefresh = GuiButton(120, 415, 100, 25, "Refresh", false, wdwVehicleActions)
    
    -- Populate actions
    populateVehicleActions()
    
    -- Add event handlers
    addEventHandler("onClientGUIDoubleClick", btnGridList, onVehicleActionDoubleClick)
    addEventHandler("onClientGUIKeyDown", btnGridList, onVehicleActionKeyDown)
    addEventHandler("onClientGUIClick", btnClose, onCloseVehicleActions)
    addEventHandler("onClientGUIClick", btnRefresh, onRefreshVehicleActions)
    
    wdwVehicleActions:setVisible(false)
end

function populateVehicleActions()
    if not btnGridList then return end
    
    guiGridListClear(btnGridList)
    
    for i, action in ipairs(vehicleActions) do
        local row = btnGridList:addRow()
        btnGridList:setItemText(row, 1, action.icon .. " " .. action.name, false, false)
        
        -- Get current status for the action
        local status = getVehicleActionStatus(action.action)
        btnGridList:setItemText(row, 2, status, false, false)
        
        -- Color code based on status
        if status == "ON" or status == "OPEN" or status == "LOCKED" then
            btnGridList:setItemColor(row, 2, 0, 255, 0, 255) -- Green
        elseif status == "OFF" or status == "CLOSED" or status == "UNLOCKED" then
            btnGridList:setItemColor(row, 2, 255, 100, 100, 255) -- Light red
        else
            btnGridList:setItemColor(row, 2, 200, 200, 200, 255) -- Gray
        end
    end
end

function getVehicleActionStatus(action)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then 
        vehicle = currentVehicle
    end
    
    if not vehicle then return "N/A" end
    
    local status = "N/A"
    
    if action == "doors" then
        -- Check if any door is open
        local anyDoorOpen = false
        for i = 0, 5 do
            if getVehicleDoorOpenRatio(vehicle, i) > 0 then
                anyDoorOpen = true
                break
            end
        end
        status = anyDoorOpen and "OPEN" or "CLOSED"
        
    elseif action == "bonnet" then
        status = getVehicleDoorOpenRatio(vehicle, 0) > 0 and "OPEN" or "CLOSED"
        
    elseif action == "trunk" then
        status = getVehicleDoorOpenRatio(vehicle, 1) > 0 and "OPEN" or "CLOSED"
        
    elseif action == "engine" then
        status = getVehicleEngineState(vehicle) and "ON" or "OFF"
        
    elseif action == "lights" then
        status = getVehicleOverrideLights(vehicle) == 2 and "ON" or "OFF"
        
    elseif action == "lock" then
        status = isVehicleLocked(vehicle) and "LOCKED" or "UNLOCKED"
        
    elseif action == "siren" then
        status = getVehicleSirensOn(vehicle) and "ON" or "OFF"
        
    else
        status = "READY"
    end
    
    return status
end

function onVehicleActionDoubleClick(button, state, absoluteX, absoluteY)
    if button == "left" and state == "up" then
        executeSelectedAction()
    end
end

function onVehicleActionKeyDown(key, press)
    if key == "enter" and press then
        executeSelectedAction()
    elseif key == "escape" and press then
        closeVehicleActionsMenu()
    end
end

function executeSelectedAction()
    local selectedRow = btnGridList:getSelectedItem()
    if selectedRow and selectedRow ~= -1 then
        local actionData = vehicleActions[selectedRow + 1]
        if actionData then
            performVehicleAction(actionData.action, actionData.name)
        end
    end
end

function performVehicleAction(action, actionName)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then 
        vehicle = currentVehicle
    end
    
    if not vehicle then
        outputChatBox("No vehicle available for this action!", 255, 0, 0)
        return
    end
    
    -- Check if player is close enough to vehicle (if not inside)
    if not getPedOccupiedVehicle(localPlayer) then
        local px, py, pz = getElementPosition(localPlayer)
        local vx, vy, vz = getElementPosition(vehicle)
        local distance = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
        
        if distance > 10 then
            outputChatBox("You are too far from the vehicle!", 255, 0, 0)
            return
        end
    end
    
    if action == "doors" then
        -- Toggle all doors
        local allClosed = true
        for i = 2, 5 do -- Skip bonnet (0) and trunk (1)
            if getVehicleDoorOpenRatio(vehicle, i) > 0 then
                allClosed = false
                break
            end
        end
        
        for i = 2, 5 do
            setVehicleDoorOpenRatio(vehicle, i, allClosed and 1 or 0, 1000)
        end
        outputChatBox("Vehicle doors " .. (allClosed and "opened" or "closed"), 0, 255, 0)
        
    elseif action == "bonnet" then
        local isOpen = getVehicleDoorOpenRatio(vehicle, 0) > 0
        setVehicleDoorOpenRatio(vehicle, 0, isOpen and 0 or 1, 1000)
        outputChatBox("Vehicle bonnet " .. (isOpen and "closed" or "opened"), 0, 255, 0)
        
    elseif action == "trunk" then
        local isOpen = getVehicleDoorOpenRatio(vehicle, 1) > 0
        setVehicleDoorOpenRatio(vehicle, 1, isOpen and 0 or 1, 1000)
        outputChatBox("Vehicle trunk " .. (isOpen and "closed" or "opened"), 0, 255, 0)
        
    elseif action == "engine" then
        local engineState = getVehicleEngineState(vehicle)
        setVehicleEngineState(vehicle, not engineState)
        outputChatBox("Vehicle engine " .. (engineState and "turned off" or "turned on"), 0, 255, 0)
        
    elseif action == "lights" then
        local currentLights = getVehicleOverrideLights(vehicle)
        setVehicleOverrideLights(vehicle, currentLights == 2 and 1 or 2)
        outputChatBox("Vehicle lights " .. (currentLights == 2 and "turned off" or "turned on"), 0, 255, 0)
        
    elseif action == "lock" then
        local isLocked = isVehicleLocked(vehicle)
        setVehicleLocked(vehicle, not isLocked)
        outputChatBox("Vehicle " .. (isLocked and "unlocked" or "locked"), 0, 255, 0)
        
    elseif action == "horn" then
        -- Trigger horn sound (you might need to use server events for this)
        outputChatBox("Horn sounded!", 0, 255, 0)
        -- triggerServerEvent("onPlayerUseHorn", localPlayer, vehicle)
        
    elseif action == "siren" then
        local sirenState = getVehicleSirensOn(vehicle)
        setVehicleSirensOn(vehicle, not sirenState)
        outputChatBox("Vehicle siren " .. (sirenState and "turned off" or "turned on"), 0, 255, 0)
        
    elseif action == "repair" then
        fixVehicle(vehicle)
        outputChatBox("Vehicle repaired!", 0, 255, 0)
        
    elseif action == "flip" then
        local x, y, z = getElementPosition(vehicle)
        setElementPosition(vehicle, x, y, z + 2)
        setElementRotation(vehicle, 0, 0, getElementRotation(vehicle))
        outputChatBox("Vehicle flipped!", 0, 255, 0)
        
    elseif action == "refuel" then
        -- This would typically be handled server-side
        outputChatBox("Refueling vehicle... (Feature needs server implementation)", 255, 255, 0)
        -- triggerServerEvent("onPlayerRefuelVehicle", localPlayer, vehicle)
        
    elseif action == "wash" then
        -- This would typically be handled server-side
        outputChatBox("Washing vehicle... (Feature needs server implementation)", 255, 255, 0)
        -- triggerServerEvent("onPlayerWashVehicle", localPlayer, vehicle)
    end
    
    -- Refresh the action list to update statuses
    setTimer(populateVehicleActions, 500, 1)
end

function onCloseVehicleActions()
    closeVehicleActionsMenu()
end

function onRefreshVehicleActions()
    populateVehicleActions()
    outputChatBox("Vehicle actions refreshed!", 0, 255, 0)
end

function openVehicleActionsMenu(vehicle)
    if not wdwVehicleActions then
        createVehicleActionsMenu()
    end
    
    currentVehicle = vehicle
    populateVehicleActions()
    wdwVehicleActions:setVisible(true)
    showCursor(true)
end

function closeVehicleActionsMenu()
    if wdwVehicleActions then
        wdwVehicleActions:setVisible(false)
        showCursor(false)
        currentVehicle = nil
    end
end

-- Event handlers for opening the actions menu
addEvent(EVENTS.VEHICLES.ON_VEHICLE_ACTIONS_MENU_OPENED, true)
addEventHandler(EVENTS.VEHICLES.ON_VEHICLE_ACTIONS_MENU_OPENED, root, openVehicleActionsMenu)

-- Initialize the menu when the script loads
addEventHandler("onClientResourceStart", resourceRoot, function()
    createVehicleActionsMenu()
end)
