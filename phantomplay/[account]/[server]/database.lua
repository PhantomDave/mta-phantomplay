function initializeAccountDatabase()
    queryAsync("CREATE TABLE IF NOT EXISTS accounts (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(255), username VARCHAR(255), password VARCHAR(255), admin_level INT DEFAULT 0, last_login DATETIME DEFAULT current_timestamp())", function(result)
        if result then
            outputDebugString("[DEBUG] Account table creation query executed successfully.")
            --triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
        else
            outputDebugString("[DEBUG] Account table creation query failed.")
        end
    end)
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, initializeAccountDatabase)

function loginUser(email, password, callback)
    if not email or not password then
        outputDebugString("[DEBUG] loginUser called with nil email or password.")
        if callback then callback(nil) end
        return
    end
    local queryString = "SELECT * FROM accounts WHERE email = ? AND password = ?"
    outputDebugString("[DEBUG] Executing login query: " .. queryString)
    queryAsync(queryString, function(result)
        if not result or #result == 0 then
            outputDebugString("[DEBUG] Login failed for user: " .. email)
            if callback then callback(nil) end
            return
        end
        if callback then callback(result[1]) end
    end, email, sha256(email .. password))
end

function GetUserByEmailOrUsername(email, username, callback)
    if not email and not username then
        outputDebugString("[DEBUG] GetUserByEmailOrUsername called with nil email and username.")
        if callback then callback(nil) end
        return
    end
    local queryString = "SELECT * FROM accounts WHERE email = ? OR username = ?"
    local result = queryAsync(queryString, function(result)
        if callback then callback(result and result[1] or nil) end
    end, email, username)
end

function RegisterUser(username, email, password)
    if not email or not username or not password then
        outputDebugString("[DEBUG] RegisterUser called with nil email, username or password.")
        return false
    end
    local hashedPassword = sha256(email .. password)
    local queryString = "INSERT INTO accounts (email, username, password) VALUES (?, ?, ?)"
    insertAsync(queryString, function(result)
        if result > 0 then
            outputDebugString("[DEBUG] User registered successfully: " .. email)
            return true
        else
            outputDebugString("[DEBUG] User registration failed for: " .. email)
            return false
        end
    end, email, username, hashedPassword)
end

function UpdateAccount(player)
    if not player or not isElement(player) then
        outputDebugString("[DEBUG] UpdatePlayer called with invalid player element.")
        return
    end

    local accountData = getAccountData(player)
    if not accountData or not accountData.id then
        outputDebugString("[DEBUG] No account data found for player: " .. getPlayerName(player))
        return
    end

    local setParts = {}
    local values = {}
    local excludeFields = {id = true, last_login = true}
    
    for key, value in pairs(accountData) do
        if not excludeFields[key] and value ~= nil then
            table.insert(setParts, key .. " = ?")
            table.insert(values, value)
        end
    end
    
    table.insert(setParts, "last_login = NOW()")
    
    if #setParts == 1 then -- Only last_login update
        outputDebugString("[DEBUG] No fields to update for player: " .. getPlayerName(player))
        return
    end
    
    table.insert(values, accountData.id)
    
    local queryString = "UPDATE accounts SET " .. table.concat(setParts, ", ") .. " WHERE id = ?"
    
    executeAsync(queryString, function(result)
        if result > 0 then
            outputDebugString("[DEBUG] Player data updated successfully for: " .. getPlayerName(player) .. " (Updated " .. (#setParts) .. " fields)")
        else
            outputDebugString("[DEBUG] Failed to update player data for: " .. getPlayerName(player))
        end
    end, unpack(values))
end