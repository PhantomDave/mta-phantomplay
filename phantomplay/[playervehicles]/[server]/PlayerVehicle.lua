PlayerVehicle = setmetatable({}, {__index = ServerVehicle})
PlayerVehicle.__index = PlayerVehicle

function PlayerVehicle:new(vehicleData)
    local mappedData = {
        id = vehicleData.id,
        model = vehicleData.model,
        alias = vehicleData.alias,
        owner = vehicleData.owner,
        x = vehicleData.x,
        y = vehicleData.y,
        z = vehicleData.z,
        rx = vehicleData.rx,
        ry = vehicleData.ry,
        rz = vehicleData.rz,
        licensePlate = vehicleData.plate,
        color = vehicleData.color,
        color2 = vehicleData.color2,
        health = vehicleData.health,
        fuelType = vehicleData.fuelType,
        fuelLevel = vehicleData.fuelLevel,
        isLocked = vehicleData.isLocked,
        isEngineOn = vehicleData.isEngineOn
    }
    
    local instance = ServerVehicle.new(self, mappedData)
    
    setmetatable(instance, PlayerVehicle)
    
    instance.lastUsed = vehicleData.lastUsed or getTimestamp()
    instance.mileage = vehicleData.mileage or 0
    instance.insurance = vehicleData.insurance or false
    -- Handle modifications as comma-separated string from database
    if type(vehicleData.modifications) == "string" and vehicleData.modifications ~= "" then
        instance.modifications = {}
        for mod in vehicleData.modifications:gmatch("[^,]+") do
            table.insert(instance.modifications, mod)
        end
    else
        instance.modifications = {}
    end
    instance.lastLocationX = vehicleData.lastLocationX or mappedData.x
    instance.lastLocationY = vehicleData.lastLocationY or mappedData.y
    instance.lastLocationZ = vehicleData.lastLocationZ or mappedData.z
    instance.lastLocationRx = vehicleData.lastLocationRx or mappedData.rx
    instance.lastLocationRy = vehicleData.lastLocationRy or mappedData.ry
    instance.lastLocationRz = vehicleData.lastLocationRz or mappedData.rz
    instance.isImpounded = vehicleData.isImpounded or false
    instance.insuranceExpiry = vehicleData.insuranceExpiry or 0
    instance.vehicle:setData("playerVehicle", instance)
    return instance
end

function PlayerVehicle.initializeDatabase()
    -- Create the player vehicle extensions table
    local createTableQuery = "CREATE TABLE IF NOT EXISTS player_vehicle (" ..
        "vehicle_id INT PRIMARY KEY, " ..
        "FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE, " ..
        "lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " ..
        "mileage FLOAT DEFAULT 0, " ..
        "insurance BOOLEAN DEFAULT FALSE, " ..
        "modifications TEXT, " ..
        "lastLocationX FLOAT, " ..
        "lastLocationY FLOAT, " ..
        "lastLocationZ FLOAT, " ..
        "lastLocationRx FLOAT, " ..
        "lastLocationRy FLOAT, " ..
        "lastLocationRz FLOAT, " ..
        "isImpounded BOOLEAN DEFAULT FALSE, " ..
        "insuranceExpiry TIMESTAMP)"
    
    Database.queryAsync(createTableQuery, function(result)
        if result then
            outputDebugString("[DEBUG] Player vehicle extensions table creation query successful.")
            PlayerVehicle.LoadAllVehicles() 
        else
            outputDebugString("[DEBUG] Player vehicle extensions table creation query failed.")
        end
    end)
end

function PlayerVehicle:insert(callback)
    -- First insert into the base vehicles table using parent method
    ServerVehicle.insert(self, function(vehicleId)
        if vehicleId then
            self.id = vehicleId
            
            -- Then insert player-specific data into extensions table
            local extensionQuery = "INSERT INTO player_vehicle (vehicle_id, lastUsed, mileage, insurance, modifications, lastLocationX, lastLocationY, lastLocationZ, lastLocationRx, lastLocationRy, lastLocationRz, isImpounded, insuranceExpiry) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            
            Database.insertAsync(extensionQuery, function(result)
                if result then
                    outputDebugString("[DEBUG] Player vehicle extension inserted successfully for vehicle ID: " .. tostring(vehicleId))
                    if callback then callback(vehicleId) end
                else
                    outputDebugString("[ERROR] Failed to insert player vehicle extension for vehicle ID: " .. tostring(vehicleId))
                    -- Rollback: delete the base vehicle record
                    ServerVehicle.delete(vehicleId)
                    if callback then callback(nil) end
                end
            end,
            vehicleId,
            self.lastUsed or getTimestamp(),
            self.mileage or 0,
            self.insurance or false,
            table.concat(self.modifications or {}, ","),
            self.lastLocationX,
            self.lastLocationY,
            self.lastLocationZ,
            self.lastLocationRx,
            self.lastLocationRy,
            self.lastLocationRz,
            self.isImpounded or false,
            self.insuranceExpiry or 0)
        else
            outputDebugString("[ERROR] Failed to insert base vehicle record")
            if callback then callback(nil) end
        end
    end)
end

function PlayerVehicle:ownedByPlayer(player)
    if not player or not isElement(player) or getElementType(player) ~= "player" then
        outputDebugString("[ERROR] Invalid player element provided to PlayerVehicle:ownedByPlayer")
        return false
    end
    
    local character = Character.getFromPlayer(player)
    if not character then
        outputDebugString("[ERROR] Character not found for player: " .. getPlayerName(player))
        return false
    end
    return self.owner == character.id
end

function PlayerVehicle:update(callback)
    -- First update the base vehicle data using parent method
    ServerVehicle.update(self, function(success)
        if success then
            -- Then update player-specific data in extensions table
            local extensionQuery = "UPDATE player_vehicle SET lastUsed = ?, mileage = ?, insurance = ?, modifications = ?, lastLocationX = ?, lastLocationY = ?, lastLocationZ = ?, lastLocationRx = ?, lastLocationRy = ?, lastLocationRz = ?, isImpounded = ?, insuranceExpiry = ? WHERE vehicle_id = ?"
            
            Database.executeAsync(extensionQuery, function(affectedRows)
                if affectedRows > 0 then
                    outputDebugString("[DEBUG] Player vehicle extension updated successfully (ID: " .. tostring(self.id) .. ")")
                    if callback then callback(true) end
                else
                    outputDebugString("[ERROR] Failed to update player vehicle extension or extension not found (ID: " .. tostring(self.id) .. ")")
                    if callback then callback(false) end
                end
            end,
            self.lastUsed,
            self.mileage,
            self.insurance,
            table.concat(self.modifications or {}, ","),
            self.lastLocationX,
            self.lastLocationY,
            self.lastLocationZ,
            self.lastLocationRx,
            self.lastLocationRy,
            self.lastLocationRz,
            self.isImpounded,
            self.insuranceExpiry,
            self.id)
        else
            outputDebugString("[ERROR] Failed to update base vehicle data (ID: " .. tostring(self.id) .. ")")
            if callback then callback(false) end
        end
    end)
end

-- Static method to get all player vehicles
function PlayerVehicle.getAll(callback)
    local query = "SELECT v.*, pve.lastUsed, pve.mileage, pve.insurance, pve.modifications, pve.lastLocationX, pve.lastLocationY, pve.lastLocationZ, pve.lastLocationRx, pve.lastLocationRy, pve.lastLocationRz, pve.isImpounded, pve.insuranceExpiry FROM vehicles v INNER JOIN player_vehicle pve ON v.id = pve.vehicle_id"
    
    Database.queryAsync(query, function(result, numRows)
        if result then
            outputDebugString("[DEBUG] Retrieved " .. tostring(numRows or 0) .. " player vehicles from database")
            if callback then callback(result) end
        else
            outputDebugString("[ERROR] Failed to retrieve player vehicles from database")
            if callback then callback({}) end
        end
    end)
end

-- Static method to get player vehicles by owner
function PlayerVehicle.getAllByOwner(ownerId, callback)
    local query = "SELECT v.*, pve.lastUsed, pve.mileage, pve.insurance, pve.modifications, pve.lastLocationX, pve.lastLocationY, pve.lastLocationZ, pve.lastLocationRx, pve.lastLocationRy, pve.lastLocationRz, pve.isImpounded, pve.insuranceExpiry FROM vehicles v INNER JOIN player_vehicle pve ON v.id = pve.vehicle_id WHERE v.owner = ?"
    
    Database.queryAsync(query, function(result, numRows)
        if result then
            outputDebugString("[DEBUG] Found " .. tostring(numRows or 0) .. " player vehicles for owner ID: " .. tostring(ownerId))
            if callback then callback(result) end
        else
            outputDebugString("[ERROR] Failed to retrieve player vehicles for owner ID: " .. tostring(ownerId))
            if callback then callback({}) end
        end
    end, ownerId)
end

-- Static method to get a player vehicle by ID
function PlayerVehicle.getById(vehicleId, callback)
    local query = "SELECT v.*, pve.lastUsed, pve.mileage, pve.insurance, pve.modifications, pve.lastLocationX, pve.lastLocationY, pve.lastLocationZ, pve.lastLocationRx, pve.lastLocationRy, pve.lastLocationRz, pve.isImpounded, pve.insuranceExpiry FROM vehicles v INNER JOIN player_vehicle pve ON v.id = pve.vehicle_id WHERE v.id = ?"
    
    Database.queryAsync(query, function(result)
        if result and #result > 0 then
            outputDebugString("[DEBUG] Player vehicle found (ID: " .. tostring(vehicleId) .. ")")
            if callback then callback(result[1]) end
        else
            outputDebugString("[DEBUG] Player vehicle not found (ID: " .. tostring(vehicleId) .. ")")
            if callback then callback(nil) end
        end
    end, vehicleId)
end

function PlayerVehicle.getFromVehicle(vehicle)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        outputDebugString("[ERROR] Invalid vehicle element provided to PlayerVehicle.getFromVehicle")
        return nil
    end

    local playerVehicle = vehicle:getData("playerVehicle")
    if playerVehicle then
        setmetatable(playerVehicle, PlayerVehicle)
    end
    return playerVehicle
end

function PlayerVehicle.createFromData(vehicleData)
    return PlayerVehicle:new(vehicleData)
end

-- Static method to delete a player vehicle
function PlayerVehicle.delete(vehicleId, callback)
    -- Delete from extensions table first (due to foreign key constraint)
    local extensionQuery = "DELETE FROM player_vehicle WHERE vehicle_id = ?"
    
    Database.executeAsync(extensionQuery, function(affectedRows)
        if affectedRows > 0 then
            -- Then delete from base vehicles table
            ServerVehicle.delete(vehicleId, function(success)
                if success then
                    outputDebugString("[DEBUG] Player vehicle deleted successfully (ID: " .. tostring(vehicleId) .. ")")
                    if callback then callback(true) end
                else
                    outputDebugString("[ERROR] Failed to delete base vehicle record (ID: " .. tostring(vehicleId) .. ")")
                    if callback then callback(false) end
                end
            end)
        else
            outputDebugString("[ERROR] Failed to delete player vehicle extension or vehicle not found (ID: " .. tostring(vehicleId) .. ")")
            if callback then callback(false) end
        end
    end, vehicleId)
end

-- Load all player vehicles
function PlayerVehicle.LoadAllVehicles()
    PlayerVehicle.getAll(function(vehicleList)
        local playerVehicles = vehicleList or {}

        -- Create visuals for all player vehicles
        for _, vehicleData in ipairs(playerVehicles) do
            local veh = PlayerVehicle:new(vehicleData)
        end

        outputDebugString("[DEBUG] Loaded " .. #playerVehicles .. " player vehicles from database.")
    end)
end

-- Player-specific methods

-- Update last used timestamp
function PlayerVehicle:updateLastUsed()
    self.lastUsed = getTimestamp()
end

-- Add mileage
function PlayerVehicle:addMileage(distance)
    self.mileage = self.mileage + (distance or 0)
end

-- Check if insurance is valid
function PlayerVehicle:hasValidInsurance()
    return self.insurance and (self.insuranceExpiry > os.time())
end

-- Set last location
function PlayerVehicle:setLastLocation(x, y, z, rx, ry, rz)
    self.lastLocationX = x
    self.lastLocationY = y
    self.lastLocationZ = z
    self.lastLocationRx = rx
    self.lastLocationRy = ry
    self.lastLocationRz = rz
end

-- Get last location
function PlayerVehicle:getLastLocation()
    if self.lastLocationX and self.lastLocationY and self.lastLocationZ then
        return self.lastLocationX, self.lastLocationY, self.lastLocationZ, self.lastLocationRx, self.lastLocationRy, self.lastLocationRz
    end
    return nil, nil, nil, nil, nil, nil
end

-- Impound vehicle
function PlayerVehicle:impound()
    self.isImpounded = true
    if self.vehicle and isElement(self.vehicle) then
        self.vehicle:destroy()
        self.vehicle = nil
    end
end

-- Release from impound
function PlayerVehicle:releaseFromImpound()
    self.isImpounded = false
    -- Recreate the vehicle
    self.vehicle = Vehicle(self.model, self.position.x, self.position.y, self.position.z)
    local color1 = StringUtils.split(self.color, ",")
    local color2 = StringUtils.split(self.color2, ",")
    self.vehicle:setColor(tonumber(color1[1]), tonumber(color1[2]), tonumber(color1[3]),
                             tonumber(color2[1]), tonumber(color2[2]), tonumber(color2[3]))
    self.vehicle:setPlateText(self.licensePlate)
    self.vehicle:setHealth(self.health)
    self.vehicle:setEngineState(self.isEngineOn)
    self.vehicle:setLocked(self.isLocked)
    self.vehicle:spawn(self.position.x, self.position.y, self.position.z, 
                       self.rotation.x, self.rotation.y, self.rotation.z)
    self:attachEventHandlers()
end

-- Override attachEventHandlers to add player-specific functionality
function PlayerVehicle:attachEventHandlers()
    -- Call parent event handlers first
    ServerVehicle.attachEventHandlers(self)
    
    -- Add player-specific event handlers
    addEventHandler("onVehicleEnter", self.vehicle, function(player, seat, jacked)
        if seat == 0 then
            self:updateLastUsed()
        end
    end)
    
    addEventHandler("onVehicleExit", self.vehicle, function(player, seat, jacked)
        if self:getType() == "player" and seat == 0 then
            local x, y, z = getElementPosition(self.vehicle)
            local rx, ry, rz = getElementRotation(self.vehicle)
            self:setLastLocation(x, y, z, rx, ry, rz)
            self:update()
        end
    end)
end

-- Override getType method
function PlayerVehicle:getType()
    return "player"
end

-- Initialize player vehicle system when database is connected
addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, PlayerVehicle.initializeDatabase)
