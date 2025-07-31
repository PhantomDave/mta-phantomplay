-- House management using House OOP class
local houses = {}

-- Initialize houses when the house database is connected


-- Command to buy a house
-- function buyHouseCommand(player)
--     -- Find the nearest house to the player
--     local px, py, pz = getElementPosition(player)
--     local nearestHouse = nil
--     local minDistance = math.huge
    
--     for _, house in ipairs(houses) do
--         local distance = getDistanceBetweenPoints3D(px, py, pz, house.x, house.y, house.z)
--         if distance < 5 and distance < minDistance then
--             minDistance = distance
--             nearestHouse = house
--         end
--     end
    
--     if nearestHouse then
--         if nearestHouse:isOwned() then
--             outputChatBox("This house is already owned.", player)
--         else
--             nearestHouse:sellTo(player, function(success)
--                 if success then
--                     -- Refresh the house list
--                     initializeHouses()
--                 end
--             end)
--         end
--     else
--         outputChatBox("You are not near any house for sale.", player)
--     end
-- end

-- Command to create a house (admin only)

-- Initialize houses when database is ready
