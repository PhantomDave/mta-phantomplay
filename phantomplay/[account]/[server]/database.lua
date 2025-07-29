function initializeAccountDatabase()
    local result = query("CREATE TABLE IF NOT EXISTS accounts (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(255), username VARCHAR(255), password VARCHAR(255), last_login DATETIME DEFAULT current_timestamp())")
    if result then
        outputDebugString("[DEBUG] Account table creation query executed successfully.")
        --triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
    else
        outputDebugString("[DEBUG] Account table creation query failed.")
    end
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, initializeAccountDatabase)

function loginUser(email, password, callback)
    if not email or not password then
        outputDebugString("[DEBUG] loginUser called with nil email or password.")
        if callback then callback(nil) end
        return
    end
    local queryString = string.format("SELECT * FROM accounts WHERE email = '%s' AND password = '%s'", email, sha256(email .. password))
    outputDebugString("[DEBUG] Executing login query: " .. queryString)
    queryAsync(queryString, function(result)
        if not result or #result == 0 then
            outputDebugString("[DEBUG] Login failed for user: " .. email)
            if callback then callback(nil) end
            return
        end
        if callback then callback(result[1]) end
    end)
end

function GetUserByEmailOrUsername(email, username, callback)
    if not email and not username then
        outputDebugString("[DEBUG] GetUserByEmailOrUsername called with nil email and username.")
        if callback then callback(nil) end
        return
    end
    local queryString = string.format("SELECT * FROM accounts WHERE email = '%s' OR username = '%s'", email, username)
    local result = queryAsync(queryString, function(result)
        if callback then callback(result and result[1] or nil) end
    end)
end

function RegisterUser(username, email, password)
    if not email or not username or not password then
        outputDebugString("[DEBUG] RegisterUser called with nil email, username or password.")
        return false
    end
    local hashedPassword = sha256(email .. password)
    local queryString = string.format("INSERT INTO accounts (email, username, password) VALUES ('%s', '%s', '%s')", email, username, hashedPassword)
    insertAsync(queryString, function(result)
        if result > 0 then
            outputDebugString("[DEBUG] User registered successfully: " .. email)
            return true
        else
            outputDebugString("[DEBUG] User registration failed for: " .. email)
            return false
        end
    end)
end