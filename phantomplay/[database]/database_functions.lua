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

function executeAsync(queryStr, callback, ...)
    dbQuery(function(qh)
        local _, numRows = dbPoll(qh, -1)
        callback(numRows)
        dbFree(qh)
    end, {}, DBConnection, queryStr, ...)
end

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
            dbFree(qh2)
        end, {}, DBConnection, "SELECT LAST_INSERT_ID() AS id")
        dbFree(qh)
    end, {}, DBConnection, queryStr, ...)
end