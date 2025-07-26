function connect ()
    DBConnection = dbConnect("mysql", "dbname=mta_sa;host=127.0.0.1;charset=utf8", "my_user", "user_password", "share=1" )

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


addEventHandler (EVENTS.ON_RESOURCE_START, root, connect)
addEvent(EVENTS.ON_DATABASE_CONNECTED, false)