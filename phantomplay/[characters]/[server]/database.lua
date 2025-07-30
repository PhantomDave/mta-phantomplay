function initializeCharacterDatabase()
    local result = queryAsync("CREATE TABLE IF NOT EXISTS characters (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT, gender VARCHAR(16), skin VARCHAR(16), cash INT(11), bank INT(11), account_id INT, FOREIGN KEY (account_id) REFERENCES accounts(id))", function(result)
        if result then
            outputDebugString("[DEBUG] Characters table creation query executed successfully.")
            --triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
        else
            outputDebugString("[DEBUG] Characters table creation query failed.")
        end
    end)
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, initializeCharacterDatabase)

function GetCharacterById(characterId, callback)
    if not characterId then
        outputDebugString("[DEBUG] GetCharacterById called with nil characterId.")
        if callback then callback(nil) end
        return
    end
    local queryString = "SELECT * FROM characters WHERE id = ?"
    queryAsync(queryString, function(result)
        if callback then callback(result and result[1] or nil) end
    end, characterId)
end

function GetCharactersByAccountId(accountId, callback)
    if not accountId then
        outputDebugString("[DEBUG] GetCharactersByAccountId called with nil accountId.")
        if callback then callback(nil) end
        return
    end
    local queryString = "SELECT * FROM characters WHERE account_id = ?"
    queryAsync(queryString, function(result)
        if callback then
            callback(isTableNotEmpty(result) and result or nil)
        end
    end, accountId)
end

function CreateCharacter(name, age, gender, skin, accountId, callback)
    if not name or not age or not gender or not skin or not accountId then
        outputDebugString("[DEBUG] CreateCharacter called with nil values.")
        if callback then callback(false) end
        return
    end
    local queryString = "INSERT INTO characters (name, age, gender, skin, account_id) VALUES (?, ?, ?, ?, ?)"
    insertAsync(queryString, function(result)
        if result > 0 then
            outputDebugString("[DEBUG] Character created successfully: " .. name)
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Character creation failed for: " .. name)
            if callback then callback(false) end
        end
    end, name, age, gender, skin, accountId)
end

function UpdateCharacter(characterData, callback)
    if not characterData or not characterData.id then
        outputDebugString("[DEBUG] UpdateCharacter called with invalid data.")
        if callback then callback(false) end
        return
    end
    local queryString = "UPDATE characters SET name = ?, age = ?, gender = ?, skin = ?, cash = ?, bank = ? WHERE id = ?"
    executeAsync(queryString, function(result)
        if result then
            outputDebugString("[DEBUG] Character updated successfully: " .. characterData.name)
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Character update failed for: " .. characterData.name)
            if callback then callback(false) end
        end
    end, characterData.name, characterData.age, characterData.gender, characterData.skin, characterData.cash, characterData.bank, characterData.id)
end
