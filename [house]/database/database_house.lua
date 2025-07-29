function onHouseDatabaseConnected()
    local result = query("CREATE TABLE IF NOT EXISTS houses (id INT AUTO_INCREMENT PRIMARY KEY, owner int(11), x FLOAT, y FLOAT, z FLOAT, price INT)")
    if result then
        outputDebugString("[DEBUG] House table creation query executed successfully.")
        triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
        createHouse(0, 0, 0, 560)
    else
        outputDebugString("[DEBUG] House table creation query failed.")
    end
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

function createHouse(x, y, z, price)
    if not x or not y or not z or not price or tonumber(price) <= 0 then
        outputDebugString("[DEBUG] Invalid parameters for creating house.")
        return false
    end
    outputDebugString("[DEBUG] Attempting to create house at (" .. x .. ", " .. y .. ", " .. z .. ") with price $" .. price .. ".")
    local query = string.format("INSERT INTO houses (x,y,z, price) VALUES (%f, %f, %f, %d)", x, y, z, tonumber(price))
    -- use insertAsync to get the new record ID
    insertAsync(query, function(insertId, rowsAffected)
        if rowsAffected and rowsAffected > 0 then
            addHouseToRadar({ id = insertId, x = x, y = y, z = z, price = price })
        else
            outputDebugString("[DEBUG] Failed to create house at (" .. x .. ", " .. y .. ", " .. z .. ").")
        end
    end)
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