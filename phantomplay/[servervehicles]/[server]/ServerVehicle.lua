ServerVehicle = {}
ServerVehicle.__index = ServerVehicle


function ServerVehicle.initializeDatabase()
    local createTableQuery = "CREATE TABLE IF NOT EXISTS vehicles (" ..
        "id INT AUTO_INCREMENT PRIMARY KEY, " ..
        "owner INT, " ..
        "FOREIGN KEY (owner) REFERENCES characters(id), " ..
        "x FLOAT NOT NULL, " ..
        "y FLOAT NOT NULL, " ..
        "z FLOAT NOT NULL, " ..
        "rx FLOAT NOT NULL, " ..
        "ry FLOAT NOT NULL, " ..
        "rz FLOAT NOT NULL, " ..
        "plate VARCHAR(10), " ..
        "color VARCHAR(20) NOT NULL, " ..
        "color2 VARCHAR(20) NOT NULL, " ..
        "fuelType VARCHAR(20) NOT NULL, " ..
        "fuelLevel FLOAT NOT NULL, " ..
        "isLocked BOOLEAN NOT NULL, " ..
        "isEngineOn BOOLEAN NOT NULL, " ..
        "model INT NOT NULL, " ..
        "alias VARCHAR(50) NOT NULL, " ..
        "health FLOAT NOT NULL)"
    
    Database.queryAsync(createTableQuery, function(result)
        if result then
            outputDebugString("[DEBUG] Vehicle table creation query successful.")
            ServerVehicle.LoadAllVehicles()
        else
            outputDebugString("[DEBUG] Vehicle table creation query failed.")
        end
    end)
end

function ServerVehicle:insert(callback)
    local query = "INSERT INTO vehicles (" ..
        "owner, x, y, z, rx, ry, rz, plate, color, color2, " ..
        "fuelType, fuelLevel, isLocked, isEngineOn, model, alias, health" ..
        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
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
    (self.isLocked or false) and 1 or 0,
    (self.isEngineOn or false) and 1 or 0,
    self.model or 400,
    self.alias or "",
    self.health or 1000)
end

function ServerVehicle:park(x,y,z,rx,ry,rz,callback)
    if not self.vehicle then
        outputDebugString("[ERROR] Cannot park vehicle, vehicle object is nil")
        if callback then callback(false) end
        return
    end

    local query = "UPDATE vehicles SET " ..
            "x = ?, y = ?, z = ?, rx = ?, ry = ?, rz = ? " ..
            "WHERE id = ?"
        
        Database.executeAsync(query, function(affectedRows)
            outputDebugString("[DEBUG] Update query affected " .. tostring(affectedRows) .. " rows")
            if affectedRows > 0 then
                self.position.x = x
                self.position.y = y
                self.position.z = z
                self.rotation.x = rx
                self.rotation.y = ry
                self.rotation.z = rz
                if callback then callback(true) end
            else
                outputDebugString("[ERROR] Failed to update vehicle or vehicle not found (ID: " .. 
                    tostring(self.id) .. ")")
                if callback then callback(false) end
            end
        end,
        x,
        y,
        z,
        rx,
        ry,
        rz,
        self.id)
end

-- Update an existing vehicle in the database
function ServerVehicle:update(callback)
    local query = "UPDATE vehicles SET " ..
        "owner = ?, " ..
        "plate = ?, color = ?, color2 = ?, fuelType = ?, fuelLevel = ?, " ..
        "isLocked = ?, isEngineOn = ?, model = ?, alias = ?, health = ? " ..
        "WHERE id = ?"
    
    Database.executeAsync(query, function(affectedRows)
        if affectedRows >= 0 then
            if callback then callback(true) end
        else
            outputDebugString("[ERROR] Failed to update vehicle or vehicle not found (ID: " .. 
                tostring(self.id) .. ")")
            if callback then callback(false) end
        end
    end,
    self.owner,
    self.plate,
    self.color,
    self.color2,
    self.fuelType,
    self.fuelLevel,
    self.isLocked and 1 or 0,
    self.isEngineOn and 1 or 0,
    self.model,
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

function ServerVehicle.getAllByOwner(ownerId, callback)
    local query = "SELECT * FROM vehicles WHERE owner = ?"
    
    Database.queryAsync(query, function(result, numRows)
        if result then
            outputDebugString("[DEBUG] Found " .. tostring(numRows or 0) .. 
                " vehicles for owner ID: " .. tostring(ownerId))
            if callback then callback(result) end
        else
            outputDebugString("[ERROR] Failed to retrieve vehicles for owner ID: " .. 
                tostring(ownerId))
            if callback then callback({}) end
        end
    end, ownerId)
end

function ServerVehicle.getAll(callback)
    local query = "SELECT * FROM vehicles WHERE owner IS NULL"

    Database.queryAsync(query, function(result, numRows)
        if result then
            outputDebugString("[DEBUG] Retrieved " .. tostring(numRows or 0) .. 
                " server vehicles from database")
            if callback then callback(result) end
        else
            outputDebugString("[ERROR] Failed to retrieve server vehicles from database")
            if callback then callback({}) end
        end
    end)
end

function ServerVehicle.delete(vehicleId, callback)
    local query = "DELETE FROM vehicles WHERE id = ?"
    
    Database.executeAsync(query, function(affectedRows)
        if affectedRows > 0 then
            outputDebugString("[DEBUG] Vehicle deleted successfully (ID: " .. 
                tostring(vehicleId) .. ")")
            if callback then callback(true) end
        else
            outputDebugString("[ERROR] Failed to delete vehicle or vehicle not found (ID: " .. 
                tostring(vehicleId) .. ")")
            if callback then callback(false) end
        end
    end, vehicleId)
end

function ServerVehicle.LoadAllVehicles()
    ServerVehicle.getAll(function(vehicleList)
        vehicles = vehicleList or {}

        -- Create visuals for all vehicles
        for _, vehicleData in ipairs(vehicles) do
            local veh = ServerVehicle:new(vehicleData)
        end

        outputDebugString("[DEBUG] Loaded " .. #vehicles .. " vehicles from database.")
    end)
end

function ServerVehicle:attachEventHandlers()
    addEventHandler("onVehicleEnter", self.vehicle, function(player, seat, jacked)
        if seat ~= 0 then return end
        
        self.vehicle:setEngineState(self.isEngineOn)
        
        bindKey(player, "k", "up", function()
            local character = Character.getFromPlayer(player)
            
            if not character then return end

            if(self.owner ~= character.id) then
                outputChatBox("You do not own this vehicle.", player)
                return
            end
            self.isEngineOn = not self.isEngineOn
            self.vehicle:setEngineState(self.isEngineOn)
            outputChatBox("Engine " .. (self.isEngineOn and "started" or "stopped"), player)
        end)

        bindKey(player, "l", "up", function()
            local character = Character.getFromPlayer(player)
            
            if not character then return end

            if(self.owner ~= character.id) then
                outputChatBox("You do not own this vehicle.", player)
                return
            end
            self.isLocked = not self.isLocked
            self.vehicle:setLocked(self.isLocked)
            outputChatBox("Vehicle " .. (self.isLocked and "locked" or "unlocked"), player)
        end)

        bindKey(player, "2", "up", function()
            local character = Character.getFromPlayer(player)
            
            if not character then return end
            self.lights = self.lights == 1 and 2 or 1
            self.vehicle:setOverrideLights(self.lights)
        end)
    end)

    addEventHandler("onVehicleExit", self.vehicle, function(player, seat, jacked)
        self.vehicle:setEngineState(self.isEngineOn)
        unbindKey(player, "k", "up")
        unbindKey(player, "2", "up")
        unbindKey(player, "l", "up")
        if self.getType() == "server" then
            self:update()
        end
    end)
end

function ServerVehicle:getType()
    return "server"
end


function ServerVehicle:new(vehicleData)
    local instance = setmetatable({}, self)

    instance.id = vehicleData.id or 0
    instance.model = vehicleData.model
    instance.alias = vehicleData.alias or Vehicle.getNameFromModel(vehicleData.model)
    instance.owner = vehicleData.owner or 0
    instance.position = { 
        x = vehicleData.x or 0, 
        y = vehicleData.y or 0, 
        z = vehicleData.z or 0 
    }
    instance.rotation = { 
        x = vehicleData.rx or 0, 
        y = vehicleData.ry or 0, 
        z = vehicleData.rz or 0 
    }
    instance.color = vehicleData.color or ColorUtils.getRandomColor()
    instance.color2 = vehicleData.color2 or ColorUtils.getRandomColor()
    instance.plate = vehicleData.plate or "UNKNOWN"
    instance.health = vehicleData.health or 1000
    instance.fuelType = vehicleData.fuelType or "petrol"
    instance.fuelLevel = vehicleData.fuelLevel or 100
    -- Convert numeric boolean values from database to actual booleans
    instance.isLocked = (vehicleData.isLocked == 1 or vehicleData.isLocked == true) and 
        true or false
    instance.isEngineOn = (vehicleData.isEngineOn == 1 or vehicleData.isEngineOn == true) and 
        true or false
    instance.vehicle = Vehicle(vehicleData.model, instance.position.x, 
        instance.position.y, instance.position.z)
    local color1 = StringUtils.split(instance.color, ",")
    local color2 = StringUtils.split(instance.color2, ",")
    instance.vehicle:setColor(tonumber(color1[1]), tonumber(color1[2]), tonumber(color1[3]),
        tonumber(color2[1]), tonumber(color2[2]), tonumber(color2[3]))
    instance.vehicle:setPlateText(instance.plate)
    instance.vehicle:setHealth(instance.health)
    instance.vehicle:setEngineState(instance.isEngineOn)
    instance.vehicle:setLocked(instance.isLocked)
    instance.vehicle:spawn(instance.position.x, instance.position.y, instance.position.z, 
        instance.rotation.x, instance.rotation.y, instance.rotation.z)
    instance:attachEventHandlers()
    instance.vehicle:setData("serverVehicle", instance)
    return instance
end


addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, ServerVehicle.initializeDatabase)
