function initializeCharacterDatabase()
    local result = query("CREATE TABLE IF NOT EXISTS characters (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT, gender VARCHAR(16), skin VARCHAR(16), account_id INT, FOREIGN KEY (account_id) REFERENCES accounts(id))")
    if result then
        outputDebugString("[DEBUG] Characters table creation query executed successfully.")
        --triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
    else
        outputDebugString("[DEBUG] Characters table creation query failed.")
    end
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, initializeCharacterDatabase)

function GetCharacterById(characterId)
    if not characterId then
        outputDebugString("[DEBUG] GetCharacterById called with nil characterId.")
        return nil
    end
    local queryString = string.format("SELECT * FROM characters WHERE id = %d", characterId)
    local result = queryAsync(queryString, function(result)
        return result and result[1] or nil
    end)
end

function GetCharactersByAccountId(accountId)
    if not accountId then
        outputDebugString("[DEBUG] GetCharactersByAccountId called with nil accountId.")
        return nil
    end
    local queryString = string.format("SELECT * FROM characters WHERE account_id = %d", accountId)
    local result = queryAsync(queryString, function(result)
        return isTableNotEmpty(result) and result or nil
    end)
end

function CreateCharacter(name, age, gender, skin, accountId)
    if not name or not age or not gender or not skin or not accountId then
        outputDebugString("[DEBUG] CreateCharacter called with nil values.")
        return false
    end
    local queryString = string.format("INSERT INTO characters (name, age, gender, skin, account_id) VALUES ('%s', %d, '%s', '%s', %d)", name, age, gender, skin, accountId)
    local result = insertAsync(queryString, function(result)
        return result and result[1] or nil
    end)
    return result
end