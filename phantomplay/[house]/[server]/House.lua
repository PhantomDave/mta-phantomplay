House = {}
House.__index = House

-- Constructor
function House:create(data)
    local instance = {}
    setmetatable(instance, House)
    
    -- Initialize properties with safety checks
    instance.id = data.id or nil
    instance.owner = data.owner or nil
    instance.ownerName = data.owner_name or nil  -- New field for owner name from JOIN
    instance.x = tonumber(data.x) or 0
    instance.y = tonumber(data.y) or 0
    instance.z = tonumber(data.z) or 0
    instance.price = tonumber(data.price) or 50000  -- Ensure price is always a number
    instance.interior = tonumber(data.interior) or 0
    instance.dimension = tonumber(data.dimension) or 0
    
    -- Visual elements
    instance.marker = nil
    instance.blip = nil
    instance.colShape = nil
    
    return instance
end

-- Static method to initialize database
function House.initializeDatabase()
    queryAsync("CREATE TABLE IF NOT EXISTS houses (id INT AUTO_INCREMENT PRIMARY KEY, owner INT, FOREIGN KEY (owner) REFERENCES characters(id), x FLOAT NOT NULL, y FLOAT NOT NULL, z FLOAT NOT NULL, price INT NOT NULL DEFAULT 50000, interior INT NOT NULL DEFAULT 0)", function(result)
        if result then
            outputDebugString("[DEBUG] House table creation query successful.")
            House.LoadAllHouses()
        else
            outputDebugString("[DEBUG] House table creation query failed.")
        end
    end)
end

function House.LoadAllHouses()
    House.getAll(function(houseList)
        houses = houseList or {}
        
        -- Create visuals for all houses
        for _, house in ipairs(houses) do
            house:createVisuals()
        end
        
        outputDebugString("[DEBUG] Loaded " .. #houses .. " houses from database.")
    end)
end

-- Static method to get all houses
function House.getAll(callback)
    local query = [[
        SELECT h.id, h.owner, h.x, h.y, h.z, h.price, h.interior, c.name as owner_name
        FROM houses h
        LEFT JOIN characters c ON h.owner = c.id
    ]]
    
    queryAsync(query, function(result)
        if result and #result > 0 then
            local houses = {}
            for _, houseData in ipairs(result) do
                table.insert(houses, House:create(houseData))
            end
            callback(houses)
        else
            outputDebugString("[DEBUG] No houses found in database.")
            callback({})
        end
    end)
end

-- Static method to get house by ID
function House.getById(houseId, callback)
    if not houseId then
        outputDebugString("[DEBUG] House.getById called with nil houseId.")
        if callback then callback(nil) end
        return
    end
    
    local query = [[
        SELECT h.id, h.owner, h.x, h.y, h.z, h.price, h.interior, c.name as owner_name
        FROM houses h
        LEFT JOIN characters c ON h.owner = c.id
        WHERE h.id = ?
    ]]
    
    queryAsync(query, function(result)
        if result and result[1] then
            local house = House:create(result[1])
            callback(house)
        else
            callback(nil)
        end
    end, houseId)
end

-- Static method to create new house
function House.createNew(x, y, z, price, callback)
    outputDebugString("[DEBUG] House.createNew called with parameters: x=" .. tostring(x) .. ", y=" .. tostring(y) .. ", z=" .. tostring(z) .. ", price=" .. tostring(price))
    if not x or not y or not z or not price or tonumber(price) <= 0 then
        outputDebugString("[DEBUG] House.createNew called with invalid parameters.")
        if callback then callback(nil) end
        return
    end
    
    outputDebugString("[DEBUG] Attempting to create house at (" .. x .. ", " .. y .. ", " .. z .. ") with price $" .. price .. ".")
    local query = "INSERT INTO houses (x, y, z, price, interior) VALUES (?, ?, ?, ?, ?)"
    
    local randomInterior = getRandomInterior()
    local interiorId = randomInterior and randomInterior.id or 1 -- Default to interior ID 1 if random fails
    
    insertAsync(query, function(insertId)
        if insertId and insertId > 0 then
            -- Get the newly created house
            House.getById(insertId, callback)
        else
            outputDebugString("[DEBUG] Failed to create house.")
            if callback then callback(nil) end
        end
    end, x, y, z, price, interiorId)
end

-- Instance method to save house data
function House:save(callback)
    if not self.id then
        outputDebugString("[DEBUG] Cannot save house without ID.")
        if callback then callback(false) end
        return
    end
    
    local queryString = "UPDATE houses SET owner = ?, x = ?, y = ?, z = ?, price = ? WHERE id = ?"
    queryAsync(queryString, function(result)
        if result then
            outputDebugString("[DEBUG] House updated successfully: ID " .. self.id)
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] House update failed: ID " .. self.id)
            if callback then callback(false) end
        end
    end, self.owner, self.x, self.y, self.z, self.price, self.id)
end

-- Instance method to create visual elements
function House:createVisuals()
    self:destroyVisuals()

    local pickupId = self.owner and 1272 or 1273
    self.pickup = Pickup(self.x, self.y, self.z, 3, pickupId, 1)
    self.pickup:setDimension(0)
    
    self.blip = Blip.createAttachedTo(self.pickup, 31, 0, 0, 0, 0, 255, 0, 9999)
    self.blip:setDimension(0)
    self.blip:setVisibleDistance(200)
    local icon = self.owner and 32 or 31
    self.blip:setIcon(icon)

    self.colShape = ColShape.Sphere(self.x, self.y, self.z, 1.5)
    self.colShape:setDimension(0)

    local interior = getInteriorByID(self.interior)
    if interior then
        self.interiorMarker = Marker(interior.x, interior.y, interior.z + 1, "arrow", 1.5, 255, 255, 255, 150)
        self.interiorMarker:setDimension(self.id)
        self.interiorMarker:setInterior(interior.interior)

        self.interiorColShape = ColShape.Sphere(interior.x, interior.y, interior.z, 2.0)
        self.interiorColShape:setDimension(self.id)
        self.interiorColShape:setInterior(interior.interior)
        
    end

    self.textDisplay = TextDisplay.create()

    local ownerDisplay = self.ownerName or "Nobody"
    local text = "House ID: " .. (self.id) .. "\nPrice: $" .. (self.price or 0) .. "\nOwner: " .. ownerDisplay .. "\n\nPress ALT to buy the house"

    self.textItem = TextItem.create(text, 0.5, 0.5, "medium", 0, 255, 0, 150, 2, "left", "left", 255)
    textDisplayAddText(self.textDisplay, self.textItem)


    addEventHandler(EVENTS.ON_COLSHAPE_HIT, self.interiorColShape, function(hitElement)
        if getElementType(hitElement) == "player" then
            bindKey(hitElement, "enter", "up", function()
                self:onPlayerExit(Character.getFromPlayer(hitElement))
            end)
        end
    end)

    addEventHandler(EVENTS.ON_COLSHAPE_LEAVE, self.interiorColShape, function(leaveElement)
        if getElementType(leaveElement) == "player" then
            unbindKey(leaveElement, "enter", "up")
        end
    end)

    addEventHandler(EVENTS.ON_COLSHAPE_HIT, self.colShape, function(hitElement)
        if getElementType(hitElement) == "player" then
            textDisplayAddObserver(self.textDisplay, hitElement)
            bindKey(hitElement, "lalt", "down", function()
                textDisplayRemoveObserver(self.textDisplay, hitElement)
                buyHouseFunction(hitElement, self)
                textDisplayAddObserver(self.textDisplay, hitElement)
            end)
            bindKey(hitElement, "enter", "up", function()
                self:onPlayerEnter(Character.getFromPlayer(hitElement))
            end)
        end
    end)
    
    addEventHandler(EVENTS.ON_COLSHAPE_LEAVE, self.colShape, function(leaveElement)
        if getElementType(leaveElement) == "player" then
            textDisplayRemoveObserver(self.textDisplay, leaveElement)
            unbindKey(leaveElement, "lalt", "down")
            unbindKey(leaveElement, "enter", "up")
        end
    end)
end

-- Instance method to destroy visual elements
function House:destroyVisuals()
    if self.pickup and isElement(self.pickup) then
        destroyElement(self.pickup)
        self.pickup = nil
    end
    
    if self.blip and isElement(self.blip) then
        destroyElement(self.blip)
        self.blip = nil
    end
    
    if self.colShape and isElement(self.colShape) then
        destroyElement(self.colShape)
        self.colShape = nil
    end
end

function House:setOwner(character)
    
    character:takeBankMoney(self.price)
    
    self.owner = character.id
    self.ownerName = character.name  -- Set the owner name directly
    self:save()
    self:createVisuals()
    outputDebugString("[DEBUG] House ID " .. self.id .. " ownership set to player ID " .. character.id)
    return true
end

-- Instance method called when player enters house area
function House:onPlayerEnter(character)
    if self.owner and self.owner == character.id then
        local interior = getInteriorByID(self.interior)
        if interior then
            outputChatBox("Interior: " .. interior.name, character.player)
            local player = character.player
            setElementPosition(player, interior.x, interior.y, interior.z)
            setElementInterior(player, interior.interior)
            setElementDimension(player, self.id)
        else
            outputChatBox("Interior ID: " .. (self.interior or 0), character.player)
        end
    else
        local priceDisplay = self.price or 0
        outputChatBox("House for sale at (" .. self.x .. ", " .. self.y .. ", " .. self.z .. "). Price: $" .. priceDisplay, character.player)
    end
end

function House:onPlayerExit(character)
    if self.owner and self.owner == character.id then
        local interior = getInteriorByID(self.interior)
        if interior then
            outputChatBox("Interior: " .. interior.name, character.player)
            local player = character.player
            setElementPosition(player, self.x, self.y, self.z)
            setElementInterior(player, 0)
            setElementDimension(player, 0)
        else
            outputChatBox("Interior ID: " .. (self.interior or 0), character.player)
        end
    else
        local priceDisplay = self.price or 0
        outputChatBox("House for sale at (" .. self.x .. ", " .. self.y .. ", " .. self.z .. "). Price: $" .. priceDisplay, character.player)
    end
end

-- Instance method to sell house to player
function House:sellTo(player, callback)
    local character = Character.getFromPlayer(player)
    if not character then
        outputChatBox("You must have a character to buy a house.", player)
        if callback then callback(false) end
        return
    end
    
    if character.cash < self.price then
        outputChatBox("You don't have enough money to buy this house. Required: $" .. self.price, player)
        if callback then callback(false) end
        return
    end
    
    -- Take money from character
    character:takeCash(self.price)
    
    -- Set owner
    self.owner = character.id
    self.ownerName = character.name  -- Set the owner name directly
    
    -- Save house
    self:save(function(success)
        if success then
            outputChatBox("Congratulations! You bought the house for $" .. self.price, player)
            character:save() -- Save character money
            self:createVisuals() -- Recreate visuals with new owner name
            if callback then callback(true) end
        else
            -- Refund money if save failed
            character:giveCash(self.price)
            outputChatBox("Failed to purchase house. Money refunded.", player)
            if callback then callback(false) end
        end
    end)
end

-- Instance method to check if house is owned
function House:isOwned()
    return self.owner ~= nil
end

-- Instance method to get house data as table
function House:getData()
    return {
        id = self.id,
        owner = self.owner,
        ownerName = self.ownerName,
        x = self.x,
        y = self.y,
        z = self.z,
        price = self.price
    }
end

-- Instance method to delete house
function House:delete(callback)
    if not self.id then
        outputDebugString("[DEBUG] Cannot delete house without ID.")
        if callback then callback(false) end
        return
    end
    
    -- Destroy visuals first
    self:destroyVisuals()
    
    local queryString = "DELETE FROM houses WHERE id = ?"
    queryAsync(queryString, function(result)
        if result then
            outputDebugString("[DEBUG] House deleted successfully: ID " .. self.id)
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] House deletion failed: ID " .. self.id)
            if callback then callback(false) end
        end
    end, self.id)
end

-- Initialize database when database connection is established
addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, House.initializeDatabase)
