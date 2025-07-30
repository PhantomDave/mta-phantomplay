-- Account class using MTA OOP system
-- Based on https://wiki.multitheftauto.com/wiki/OOP_Introduction

Account = {}
Account.__index = Account

-- Constructor
function Account:create(data)
    local instance = {}
    setmetatable(instance, Account)
    
    -- Initialize properties
    instance.id = data.id or nil
    instance.email = data.email or nil
    instance.username = data.username or nil
    instance.password = data.password or nil
    instance.adminLevel = data.admin_level or 0
    instance.lastLogin = data.last_login or nil
    instance.player = nil -- Associated player element
    
    return instance
end

-- Static method to initialize database
function Account.initializeDatabase()
    queryAsync("CREATE TABLE IF NOT EXISTS accounts (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(255), username VARCHAR(255), password VARCHAR(255), admin_level INT DEFAULT 0, last_login DATETIME DEFAULT current_timestamp())", function(result)
        if result then
            outputDebugString("[DEBUG] Account table creation query executed successfully.")
            triggerEvent(EVENTS.ACCOUNTS.ON_ACCOUNT_DATABASE_CONNECTED, resourceRoot)
        else
            outputDebugString("[DEBUG] Account table creation query failed.")
        end
    end)
end

-- Static method to login user
function Account.login(email, password, callback)
    if not email or not password then
        outputDebugString("[DEBUG] Account.login called with nil email or password.")
        if callback then callback(nil) end
        return
    end
    
    local queryString = "SELECT * FROM accounts WHERE email = ? AND password = ?"
    outputDebugString("[DEBUG] Executing login query: " .. queryString)
    
    queryAsync(queryString, function(result)
        if result and #result > 0 then
            outputDebugString("[DEBUG] Login successful for email: " .. email)
            local account = Account:create(result[1])
            callback(account)
        else
            outputDebugString("[DEBUG] Login failed for email: " .. email)
            callback(nil)
        end
    end, email, password)
end

-- Static method to check if user exists
function Account.checkExists(email, username, callback)
    if not email or not username then
        outputDebugString("[DEBUG] Account.checkExists called with nil email or username.")
        if callback then callback(nil) end
        return
    end
    
    local queryString = "SELECT * FROM accounts WHERE email = ? OR username = ?"
    outputDebugString("[DEBUG] Executing user existence check query: " .. queryString)
    
    queryAsync(queryString, function(result)
        callback(result and #result > 0)
    end, email, username)
end

-- Static method to create new account
function Account.register(email, username, password, callback)
    if not email or not username or not password then
        outputDebugString("[DEBUG] Account.register called with nil parameters.")
        if callback then callback(false) end
        return
    end
    
    local queryString = "INSERT INTO accounts (email, username, password) VALUES (?, ?, ?)"
    outputDebugString("[DEBUG] Executing user creation query: " .. queryString)
    
    queryAsync(queryString, function(result)
        if result then
            outputDebugString("[DEBUG] User created successfully: " .. username)
            callback(true)
        else
            outputDebugString("[DEBUG] User creation failed: " .. username)
            callback(false)
        end
    end, email, username, password)
end

-- Instance method to save account data
function Account:save(callback)
    if not self.id then
        outputDebugString("[DEBUG] Cannot save account without ID.")
        if callback then callback(false) end
        return
    end
    
    local queryString = "UPDATE accounts SET email = ?, username = ?, password = ?, admin_level = ?, last_login = ? WHERE id = ?"
    outputDebugString("[DEBUG] Executing account update query: " .. queryString)
    
    queryAsync(queryString, function(result)
        if result then
            outputDebugString("[DEBUG] Account updated successfully: " .. (self.username or "unknown"))
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Account update failed: " .. (self.username or "unknown"))
            if callback then callback(false) end
        end
    end, self.email, self.username, self.password, self.adminLevel, self.lastLogin, self.id)
end

-- Instance method to update last login
function Account:updateLastLogin(callback)
    self.lastLogin = getRealTime().timestamp
    self:save(callback)
end

-- Instance method to set associated player
function Account:setPlayer(player)
    self.player = player
    if isElement(player) then
        setElementData(player, "account", self)
    end
end

-- Instance method to get associated player
function Account:getPlayer()
    return self.player
end

-- Instance method to check if account is admin
function Account:isAdmin()
    return self.adminLevel > 0
end

-- Instance method to get account data as table
function Account:getData()
    return {
        id = self.id,
        email = self.email,
        username = self.username,
        admin_level = self.adminLevel,
        last_login = self.lastLogin
    }
end

-- Static method to get account from player
function Account.getFromPlayer(player)
    if not isElement(player) then
        return nil
    end
    return getElementData(player, "account")
end

-- Initialize database when database connection is established
addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, Account.initializeDatabase)
