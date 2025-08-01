Dealership = {}
Dealership.__index = Dealership

function Dealership:create(data)
    local instance = {}
    setmetatable(instance, Dealership)

    instance.id = data.id or nil
    instance.x = tonumber(data.x) or 0
    instance.y = tonumber(data.y) or 0
    instance.z = tonumber(data.z) or 0
    instance.vehicles = {}
    instance.name = data.name or "Unnamed Dealership"

    -- Visual elements
    instance.marker = nil
    instance.blip = nil
    instance.colShape = nil
    
    return instance
end

function Dealership:save(callback)
    if not self.x or not self.y or not self.z then
        outputDebugString("[DEBUG] Cannot save dealership without valid coordinates.")
        if callback then callback(false) end
        return
    end

    local query = "INSERT INTO dealerships (name, x, y, z) VALUES (?, ?, ?, ?)"
    local params = {self.name, self.x, self.y, self.z}

    insertAsync(query, function(insertId)
        if insertId and insertId > 0 then
            self.id = insertId
            outputDebugString("[DEBUG] Dealership saved with ID: " .. self.id)
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Failed to save dealership.")
            if callback then callback(false) end
        end
    end, unpack(params))
end

function Dealership.initializeDatabase()
    queryAsync("CREATE TABLE IF NOT EXISTS dealerships (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, x FLOAT NOT NULL, y FLOAT NOT NULL, z FLOAT NOT NULL, dimension INT NOT NULL DEFAULT 0)", function(result)
        if result then
            outputDebugString("[DEBUG] Dealership table creation query successful.")
            Dealership.LoadAllDealerships()
        else
            outputDebugString("[DEBUG] Dealership table creation query failed.")
        end
    end)
end

function Dealership.LoadAllDealerships()
    queryAsync("SELECT * FROM dealerships", function(result)
        if result then
            for _, data in ipairs(result) do
                local dealership = Dealership:create(data)
                dealership:createVisuals()
                outputDebugString("[DEBUG] Loaded dealership: " .. dealership.name)
            end
        else
            outputDebugString("[DEBUG] Failed to load dealerships from database.")
        end
    end)
end

function Dealership:createVisuals()
    if self.marker then
        self.marker:destroy()
    end
    if self.blip then
        self.blip:destroy()
    end
    if self.colShape then
        self.colShape:destroy()
    end

    -- Create marker at dealership location
    self.marker = Marker(self.x, self.y, self.z + 1, "arrow", 1.5, 0, 255, 0, 150)
    self.marker:setDimension(0)

    -- Create blip for the dealership
    self.blip = Blip.createAttachedTo(self.marker, 31, 0, 0, 0, 0, 255, 0, 9999)
    self.blip:setDimension(0)

    -- Create colshape for interaction
    self.colShape = ColShape.Sphere(self.x, self.y, self.z, 1.5)
    self.colShape:setDimension(0)

    addEventHandler(EVENTS.ON_COLSHAPE_HIT, self.colShape, function(hitElement)
        if getElementType(hitElement) == "player" then
            bindKey(hitElement, "enter", "up", function()
                hitElement:outputChat("Welcome to " .. self.name .. " Dealership!")
                DealershipVehicle.LoadDealershipVehicles(self.id, function(vehicles)
                    if not vehicles or #vehicles == 0 then
                        hitElement:outputChat("No vehicles available in this dealership.")
                        return
                    end
                    hitElement:setData("currentDealership", self.id)

                    self.vehicles = vehicles
                    triggerClientEvent(hitElement, EVENTS.VEHICLES.OPEN_VEHICLE_SELECTION, hitElement, self.vehicles)
                end)
            end)
        end
    end)

    addEventHandler(EVENTS.ON_COLSHAPE_LEAVE, self.colShape, function(hitElement)
        if getElementType(hitElement) == "player" then
            unbindKey(hitElement, "enter", "up")
        end
    end)
end

function Dealership.getFromId(dealershipId, callback)
    if not dealershipId then
        outputDebugString("[DEBUG] Dealership.getFromId called with nil dealershipId.")
        if callback then callback(nil) end
        return
    end

    local queryString = "SELECT * FROM dealerships WHERE id = ?"
    queryAsync(queryString, function(result)
        if result and result[1] then
            local dealership = Dealership:create(result[1])
            callback(dealership)
        else
            callback(nil)
        end
    end, dealershipId)
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, Dealership.initializeDatabase)
