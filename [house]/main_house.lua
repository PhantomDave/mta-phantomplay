houses = {}

function updateHouseRadar()
    for _, house in ipairs(houses) do

        if house.marker then
            destroyElement(house.marker)
            house.marker = nil
            destroyElement(house.blip)
            house.blip = nil
            destroyElement(house.colShape)
            house.colShape = nil
        end

        house.marker = createMarker(house.x, house.y, house.z + 1, "arrow", 1.5, 255, 255, 255, 150)
        setElementDimension(house.marker, 0)
        setElementInterior(house.marker, 0)
        house.blip = createBlipAttachedTo(house.marker, 31, 0, 0, 0, 0, 255, 0, 9999)
        setElementDimension(house.blip, 0)
        house.colShape = createColSphere(house.x, house.y, house.z, 1.5)
        setElementDimension(house.colShape, 0)

        addEventHandler(EVENTS.ON_COLSHAPE_HIT, house.colShape, function(hitElement)
            if getElementType(hitElement) == "player" then
                bindKey(hitElement, "enter", "down", function()
                    if house then
                        outputChatBox("You are near a house at (" .. house.x .. ", " .. house.y .. ", " .. house.z .. "). Price: $" .. house.price, hitElement)
                    else
                        outputChatBox("No house found at this location.", hitElement, 255, 0, 0)
                    end
                end)
            end
        end)

        addEventHandler(EVENTS.ON_COLSHAPE_LEAVE, house.colShape, function(leaveElement)
            if getElementType(leaveElement) == "player" then
                unbindKey(leaveElement, "enter", "down")
            end
        end)

    end

    outputDebugString("[DEBUG] House radar updated with " .. #houses .. " houses.")
end

function addHouseToRadar(house)
    house.marker = createMarker(house.x, house.y, house.z + 1, "arrow", 1.5, 255, 255, 255, 150)
    setElementDimension(house.marker, 0)
    setElementInterior(house.marker, 0)
    house.blip = createBlipAttachedTo(house.marker, 31, 0, 0, 0, 0, 255, 0, 9999)
    setElementDimension(house.blip, 0)
    house.colShape = createColSphere(house.x, house.y, house.z, 1.5)
    setElementDimension(house.colShape, 0)

    addEventHandler(EVENTS.ON_COLSHAPE_HIT, house.colShape, function(hitElement)
        if getElementType(hitElement) == "player" then
            bindKey(hitElement, "enter", "down", function()
                if house then
                    outputChatBox("You are near a house at (" .. house.x .. ", " .. house.y .. ", " .. house.z .. "). Price: $" .. house.price, hitElement)
                else
                    outputChatBox("No house found at this location.", hitElement, 255, 0, 0)
                end
            end)
        end
    end)

    addEventHandler(EVENTS.ON_COLSHAPE_LEAVE, house.colShape, function(leaveElement)
        if getElementType(leaveElement) == "player" then
            unbindKey(leaveElement, "enter", "down")
        end
    end)
    
    table.insert(houses, house)
    outputDebugString("[DEBUG] House created (ID: " .. tostring(insertId) .. ") at (" .. x .. ", " .. y .. ", " .. z .. ") for $" .. price .. ".")
    outputDebugString("[DEBUG] Total houses in radar: " .. #houses)

end