-- Character class using MTA OOP system
-- Based on https://wiki.multitheftauto.com/wiki/OOP_Introduction

Character = {}
Character.__index = Character

-- Constructor
function Character:create(data)
    local instance = {}
    setmetatable(instance, Character)
    
    -- Initialize properties
    instance.id = data.id or nil
    instance.name = data.name or nil
    instance.age = data.age or 18
    instance.gender = data.gender or "Male"
    instance.skin = data.skin or "0"
    instance.cash = data.cash or 5000
    instance.bank = data.bank or 0
    instance.accountId = data.account_id or nil
    instance.player = nil
    instance.position = {x = 0, y = 0, z = 3}
    instance.rotation = 0
    
    return instance
end

-- Static method to initialize database
function Character.initializeDatabase()
    queryAsync("CREATE TABLE IF NOT EXISTS characters (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT, gender VARCHAR(16), skin VARCHAR(16), cash INT(11), bank INT(11), account_id INT, FOREIGN KEY (account_id) REFERENCES accounts(id))", function(result)
        if result then
            triggerEvent(EVENTS.CHARACTERS.ON_CHARACTER_DATABASE_CONNECTED, resourceRoot)
        else
            outputDebugString("[DEBUG] Characters table creation query failed.")
        end
    end)
end

-- Static method to get character by ID
function Character.getById(characterId, callback)
    if not characterId then
        outputDebugString("[DEBUG] Character.getById called with nil characterId.")
        if callback then callback(nil) end
        return
    end
    
    local queryString = "SELECT * FROM characters WHERE id = ?"
    queryAsync(queryString, function(result)
        if result and result[1] then
            local character = Character:create(result[1])
            callback(character)
        else
            callback(nil)
        end
    end, characterId)
end

-- Static method to get characters by account ID
function Character.getByAccountId(accountId, callback)
    if not accountId then
        outputDebugString("[DEBUG] Character.getByAccountId called with nil accountId.")
        if callback then callback(nil) end
        return
    end
    
    local queryString = "SELECT * FROM characters WHERE account_id = ?"
    queryAsync(queryString, function(result)
        if result and #result > 0 then
            local characters = {}
            for _, charData in ipairs(result) do
                table.insert(characters, Character:create(charData))
            end
            callback(characters)
        else
            callback(nil)
        end
    end, accountId)
end

-- Static method to create new character
function Character.createNew(name, age, gender, skin, accountId, callback)
    if not name or not age or not gender or not skin or not accountId then
        outputDebugString("[DEBUG] Character.createNew called with nil values.")
        if callback then callback(nil) end
        return
    end
    local queryString = "INSERT INTO characters (name, age, gender, skin, account_id) VALUES (?, ?, ?, ?, ?)"
    insertAsync(queryString, function(result)
        if result and result > 0 then
            outputDebugString("[DEBUG] Character created successfully: " .. name)
            -- Get the newly created character
            Character.getById(result, callback)
        else
            outputDebugString("[DEBUG] Character creation failed for: " .. name)
            if callback then callback(nil) end
        end
    end, name, age, gender, skin, accountId)
end

-- Instance method to save character data
function Character:save(callback)
    if not self.id then
        outputDebugString("[DEBUG] Cannot save character without ID.")
        if callback then callback(false) end
        return
    end
    
    local queryString = "UPDATE characters SET name = ?, age = ?, gender = ?, skin = ?, cash = ?, bank = ? WHERE id = ?"
    queryAsync(queryString, function(result)
        if result then
            outputDebugString("[DEBUG] Character updated successfully: " .. (self.name or "unknown"))
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Character update failed: " .. (self.name or "unknown"))
            if callback then callback(false) end
        end
    end, self.name, self.age, self.gender, self.skin, self.cash, self.bank, self.id)
end

-- Instance method to set associated player
function Character:setPlayer(player)
    self.player = player
    if isElement(player) then
        setElementData(player, "character", self)
        -- Set player properties
        setElementModel(player, tonumber(self.skin) or 0)
        setPlayerMoney(player, self.cash)
    end
end

-- Instance method to get associated player
function Character:getPlayer()
    return self.player
end

-- Instance method to spawn character
function Character:spawn(x, y, z, rotation)
    if not self.player or not isElement(self.player) then
        outputDebugString("[DEBUG] Cannot spawn character without valid player.")
        return false
    end
    
    local spawnX = x or self.position.x
    local spawnY = y or self.position.y
    local spawnZ = z or self.position.z
    local spawnRot = rotation or self.rotation
    
    spawnPlayer(self.player, spawnX, spawnY, spawnZ, spawnRot, tonumber(self.skin) or 0)
    fadeCamera(self.player, true)
    setCameraTarget(self.player, self.player)
    
    -- Update position
    self.position = {x = spawnX, y = spawnY, z = spawnZ}
    self.rotation = spawnRot
    
    outputDebugString("[DEBUG] Character " .. self.name .. " spawned successfully.")
    return true
end

-- Instance method to add money
function Character:addMoney(amount)
    if not amount or amount <= 0 then return false end
    
    self.cash = self.cash + amount
    if self.player and isElement(self.player) then
        setPlayerMoney(self.player, self.cash)
    end
    return true
end

-- Instance method to take money
function Character:takeMoney(amount)
    if not amount or amount <= 0 or self.cash < amount then return false end
    
    self.cash = self.cash - amount
    if self.player and isElement(self.player) then
        setPlayerMoney(self.player, self.cash)
    end
    return true
end

-- Instance method to get character data as table
function Character:getData()
    return {
        id = self.id,
        name = self.name,
        age = self.age,
        gender = self.gender,
        skin = self.skin,
        cash = self.cash,
        bank = self.bank,
        account_id = self.accountId
    }
end

-- Static method to get character from player
function Character.getFromPlayer(player)
    if not isElement(player) then
        return nil
    end
    return getElementData(player, "character")
end

-- Instance method to delete character
function Character:delete(callback)
    if not self.id then
        outputDebugString("[DEBUG] Cannot delete character without ID.")
        if callback then callback(false) end
        return
    end
    
    local queryString = "DELETE FROM characters WHERE id = ?"
    queryAsync(queryString, function(result)
        if result then
            outputDebugString("[DEBUG] Character deleted successfully: " .. (self.name or "unknown"))
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Character deletion failed: " .. (self.name or "unknown"))
            if callback then callback(false) end
        end
    end, self.id)
end

function Character:hasCash(price)
    return self.cash >= price
end

function Character:hasBankMoney(price)
    return self.bank >= price
end

function Character:getCash()
    return self.cash
end

function Character:getBankMoney()
    return self.bank
end

-- Initialize database when database connection is established
addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, Character.initializeDatabase)
