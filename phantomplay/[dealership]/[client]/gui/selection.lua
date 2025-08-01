function createDealershipSelectionWindow()
	local sWidth, sHeight = guiGetScreenSize()

    local Width,Height = 376,259
	local X = (sWidth/2) - (Width/2)
	local Y = (sHeight/2) - (Height/2)

    wdwVehSelection = guiCreateWindow(X, Y, Width, Height, "Buy a vehicle", false)

    gridListVehicles = guiCreateGridList(0.05, 0.1, 0.9, 0.7, true, wdwVehSelection)
    guiGridListAddColumn(gridListVehicles, "Vehicle name", 0.65)
    guiGridListAddColumn(gridListVehicles, "Price", 0.3)

    local btnSelect = guiCreateButton(0.55, 0.85, 0.4, 0.1, "Select Vehicle", true, wdwVehSelection)

    addEventHandler(EVENTS.GUI.ON_GUI_CLICK, btnSelect, OnSelectVehicle, false)
end

function OnSelectVehicle(button, state)
    if button == "left" and state == "up" then
        local selectedRow = guiGridListGetSelectedItem(gridListVehicles)
        if selectedRow ~= -1 then
            local vehicleName = guiGridListGetItemText(gridListVehicles, selectedRow, 1)
            outputChatBox("You have selected vehicle: " .. vehicleName)
            triggerServerEvent(EVENTS.VEHICLES.ON_VEHICLE_SELECTED, localPlayer, localPlayer:getData("currentDealership"), Vehicles[selectedRow+1].id)
        else
            outputChatBox("Please select a vehicle first.")
        end
    end
end


addEvent(EVENTS.VEHICLES.OPEN_VEHICLE_SELECTION, true)
addEventHandler(EVENTS.VEHICLES.OPEN_VEHICLE_SELECTION, localPlayer, 
    function (vehicles)
        if not wdwVehSelection then
            createDealershipSelectionWindow()
        end

        guiGridListClear(gridListVehicles)

        if vehicles and isTableNotEmpty(vehicles) then
            Vehicles = vehicles or {}
            for _, veh in ipairs(Vehicles) do
                local row = guiGridListAddRow(gridListVehicles)
                guiGridListSetItemText(gridListVehicles, row, 1, Vehicle.getNameFromModel(veh.model), false, false)
                guiGridListSetItemText(gridListVehicles, row, 2, tostring("$" .. veh.price), false, false)
            end
        end

    guiSetVisible(wdwVehSelection, true)
    showCursor(true)
        guiSetInputEnabled(true)
    end
)

addEvent(EVENTS.GUI.CLEAR_VEHICLE_SELECTION_WINDOW, true)
addEventHandler(EVENTS.GUI.CLEAR_VEHICLE_SELECTION_WINDOW, localPlayer,
    function ()
        if wdwVehSelection then
            guiSetVisible(wdwVehSelection, false)
            showCursor(false)
            guiSetInputEnabled(false)
        end
    end
)