function onHouseDatabaseConnected()
    local result = queryAsync("CREATE TABLE IF NOT EXISTS houses (id INT AUTO_INCREMENT PRIMARY KEY, owner int(11), x FLOAT, y FLOAT, z FLOAT, price INT)", function(result)
        if result then
            outputDebugString("[DEBUG] House table creation query executed successfully.")
            triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
        else
            outputDebugString("[DEBUG] House table creation query failed.")
        end
    end)
end

function getHouses(callback)
    queryAsync("SELECT * FROM houses", function(result)
        if not result then
            outputDebugString("[DEBUG] Failed to retrieve houses from the database.")
            callback({})
        else
            callback(result)
        end
    end)
end

function getHouseById(callback, houseId)
    -- correctly call queryAsync with callback first then parameters
    queryAsync("SELECT * FROM houses WHERE id = ?", function(result)
        if not result then
            callback(nil)
            return
        end
        if #result > 0 then
            callback(result[1])
        else
            callback(nil)
        end
    end, houseId)
end

function createHouse(x, y, z, price, callback)
    if not x or not y or not z or not price or tonumber(price) <= 0 then
        outputDebugString("[DEBUG] Invalid parameters for creating house.")
        if callback then callback(false) end
        return
    end
    outputDebugString("[DEBUG] Attempting to create house at (" .. x .. ", " .. y .. ", " .. z .. ") with price $" .. price .. ".")
    local query = "INSERT INTO houses (x,y,z, price) VALUES (?, ?, ?, ?)"
    -- use insertAsync to get the new record ID
    insertAsync(query, function(insertId, rowsAffected)
        if rowsAffected and rowsAffected > 0 then
            addHouseToRadar({ id = insertId, x = x, y = y, z = z, price = price })
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Failed to create house at (" .. x .. ", " .. y .. ", " .. z .. ").")
            if callback then callback(false) end
        end
    end, x, y, z, tonumber(price))
end

function initializeHouses()
    getHouses(function(housesList)
        houses = housesList
        if #houses > 0 then
            updateHouseRadar()
            outputDebugString("[DEBUG] Houses initialized successfully.")
        else
            outputDebugString("[DEBUG] No houses found in the database.")
        end
    end)
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, onHouseDatabaseConnected)
addEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, true)

addEventHandler(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, root, initializeHouses)