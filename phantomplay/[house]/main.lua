-- House management using House OOP class
local houses = {}

-- Initialize houses when the house database is connected
function initializeHouses()
    House.getAll(function(houseList)
        houses = houseList or {}
        
        -- Create visuals for all houses
        for _, house in ipairs(houses) do
            house:createVisuals()
        end
        
        outputDebugString("[DEBUG] Loaded " .. #houses .. " houses from database.")
    end)
end

-- Command to buy a house
function buyHouseCommand(player)
    -- Find the nearest house to the player
    local px, py, pz = getElementPosition(player)
    local nearestHouse = nil
    local minDistance = math.huge
    
    for _, house in ipairs(houses) do
        local distance = getDistanceBetweenPoints3D(px, py, pz, house.x, house.y, house.z)
        if distance < 5 and distance < minDistance then
            minDistance = distance
            nearestHouse = house
        end
    end
    
    if nearestHouse then
        if nearestHouse:isOwned() then
            outputChatBox("This house is already owned.", player)
        else
            nearestHouse:sellTo(player, function(success)
                if success then
                    -- Refresh the house list
                    initializeHouses()
                end
            end)
        end
    else
        outputChatBox("You are not near any house for sale.", player)
    end
end

-- Command to create a house (admin only)
function createHouseCommand(player, x, y, z, price)
    -- Check if player is admin
    local account = Account.getFromPlayer(player)
    if not account or not account:isAdmin() then
        outputChatBox("You don't have permission to use this command.", player)
        return
    end
    
    if not x or not y or not z or not price then
        outputChatBox("Usage: /createhouse <x> <y> <z> <price>", player)
        return
    end
    
    x, y, z, price = tonumber(x), tonumber(y), tonumber(z), tonumber(price)
    if not x or not y or not z or not price or price <= 0 then
        outputChatBox("Invalid parameters. All coordinates and price must be valid numbers.", player)
        return
    end
    
    House.createNew(x, y, z, price, function(house)
        if house then
            house:createVisuals()
            table.insert(houses, house)
            outputChatBox("House created successfully at (" .. x .. ", " .. y .. ", " .. z .. ") for $" .. price, player)
        else
            outputChatBox("Failed to create house.", player)
        end
    end)
end

-- Register commands
addCommandHandler("buyhouse", buyHouseCommand)
addCommandHandler("createhouse", createHouseCommand)

-- Initialize houses when database is ready
addEventHandler(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, root, initializeHouses)
