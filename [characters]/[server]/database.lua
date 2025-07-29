function initializeCharacterDatabase()
    executeAsync(
        function(affectedRows, error)
            if error then
                outputDebugString("[DEBUG] Characters table creation query failed: " .. tostring(error))
            else
                outputDebugString("[DEBUG] Characters table creation query executed successfully.")
            end
        end,
        nil,
        "CREATE TABLE IF NOT EXISTS characters (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT, gender VARCHAR(16), skin VARCHAR(16), account_id INT, FOREIGN KEY (account_id) REFERENCES accounts(id))"
    )
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, initializeCharacterDatabase)

function GetCharacterById(characterId, callback)
    if not characterId then
        outputDebugString("[DEBUG] GetCharacterById called with nil characterId.")
        if callback then callback(nil) end
        return
    end
    
    queryAsync(
        function(result, numRows, error)
            if error or not result or #result == 0 then
                if callback then callback(nil) end
            else
                if callback then callback(result[1]) end
            end
        end,
        nil,
        "SELECT * FROM characters WHERE id = ?",
        characterId
    )
end

function GetCharactersByAccountId(accountId, callback)
    if not accountId then
        outputDebugString("[DEBUG] GetCharactersByAccountId called with nil accountId.")
        if callback then callback(nil) end
        return
    end
    
    queryAsync(
        function(result, numRows, error)
            if error or not result then
                if callback then callback(nil) end
            else
                if callback then callback(isTableNotEmpty(result) and result or nil) end
            end
        end,
        nil,
        "SELECT * FROM characters WHERE account_id = ?",
        accountId
    )
end

function CreateCharacter(name, age, gender, skin, accountId, callback)
    if not name or not age or not gender or not skin or not accountId then
        outputDebugString("[DEBUG] CreateCharacter called with nil values.")
        if callback then callback(false) end
        return
    end
    
    executeAsync(
        function(affectedRows, error)
            if error then
                outputDebugString("[DEBUG] Character creation failed: " .. tostring(error))
                if callback then callback(false) end
            else
                outputDebugString("[DEBUG] Character created successfully: " .. name)
                if callback then callback(true) end
            end
        end,
        nil,
        "INSERT INTO characters (name, age, gender, skin, account_id) VALUES (?, ?, ?, ?, ?)",
        name, age, gender, skin, accountId
    )
end