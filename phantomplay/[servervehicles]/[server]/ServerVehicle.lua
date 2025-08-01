ServerVehicle = {}
ServerVehicle.__index = ServerVehicle


function ServerVehicle.initializeDatabase()
    Database.queryAsync("CREATE TABLE IF NOT EXISTS vehicles (id INT AUTO_INCREMENT PRIMARY KEY, owner INT, FOREIGN KEY (owner) REFERENCES characters(id), x FLOAT NOT NULL, y FLOAT NOT NULL, z FLOAT NOT NULL, rx FLOAT NOT NULL, ry FLOAT NOT NULL, rz FLOAT NOT NULL, plate VARCHAR(10) NOT NULL, color VARCHAR(20) NOT NULL, color2 VARCHAR(20) NOT NULL, fuelType VARCHAR(20) NOT NULL, fuelLevel FLOAT NOT NULL, isLocked BOOLEAN NOT NULL, isEngineOn BOOLEAN NOT NULL, model INT, locked BOOLEAN NOT NULL, engineOn BOOLEAN NOT NULL, fuel FLOAT NOT NULL, alias VARCHAR(50) NOT NULL, health FLOAT NOT NULL)", function(result)
        if result then
            outputDebugString("[DEBUG] Vehicle table creation query successful.")
            ServerVehicle.LoadAllVehicles()
        else
            outputDebugString("[DEBUG] Vehicle table creation query failed.")
        end
    end)
end

function ServerVehicle:insert(callback)
    local query = "INSERT INTO vehicles (owner, x, y, z, rx, ry, rz, plate, color, color2, fuelType, fuelLevel, isLocked, isEngineOn, model, locked, engineOn, fuel, alias, health) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    Database.insertAsync(query, function(insertId)
        if insertId then
            outputDebugString("[DEBUG] Vehicle inserted successfully with ID: " .. tostring(insertId))
            if callback then callback(insertId) end
        else
            outputDebugString("[ERROR] Failed to insert vehicle")
            if callback then callback(nil) end
        end
    end,
    self.owner or 0,
    self.position.x or 0,
    self.position.y or 0,
    self.position.z or 0,
    self.rotation.x or 0,
    self.rotation.y or 0,
    self.rotation.z or 0,
    self.plate or "UNKNOWN",
    self.color or "255,255,255",
    self.color2 or "255,255,255",
    self.fuelType or "petrol",
    self.fuelLevel or 100,
    self.isLocked or false,
    self.isEngineOn or false,
    self.model or 400,
    self.locked or false,
    self.engineOn or false,
    self.fuel or 100,
    self.alias or "",
    self.health or 1000)
end

-- Update an existing vehicle in the database
function ServerVehicle:update(callback)
    local query = "UPDATE vehicles SET owner = ?, x = ?, y = ?, z = ?, rx = ?, ry = ?, rz = ?, plate = ?, color = ?, color2 = ?, fuelType = ?, fuelLevel = ?, isLocked = ?, isEngineOn = ?, model = ?, locked = ?, engineOn = ?, fuel = ?, alias = ?, health = ? WHERE id = ?"
    
    Database.executeAsync(query, function(affectedRows)
        if affectedRows > 0 then
            outputDebugString("[DEBUG] Vehicle updated successfully (ID: " .. tostring(self.id) .. ")")
            if callback then callback(true) end
        else
            outputDebugString("[ERROR] Failed to update vehicle or vehicle not found (ID: " .. tostring(self.id) .. ")")
            if callback then callback(false) end
        end
    end,
    self.owner,
    self.x,
    self.y,
    self.z,
    self.rx,
    self.ry,
    self.rz,
    self.plate,
    self.color,
    self.color2,
    self.fuelType,
    self.fuelLevel,
    self.isLocked,
    self.isEngineOn,
    self.model,
    self.locked,
    self.engineOn,
    self.fuel,
    self.alias,
    self.health,
    self.id)
end

-- Get a vehicle by its ID
function ServerVehicle.getById(vehicleId, callback)
    local query = "SELECT * FROM vehicles WHERE id = ?"
    
    Database.queryAsync(query, function(result)
        if result and #result > 0 then
            outputDebugString("[DEBUG] Vehicle found (ID: " .. tostring(vehicleId) .. ")")
            if callback then callback(result[1]) end
        else
            outputDebugString("[DEBUG] Vehicle not found (ID: " .. tostring(vehicleId) .. ")")
            if callback then callback(nil) end
        end
    end, vehicleId)
end

-- Get all vehicles owned by a specific owner
function ServerVehicle.getAllByOwner(ownerId, callback)
    local query = "SELECT * FROM vehicles WHERE owner = ?"
    
    Database.queryAsync(query, function(result, numRows)
        if result then
            outputDebugString("[DEBUG] Found " .. tostring(numRows or 0) .. " vehicles for owner ID: " .. tostring(ownerId))
            if callback then callback(result) end
        else
            outputDebugString("[ERROR] Failed to retrieve vehicles for owner ID: " .. tostring(ownerId))
            if callback then callback({}) end
        end
    end, ownerId)
end

function ServerVehicle.getAll(callback)
    local query = "SELECT * FROM vehicles"
    
    Database.queryAsync(query, function(result, numRows)
        if result then
            outputDebugString("[DEBUG] Retrieved " .. tostring(numRows or 0) .. " vehicles from database")
            if callback then callback(result) end
        else
            outputDebugString("[ERROR] Failed to retrieve vehicles from database")
            if callback then callback({}) end
        end
    end)
end

function ServerVehicle.delete(vehicleId, callback)
    local query = "DELETE FROM vehicles WHERE id = ?"
    
    Database.executeAsync(query, function(affectedRows)
        if affectedRows > 0 then
            outputDebugString("[DEBUG] Vehicle deleted successfully (ID: " .. tostring(vehicleId) .. ")")
            if callback then callback(true) end
        else
            outputDebugString("[ERROR] Failed to delete vehicle or vehicle not found (ID: " .. tostring(vehicleId) .. ")")
            if callback then callback(false) end
        end
    end, vehicleId)
end

function ServerVehicle.LoadAllVehicles()
    ServerVehicle.getAll(function(vehicleList)
        vehicles = vehicleList or {}

        -- Create visuals for all vehicles
        for _, vehicleData in ipairs(vehicles) do
            ServerVehicle:new(vehicleData)
        end

        outputDebugString("[DEBUG] Loaded " .. #vehicles .. " vehicles from database.")
    end)
end


function ServerVehicle:new(vehicleData)
    local instance = setmetatable({}, self)

    instance.id = vehicleData.id or 0
    instance.model = vehicleData.model
    instance.alias = vehicleData.alias or Vehicle.getNameFromModel(vehicleData.model)
    instance.owner = vehicleData.owner or 0
    instance.position = { x = vehicleData.x or 0, y = vehicleData.y or 0, z = vehicleData.z or 0 }
    instance.rotation = { x = vehicleData.rx or 0, y = vehicleData.ry or 0, z = vehicleData.rz or 0 }
    instance.color = vehicleData.color or { r = 255, g = 255, b = 255 }
    instance.color2 = vehicleData.color2 or { r = 255, g = 255, b = 255 }
    instance.licensePlate = vehicleData.licensePlate or "UNKNOWN"
    instance.health = vehicleData.health or 1000
    instance.fuelType = vehicleData.fuelType or "petrol"
    instance.fuelLevel = vehicleData.fuelLevel or 100
    -- Convert numeric boolean values from database to actual booleans
    instance.isLocked = (vehicleData.isLocked == 1 or vehicleData.isLocked == true) and true or false
    instance.isEngineOn = (vehicleData.isEngineOn == 1 or vehicleData.isEngineOn == true) and true or false
    instance.vehicle = Vehicle(vehicleData.model, instance.position.x, instance.position.y, instance.position.z)
    instance.vehicle:setColor(instance.color.r, instance.color.g, instance.color.b,
                                 instance.color2.r, instance.color2.g, instance.color2.b)
    instance.vehicle:setPlateText(instance.licensePlate)
    instance.vehicle:setHealth(instance.health)
    instance.vehicle:setEngineState(instance.isEngineOn)
    instance.vehicle:setLocked(instance.isLocked)
    instance.vehicle:spawn(instance.position.x, instance.position.y, instance.position.z, 
                           instance.rotation.x, instance.rotation.y, instance.rotation.z)

    
    
    return instance
end


addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, ServerVehicle.initializeDatabase)
