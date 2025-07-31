-- Database class using MTA OOP system
-- Based on https://wiki.multitheftauto.com/wiki/OOP_Introduction

Database = {}

-- Register custom events
if type(EVENTS) == "table" and EVENTS.ON_DATABASE_CONNECTED then
    addEvent(EVENTS.ON_DATABASE_CONNECTED, true)
end
Database.__index = Database

-- Static database connection
Database.connection = nil
Database.isConnected = false

-- Constructor (for potential multiple database connections)
function Database:create(connectionString)
    local instance = {}
    setmetatable(instance, Database)
    
    instance.connectionString = connectionString
    instance.connection = nil
    instance.isConnected = false
    
    return instance
end

-- Static method to initialize main database connection
function Database.initialize()
    -- Get database settings using the correct MTA settings system
    local dbType = get("dbtype")
    local dbName = get("dbname")
    local dbHost = get("dbhost")
    local dbUser = get("dbuser")
    local dbPass = get("dbpassword")
    
    if not dbType or dbType == false or dbType == "" then
        outputDebugString("[ERROR] Database type setting not found! Check meta.xml settings.", 1)
        return false
    end
    
    if not dbName or dbName == false or dbName == "" then
        outputDebugString("[ERROR] Database name setting not found! Check meta.xml settings.", 1)
        return false
    end
    
    if dbType == "mysql" then
        if not dbHost or dbHost == false or dbHost == "" then
            outputDebugString("[ERROR] MySQL host setting not found! Check meta.xml settings.", 1)
            return false
        end
        if not dbUser or dbUser == false or dbUser == "" then
            outputDebugString("[ERROR] MySQL user setting not found! Check meta.xml settings.", 1)
            return false
        end
        connectionString = "dbname=" .. dbName .. ";host=" .. dbHost .. ";charset=utf8"
    else
        -- For SQLite
        connectionString = dbName
    end
    
    Database.connection = dbConnect(dbType, connectionString, dbUser, dbPass)
    
    if Database.connection then
        Database.isConnected = true
        outputDebugString("[DEBUG] Database connected successfully (" .. dbType .. ")")
        addEvent(EVENTS.ON_DATABASE_CONNECTED, false)
        triggerEvent(EVENTS.ON_DATABASE_CONNECTED, resourceRoot)
        return true
    else
        outputDebugString("[ERROR] Failed to connect to database")
        return false
    end
end

-- Static method to close database connection
function Database.close()
    if Database.connection then
        dbClose(Database.connection)
        Database.connection = nil
        Database.isConnected = false
        outputDebugString("[DEBUG] Database connection closed")
    end
end

-- Static method for asynchronous queries
function Database.queryAsync(queryStr, callback, ...)
    if not Database.isConnected or not Database.connection then
        outputDebugString("[ERROR] Database not connected")
        if callback then callback(nil) end
        return false
    end
    
    local params = {...}
    dbQuery(function(qh)
        local result, numRows, errorMsg = dbPoll(qh, -1)
        if not result then
            outputDebugString("[ERROR] Query failed: " .. tostring(errorMsg) .. " | Query: " .. queryStr)
            if callback then callback(nil) end
        else
            if callback then callback(result, numRows) end
        end
        dbFree(qh)
    end, {}, Database.connection, queryStr, unpack(params))
    
    return true
end

-- Static method for execute operations (UPDATE, DELETE)
function Database.executeAsync(queryStr, callback, ...)
    if not Database.isConnected or not Database.connection then
        outputDebugString("[ERROR] Database not connected")
        if callback then callback(0) end
        return false
    end
    
    local params = {...}
    dbQuery(function(qh)
        local _, numRows, errorMsg = dbPoll(qh, -1)
        if errorMsg then
            outputDebugString("[ERROR] Execute failed: " .. tostring(errorMsg) .. " | Query: " .. queryStr)
            if callback then callback(0) end
        else
            if callback then callback(numRows or 0) end
        end
        dbFree(qh)
    end, {}, Database.connection, queryStr, unpack(params))
    
    return true
end

-- Static method for insert operations with auto-increment ID return
function Database.insertAsync(queryStr, callback, ...)
    if not Database.isConnected or not Database.connection then
        outputDebugString("[ERROR] Database not connected")
        if callback then callback(nil, 0) end
        return false
    end
    
    local params = {...}
    dbQuery(function(qh)
        local result, num_affected_rows, last_insert_id = dbPoll ( qh, -1 )
        if not result then
            local error_code,error_msg = num_affected_rows,last_insert_id
            outputDebugString("[ERROR] Insert failed: " .. tostring(error_msg) .. " | Query: " .. queryStr)
            if callback then callback(nil, 0) end
            dbFree(qh)
            return
        end

        if result and callback then
            callback(last_insert_id)
        end
        
        dbFree(qh)
    end, {}, Database.connection, queryStr, unpack(params))
    
    return true
end

-- Static method for transactions
function Database.transaction(queries, callback)
    if not Database.isConnected or not Database.connection then
        outputDebugString("[ERROR] Database not connected")
        if callback then callback(false) end
        return false
    end
    
    local completedQueries = 0
    local totalQueries = #queries
    local transactionSuccess = true
    
    -- Begin transaction
    Database.executeAsync("BEGIN TRANSACTION", function()
        for i, queryData in ipairs(queries) do
            local queryStr = queryData.query
            local params = queryData.params or {}
            
            Database.queryAsync(queryStr, function(result)
                completedQueries = completedQueries + 1
                
                if not result then
                    transactionSuccess = false
                end
                
                -- Check if all queries completed
                if completedQueries == totalQueries then
                    if transactionSuccess then
                        Database.executeAsync("COMMIT", function()
                            outputDebugString("[DEBUG] Transaction committed successfully")
                            if callback then callback(true) end
                        end)
                    else
                        Database.executeAsync("ROLLBACK", function()
                            outputDebugString("[ERROR] Transaction rolled back due to errors")
                            if callback then callback(false) end
                        end)
                    end
                end
            end, unpack(params))
        end
    end)
    
    return true
end

-- Static method to check if database is connected
function Database.isReady()
    return Database.isConnected and Database.connection ~= nil
end

-- Static method to get connection (for backward compatibility)
function Database.getConnection()
    return Database.connection
end
