DealershipVehicle = {}
DealershipVehicle.__index = DealershipVehicle


function DealershipVehicle:initializeDatabase()
    local createTableQuery = "CREATE TABLE IF NOT EXISTS dealership_vehicles (" ..
        "id INT AUTO_INCREMENT PRIMARY KEY, " ..
        "dealership_id INT NOT NULL, " ..
        "FOREIGN KEY (dealership_id) REFERENCES dealerships(id), " ..
        "model INT NOT NULL, " ..
        "x FLOAT NOT NULL, " ..
        "y FLOAT NOT NULL, " ..
        "z FLOAT NOT NULL, " ..
        "a FLOAT NOT NULL, " ..
        "price INT NOT NULL)"
    
    queryAsync(createTableQuery, function(result)
        if result then
            outputDebugString("[DEBUG] Dealership vehicle table creation query successful.")
        else
            outputDebugString("[DEBUG] Dealership vehicle table creation query failed.")
        end
    end)
end

function DealershipVehicle.LoadDealershipVehicles(dealershipId, callback)
    if not dealershipId then
        outputDebugString("[DEBUG] DealershipVehicle.LoadDealershipVehicles called with nil dealershipId.")
        return {}
    end

    local queryString = "SELECT * FROM dealership_vehicles WHERE dealership_id = ?"
    local vehicles = {}

    queryAsync(queryString, function(result)
        if result and #result > 0 then
            for _, data in ipairs(result) do
                table.insert(vehicles, DealershipVehicle:create(data))
            end
        else
            outputDebugString("[DEBUG] No vehicles found for dealership ID: " .. tostring(dealershipId))
        end
        if callback then callback(vehicles) end
    end, dealershipId)

    return vehicles
end

function DealershipVehicle:create(data)
    local instance = {}
    setmetatable(instance, DealershipVehicle)

    instance.id = data.id or nil
    instance.x = tonumber(data.x) or 0
    instance.y = tonumber(data.y) or 0
    instance.z = tonumber(data.z) or 0
    instance.a = tonumber(data.a) or 0
    instance.model = data.model or 0
    instance.price = tonumber(data.price) or 0
    instance.dealershipId = data.dealershipId or nil

    -- Visual elements
    instance.marker = nil
    instance.blip = nil
    instance.colShape = nil

    return instance
end

function DealershipVehicle:save(callback)
    if not self.x or not self.y or not self.z or not self.model then
        outputDebugString("[DEBUG] Cannot save vehicle without valid coordinates and model.")
        if callback then callback(false) end
        return
    end

    local query = "INSERT INTO dealership_vehicles (dealership_id, model, x, y, z, a, price) VALUES (?, ?, ?, ?, ?, ?, ?)"
    local params = {self.dealershipId, self.model, self.x, self.y, self.z, self.a, self.price}

    insertAsync(query, function(insertId)
        if insertId and insertId > 0 then
            self.id = insertId
            outputDebugString("[DEBUG] Vehicle saved with ID: " .. self.id)
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Failed to save vehicle.")
            if callback then callback(false) end
        end
    end, unpack(params))
end

function DealershipVehicle.getFromId(vehicleId, dealershipId, callback)
    if not vehicleId or not dealershipId then
        outputDebugString("[DEBUG] DealershipVehicle.getFromId called with nil vehicleId or dealershipId.")
        if callback then callback(nil) end
        return
    end

    local queryString = "SELECT * FROM dealership_vehicles WHERE id = ? AND dealership_id = ?"
    
    queryAsync(queryString, function(result)
        if result and #result > 0 then
            if callback then callback(DealershipVehicle:create(result[1])) end
        else
            outputDebugString("[DEBUG] No vehicle found with ID: " .. tostring(vehicleId) .. " in dealership ID: " .. tostring(dealershipId))
            if callback then callback(nil) end
        end
    end, vehicleId, dealershipId)
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, DealershipVehicle.initializeDatabase)
