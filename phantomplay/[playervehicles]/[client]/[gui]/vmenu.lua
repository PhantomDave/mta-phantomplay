

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

end


function onOpenVehicleMenu(vehicles)

    if not vehicles or #vehicles == 0 then
        outputChatBox("You have no vehicles.", 255, 0, 0)
        return
    end

    if not wdwVmenu then
        createVehicleMenu()
    end

    guiGridListClear(wdwGridList)
    
    for _, vehicle in ipairs(vehicles) do
        local row = wdwGridList:addRow()
        wdwGridList:setItemText(row, 1, vehicle.name, false, false)
        wdwGridList:setItemText(row, 2, vehicle.distance .. "m", false, false)
        wdwGridList:setItemColor(row, 2, 84, 254, 0, 255)
    end
    wdwVmenu:setVisible(true)
    showCursor(true)
end


addEvent(EVENTS.VEHICLES.ON_VEHICLE_MENU_OPENED, true)
addEventHandler(EVENTS.VEHICLES.ON_VEHICLE_MENU_OPENED, root, onOpenVehicleMenu)
