function connect ()
    DBConnection = dbConnect("mysql", "dbname=mta_sa;host=db;charset=utf8", "my_user", "user_password", "share=1" )

    if (not DBConnection) then
        outputDebugString("Error: Failed to establish connection to the MySQL database server")
    else
        outputDebugString("Success: Connected to the MySQL database server")
         local success = triggerEvent(EVENTS.ON_DATABASE_CONNECTED, resourceRoot)        
        if (not success) then
            outputDebugString("Error: Failed to add event handler for database connection")
        else
            outputDebugString("Success: Event handler for database connection added")
        end
    end
end

function queryAsync(callback, callbackData, queryString, ...)
    if not DBConnection then
        outputDebugString("Error: queryAsync called before database connection is ready.")
        if callback and type(callback) == "function" then
            callback(nil, nil, "Database not connected", callbackData)
        end
        return false
    end

    if not callback or type(callback) ~= "function" then
        outputDebugString("Error: queryAsync requires a callback function")
        return false
    end
    
    -- Ensure callbackData is a table
    callbackData = callbackData or {}
    
    -- Use the callback-based dbQuery directly (following wiki example pattern)
    local queryHandle = dbQuery(function(queryHandle, extraData)
        local result, numRows, errorMsg = dbPoll(queryHandle, 0)
        
        if result == false then
            -- Query failed - get error information
            local errorCode, errorMessage = numRows, errorMsg
            outputDebugString("Error: Query failed - Code: " .. tostring(errorCode) .. ", Message: " .. tostring(errorMessage))
            callback(nil, nil, errorMessage or "Query failed", extraData)
        elseif type(result) == "table" then
            -- Query succeeded
            callback(result, numRows or #result, nil, extraData)
        else
            -- Result is nil, query not ready yet (shouldn't happen in callback)
            outputDebugString("Warning: Query result not ready in callback")
            callback(nil, nil, "Query result not ready", extraData)
        end
    end, callbackData, DBConnection, queryString, ...)
    
    if not queryHandle then
        outputDebugString("Error: Failed to create query handle")
        callback(nil, nil, "Failed to create query handle", callbackData)
        return false
    end
    
    return true
end

function executeAsync(callback, callbackData, queryString, ...)
    if not DBConnection then
        outputDebugString("Error: executeAsync called before database connection is ready.")
        if callback and type(callback) == "function" then
            callback(nil, "Database not connected", callbackData)
        end
        return false
    end

    if not callback or type(callback) ~= "function" then
        outputDebugString("Error: executeAsync requires a callback function")
        return false
    end
    
    -- Use the callback-based dbQuery for execute operations as well
    local queryHandle = dbQuery(function(queryHandle, extraData)
        local result, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)
        
        if result == false then
            -- Query failed
            local errorCode, errorMessage = numAffectedRows, lastInsertId
            outputDebugString("Error: Execute failed - Code: " .. tostring(errorCode) .. ", Message: " .. tostring(errorMessage))
            callback(nil, errorMessage or "Execute failed", extraData)
        elseif result == nil then
            -- Query not ready yet (shouldn't happen in callback)
            outputDebugString("Warning: Execute result not ready in callback")
            callback(nil, "Execute result not ready", extraData)
        else
            -- Execute succeeded - numAffectedRows contains the affected rows count
            callback(numAffectedRows or 0, nil, extraData)
        end
    end, callbackData or {}, DBConnection, queryString, ...)
    
    if not queryHandle then
        outputDebugString("Error: Failed to create execute handle")
        callback(nil, "Failed to create execute handle", callbackData)
        return false
    end
    
    return true
end

function getDBConnection()
    return DBConnection
end

--[[
Example usage of async functions (non-blocking approach):

-- Query example:
queryAsync(function(result, numRows, error, data)
    if error then
        outputDebugString("Query failed: " .. error)
        return
    end
    
    outputDebugString("Query completed. Rows: " .. numRows)
    outputDebugString("Data passed: " .. data.message)
    
    -- Process result here
    if result then
        for i, row in ipairs(result) do
            -- Handle each row
            for column, value in pairs(row) do
                outputDebugString("Column: " .. column .. ", Value: " .. tostring(value))
            end
        end
    end
end, {message = "hello", score = 2000}, "SELECT * FROM accounts WHERE id = ?", 1)

-- Execute example:
executeAsync(function(affectedRows, error, data)
    if error then
        outputDebugString("Execute failed: " .. error)
        return
    end
    
    outputDebugString("Execute completed. Affected rows: " .. affectedRows)
    outputDebugString("Data passed: " .. data.operation)
end, {operation = "insert"}, "INSERT INTO accounts (username, password) VALUES (?, ?)", "testuser", "hashedpass")
--]]


addEventHandler (EVENTS.ON_RESOURCE_START, root, connect)
addEvent(EVENTS.ON_DATABASE_CONNECTED, false)