-- House class using MTA OOP system
-- Based on https://wiki.multitheftauto.com/wiki/OOP_Introduction

House = {}
House.__index = House

-- Constructor
function House:create(data)
    local instance = {}
    setmetatable(instance, House)
    
    -- Initialize properties
    instance.id = data.id or nil
    instance.owner = data.owner or nil
    instance.ownerName = data.owner_name or nil  -- New field for owner name from JOIN
    instance.x = data.x or 0
    instance.y = data.y or 0
    instance.z = data.z or 0
    instance.price = data.price or 50000
    instance.interior = data.interior or 0
    instance.dimension = data.dimension or 0
    
    -- Visual elements
    instance.marker = nil
    instance.blip = nil
    instance.colShape = nil
    
    return instance
end

-- Static method to initialize database
function House.initializeDatabase()
    queryAsync("CREATE TABLE IF NOT EXISTS houses (id INT AUTO_INCREMENT PRIMARY KEY, owner INT, FOREIGN KEY (owner) REFERENCES characters(id), x FLOAT, y FLOAT, z FLOAT, price INT, interior INT)", function(result)
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
        SELECT h.id, h.owner, h.x, h.y, h.z, h.price, h.interior, h.dimension, c.name as owner_name
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
        SELECT h.id, h.owner, h.x, h.y, h.z, h.price, h.interior, h.dimension, c.name as owner_name
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
    local query = "INSERT INTO houses (x, y, z, price) VALUES (?, ?, ?, ?)"
    
    insertAsync(query, function(insertId)
        if insertId and insertId > 0 then
            -- Get the newly created house
            House.getById(insertId, callback)
        else
            outputDebugString("[DEBUG] Failed to create house.")
            if callback then callback(nil) end
        end
    end, x, y, z, price)
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
    
    self.marker = createMarker(self.x, self.y, self.z + 1, "arrow", 1.5, 255, 255, 255, 150)
    setElementDimension(self.marker, self.dimension)
    setElementInterior(self.marker, self.interior)
    
    self.blip = createBlipAttachedTo(self.marker, 31, 0, 0, 0, 0, 255, 0, 9999)
    setElementDimension(self.blip, self.dimension)
    
    self.colShape = createColSphere(self.x, self.y, self.z, 1.5)
    setElementDimension(self.colShape, self.dimension)

    self.textDisplay = textCreateDisplay()

    -- Use ownerName from JOIN query, or "Nobody" if no owner
    local ownerDisplay = self.ownerName or "Nobody"
    local text = "House ID: " .. (self.id) .. "\nPrice: $" .. (self.price or 0) .. "\nOwner: " .. ownerDisplay .. "\n\nPress ALT to buy the house"

    self.textItem = textCreateTextItem(text, 0.5, 0.5, "medium", 0, 255, 0, 150, 2, "left", "left", 255)
    textDisplayAddText(self.textDisplay, self.textItem)

    addEventHandler(EVENTS.ON_COLSHAPE_HIT, self.colShape, function(hitElement)
        if getElementType(hitElement) == "player" then
            textDisplayAddObserver(self.textDisplay, hitElement)
            bindKey(hitElement, "lalt", "down", function()
                buyHouseFunction(hitElement, self)
            end)
        end
    end)
    
    addEventHandler(EVENTS.ON_COLSHAPE_LEAVE, self.colShape, function(leaveElement)
        if getElementType(leaveElement) == "player" then
            textDisplayRemoveObserver(self.textDisplay, leaveElement)
            unbindKey(leaveElement, "lalt", "down")
        end
    end)
    
    outputDebugString("[DEBUG] House visuals created for ID: " .. self.id)
end

-- Instance method to destroy visual elements
function House:destroyVisuals()
    if self.marker and isElement(self.marker) then
        destroyElement(self.marker)
        self.marker = nil
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
function House:onPlayerEnter(player)
    if self.owner then
        outputChatBox("This house is owned. ID: " .. self.id, player)
    else
        outputChatBox("House for sale at (" .. self.x .. ", " .. self.y .. ", " .. self.z .. "). Price: $" .. self.price, player)
        outputChatBox("Type /buyhouse to purchase this property.", player)
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
