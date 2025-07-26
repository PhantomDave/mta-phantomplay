function initializeAccountDatabase()
    local result = query("CREATE TABLE IF NOT EXISTS accounts (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(255), password VARCHAR(255), last_login VARCHAR(16))")
    if result then
        outputDebugString("[DEBUG] Account table creation query executed successfully.")
        --triggerEvent(EVENTS.HOUSES.ON_HOUSE_DATABASE_CONNECTED, resourceRoot)
    else
        outputDebugString("[DEBUG] Account table creation query failed.")
    end
end

addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, initializeAccountDatabase)

function loginUser(email, password)
    if not email or not password then
        outputDebugString("[DEBUG] loginUser called with nil email or password.")
        return nil
    end
    local queryString = string.format("SELECT * FROM accounts WHERE email = '%s' AND password = '%s'", email, sha256(email .. password))
    local result = query(queryString)
    return result
end

function GetUserByEmail(email)
    if not email then
        outputDebugString("[DEBUG] GetUserByEmail called with nil email.")
        return nil
    end
    local queryString = string.format("SELECT * FROM accounts WHERE email = '%s'", email)
    local result = query(queryString)
    return result and result[1] or nil
end

function RegisterUser(email, password)
    if not email or not password then
        outputDebugString("[DEBUG] RegisterUser called with nil email or password.")
        return false
    end
    local hashedPassword = sha256(email .. password)
    local queryString = string.format("INSERT INTO accounts (email, password) VALUES ('%s', '%s')", email, hashedPassword)
    local result = execute(queryString)
    if result > 0 then
        outputDebugString("[DEBUG] User registered successfully: " .. email)
        return true
    else
        outputDebugString("[DEBUG] User registration failed for: " .. email)
        return false
    end
end