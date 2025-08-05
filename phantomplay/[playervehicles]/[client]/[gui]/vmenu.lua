local vehicles = {}

function createVehicleMenu()
    wdwVmenu = GuiWindow(32, 245, 281, 404, "Vehicle Menu", false)
    wdwVmenu:setSizable(false)

    wdwGridList = GuiGridList(10, (404 - 363) / 2, 262, 363, false, wdwVmenu)
    wdwGridList:addColumn("Name", 0.5)
    wdwGridList:addColumn("Distance", 0.5)
    wdwGridList:addRow()
    wdwGridList:setItemText(0, 1, "Sultan (Current)", false, false)
    wdwGridList:setItemText(0, 2, "0m", false, false)
    wdwGridList:setItemColor(0, 2, 84, 254, 0, 255)

    -- Add event handlers for double-click and Enter key
    addEventHandler(EVENTS.GUI.ON_GUI_DOUBLE_CLICK, wdwGridList, onVehicleRowSelect)
    addEventHandler(EVENTS.GUI.ON_GUI_KEY_DOWN, wdwGridList, onVehicleRowSelect)
end


function onOpenVehicleMenu(vehiclesTable)

    if not vehiclesTable or #vehiclesTable == 0 then
        outputChatBox("You have no vehicles.", 255, 0, 0)
        return
    end

    if not wdwVmenu then
        createVehicleMenu()
    end

    guiGridListClear(wdwGridList)
    vehicles = {} -- Clear the vehicles table
    
    for _, vehicle in ipairs(vehiclesTable) do
        local row = wdwGridList:addRow()
        wdwGridList:setItemText(row, 1, vehicle.name, false, false)
        wdwGridList:setItemText(row, 2, vehicle.distance .. "m", false, false)
        wdwGridList:setItemColor(row, 2, 84, 254, 0, 255)
        iprint("Adding vehicle: " .. vehicle.name .. " at distance: " .. vehicle.distance .. "at row: " .. row)
        table.insert(vehicles, {
            row = row,
            id = vehicle.id,
            name = vehicle.name,
            distance = vehicle.distance,
            vehicle = vehicle.vehicle
        })
    end
    wdwVmenu:setVisible(true)
    showCursor(true)
end


addEvent(EVENTS.VEHICLES.ON_VEHICLE_MENU_OPENED, true)
addEventHandler(EVENTS.VEHICLES.ON_VEHICLE_MENU_OPENED, root, onOpenVehicleMenu)

function onVehicleRowSelect(button, state, absoluteX, absoluteY)
    if button == "left" or button == "enter" and state == "up" then
        local selectedRow = wdwGridList:getSelectedItem()
        iprint("Selected row: " .. tostring(selectedRow))
        if selectedRow and selectedRow ~= -1 then
            -- selectedRow is 0-based, but vehicles table is 1-based (using table.insert)
            local vehicleIndex = selectedRow + 1
            if vehicles[vehicleIndex] then
                iprint(vehicles[vehicleIndex])
                wdwVmenu:setVisible(false)
                openVehicleActionsMenu(vehicles[vehicleIndex].vehicle)
            else
                iprint("No vehicle found at index: " .. vehicleIndex)
            end
        end

    elseif key == "escape" and press then
        wdwVmenu:setVisible(false)
        showCursor(false)
    end
end
