
function onHouseDatabaseConnected()
    local result = query("CREATE TABLE IF NOT EXISTS houses (id INT AUTO_INCREMENT PRIMARY KEY, owner int(11), x FLOAT, y FLOAT, z FLOAT, price INT)")
    if result then
        outputDebugString("[DEBUG] House table creation query executed successfully.")
        triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
    else
        outputDebugString("[DEBUG] House table creation query failed.")
    end
end

function getHouses()
    local result = query("SELECT * FROM houses")
    if result then
        return result
    else
        outputDebugString("[DEBUG] Failed to retrieve houses from the database.")
        return {}
    end
end

function getHouseById(houseId)
    local result = query("SELECT * FROM houses WHERE id = ?", houseId)
    if result and #result > 0 then
        return result[1]
    else
        outputDebugString("[DEBUG] No house found with ID: " .. tostring(houseId))
        return nil
    end
end

function createHouse(x, y, z, price)
    if not x or not y or not z or not price or tonumber(price) <= 0 then
        outputDebugString("[DEBUG] Invalid parameters for creating house.")
        return false
    end

    local query = string.format("INSERT INTO houses (x,y,z, price) VALUES (%f, %f, %f, %d)", x, y, z, tonumber(price))
    local result = execute(query)

    if result then
        outputDebugString("[DEBUG] House created successfully at (" .. x .. ", " .. y .. ", " .. z .. ") for $" .. price .. ".")
        table.insert(houses, { location = { x = x, y = y, z = z }, price = price })
        return true
    else
        outputDebugString("[DEBUG] Failed to create house at (" .. x .. ", " .. y .. ", " .. z .. ").")
        return false
    end
end

function initializeHouses()
    houses = getHouses()
    if #houses > 0 then
        updateHouseRadar()
        outputDebugString("[DEBUG] Houses initialized successfully.")
    else
        outputDebugString("[DEBUG] No houses found in the database.")
    end
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, onHouseDatabaseConnected)
addEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, true)

addEventHandler(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, root, initializeHouses)