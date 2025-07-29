function initializeAccountDatabase()
    executeAsync(
        function(affectedRows, error)
            if error then
                outputDebugString("[DEBUG] Account table creation query failed: " .. tostring(error))
            else
                outputDebugString("[DEBUG] Account table creation query executed successfully.")
            end
        end,
        nil,
        "CREATE TABLE IF NOT EXISTS accounts (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(255), password VARCHAR(255), last_login VARCHAR(16) DEFAULT current_timestamp())"
    )
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, initializeAccountDatabase)

function loginUser(email, password, callback)
    if not email or not password then
        outputDebugString("[DEBUG] loginUser called with nil email or password.")
        if callback then callback(nil) end
        return
    end
    
    queryAsync(
        function(result, numRows, error)
            if error or not result or #result == 0 then
                outputDebugString("[DEBUG] Login failed for email: " .. email)
                if callback then callback(nil) end
            else
                if callback then callback(result[1]) end
            end
        end,
        nil,
        "SELECT * FROM accounts WHERE email = ? AND password = ?",
        email,
        sha256(email .. password)
    )
end

function GetUserByEmail(email, callback)
    if not email then
        outputDebugString("[DEBUG] GetUserByEmail called with nil email.")
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
        "SELECT * FROM accounts WHERE email = ?",
        email
    )
end

function RegisterUser(email, password, callback)
    if not email or not password then
        outputDebugString("[DEBUG] RegisterUser called with nil email or password.")
        if callback then callback(false) end
        return
    end
    
    local hashedPassword = sha256(email .. password)
    executeAsync(
        function(affectedRows, error)
            if error then
                outputDebugString("[DEBUG] User registration failed for: " .. email .. " - " .. tostring(error))
                if callback then callback(false) end
            else
                outputDebugString("[DEBUG] User registered successfully: " .. email)
                if callback then callback(true) end
            end
        end,
        nil,
        "INSERT INTO accounts (email, password) VALUES (?, ?)",
        email,
        hashedPassword
    )
end