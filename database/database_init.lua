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

function query(...)
    local queryHandle = dbQuery(DBConnection, ...)
    if (not queryHandle) then
        return nil
    end
    local result, numRows, errorMsg = dbPoll(queryHandle, -1)
    if not result then
        outputDebugString("Error: Query failed - " .. tostring(errorMsg))
        return nil
    end
    return result
end
 
function execute(...)
    local queryHandle = dbQuery(DBConnection, ...)
    local result, numRows = dbPoll(queryHandle, -1)
    return numRows
end

function getDBConnection()
    return DBConnection
end

-- Add asynchronous query function using dbQuery callback
function queryAsync(queryStr, callback, ...)
    dbQuery(function(qh)
        local result, numRows, errorMsg = dbPoll(qh, -1)
        if not result then
            outputDebugString("Error: Async Query failed - " .. tostring(errorMsg))
            callback(nil)
        else
            callback(result, numRows)
        end
    end, {}, DBConnection, queryStr, ...)
end

-- executeAsync: async execute for non-insert statements (callback receives rowsAffected)
function executeAsync(queryStr, callback, ...)
    dbQuery(function(qh)
        local _, numRows = dbPoll(qh, -1)
        callback(numRows)
    end, {}, DBConnection, queryStr, ...)
end

-- insertAsync: async insert that returns last_insert_id and rowsAffected
function insertAsync(queryStr, callback, ...)
    dbQuery(function(qh)
        local _, numRows = dbPoll(qh, -1)
        dbQuery(function(qh2)
            local res2 = dbPoll(qh2, -1)
            local insertId = nil
            if res2 and res2[1] then
                insertId = res2[1].id or res2[1]["LAST_INSERT_ID()"]
            end
            callback(insertId, numRows)
        end, {}, DBConnection, "SELECT LAST_INSERT_ID() AS id")
    end, {}, DBConnection, queryStr, ...)
end

addEventHandler (EVENTS.ON_RESOURCE_START, root, connect)
addEvent(EVENTS.ON_DATABASE_CONNECTED, false)