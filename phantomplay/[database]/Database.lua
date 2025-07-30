-- Database class using MTA OOP system
-- Based on https://wiki.multitheftauto.com/wiki/OOP_Introduction

Database = {}
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
    -- Try multiple methods to get settings
    local resName = getResourceName(resource)
    -- Method 1: Direct get with resource
    local dbType = get(resName .. '.database.type')
    local dbName = get(resName .. '.database.name')
    local dbHost = get(resName .. '.database.host')
    local dbUser = get(resName .. '.database.user')
    local dbPass = get(resName .. '.database.password')
        
    iprint("[DEBUG] Settings retrieval method:")
    iprint("[DEBUG] Resource name: " .. getResourceName(resource))
    iprint("[DEBUG] Database Type: " .. dbType)
    iprint("[DEBUG] Database Name: " .. dbName)
    iprint("[DEBUG] Database Host: " .. dbHost)
    iprint("[DEBUG] Database User: " .. (dbUser ~= "" and "***" or "empty"))
    
    local connectionString
    if dbType == "mysql" then
        connectionString = "dbname=" .. dbName .. ";host=" .. dbHost .. ";charset=utf8"
    else
        connectionString = dbName
    end
    
    Database.connection = dbConnect(dbType, connectionString, dbUser, dbPass)
    
    if Database.connection then
        Database.isConnected = true
        outputDebugString("[DEBUG] Database connected successfully (" .. dbType .. ")")
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
            outputDebugString("[DEBUG] Query executed successfully: " .. queryStr)
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
            outputDebugString("[DEBUG] Execute completed: " .. queryStr .. " (Affected rows: " .. (numRows or 0) .. ")")
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
        local _, numRows, errorMsg = dbPoll(qh, -1)
        if errorMsg then
            outputDebugString("[ERROR] Insert failed: " .. tostring(errorMsg) .. " | Query: " .. queryStr)
            if callback then callback(nil, 0) end
            dbFree(qh)
            return
        end
        
        -- Get the last insert ID
        dbQuery(function(qh2)
            local result2 = dbPoll(qh2, -1)
            local insertId = nil
            if result2 and result2[1] then
                insertId = result2[1].id or result2[1]["LAST_INSERT_ID()"] or result2[1]["last_insert_rowid()"]
            end
            
            outputDebugString("[DEBUG] Insert completed: " .. queryStr .. " (Insert ID: " .. tostring(insertId) .. ", Affected rows: " .. (numRows or 0) .. ")")
            if callback then callback(insertId, numRows or 0) end
            dbFree(qh2)
        end, {}, Database.connection, "SELECT LAST_INSERT_ID() as id")
        
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
