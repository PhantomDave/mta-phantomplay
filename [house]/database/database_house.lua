function onHouseDatabaseConnected()
    executeAsync(
        function(affectedRows, error)
            if error then
                outputDebugString("[DEBUG] House table creation query failed: " .. tostring(error))
            else
                outputDebugString("[DEBUG] House table creation query executed successfully.")
                triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
            end
        end,
        nil,
        "CREATE TABLE IF NOT EXISTS houses (id INT AUTO_INCREMENT PRIMARY KEY, owner int(11), x FLOAT, y FLOAT, z FLOAT, price INT)"
    )
end


function getHouses(callback)
    queryAsync(
        function(result, numRows, error)
            if error then
                outputDebugString("[DEBUG] Failed to retrieve houses from the database: " .. tostring(error))
                callback({})
            else
                callback(result)
            end
        end,
        nil,
        "SELECT * FROM houses"
    )
end


function getHouseById(houseId, callback)
    queryAsync(
        function(result, numRows, error)
            if error or not result or #result == 0 then
                outputDebugString("[DEBUG] No house found with ID: " .. tostring(houseId))
                callback(nil)
            else
                callback(result[1])
            end
        end,
        nil,
        "SELECT * FROM houses WHERE id = ?",
        houseId
    )
end


function createHouse(x, y, z, price, callback)
    if not x or not y or not z or not price or tonumber(price) <= 0 then
        outputDebugString("[DEBUG] Invalid parameters for creating house.")
        if callback then callback(false) end
        return
    end

    local query = string.format("INSERT INTO houses (x,y,z, price) VALUES (%f, %f, %f, %d)", x, y, z, tonumber(price))
    executeAsync(
        function(affectedRows, error)
            if error then
                outputDebugString("[DEBUG] Failed to create house at (" .. x .. ", " .. y .. ", " .. z .. "). Error: " .. tostring(error))
                if callback then callback(false) end
            else
                outputDebugString("[DEBUG] House created successfully at (" .. x .. ", " .. y .. ", " .. z .. ") for $" .. price .. ".")
                if callback then callback(true) end
            end
        end,
        nil,
        query
    )
end


function initializeHouses()
    createHouse(0,0,0 , 0, function(result)
        outputDebugString("[DEBUG] Creating.....")
        if result then
            outputDebugString("[DEBUG] Default house created successfully.")
        else
            outputDebugString("[DEBUG] Failed to create default house.")
        end
    end)

    getHouses(function(houses)
        if houses and #houses > 0 then
            _G.houses = houses
            updateHouseRadar()
            outputDebugString("[DEBUG] Houses initialized successfully.")
        else
            _G.houses = {}
            outputDebugString("[DEBUG] No houses found in the database.")
        end
    end)
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, onHouseDatabaseConnected)
addEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, true)

addEventHandler(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, root, initializeHouses)