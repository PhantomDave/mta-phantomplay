-- Legacy database functions for backward compatibility
-- These functions now use the Database OOP class internally

function queryAsync(queryStr, callback, ...)
    return Database.queryAsync(queryStr, callback, ...)
end

function executeAsync(queryStr, callback, ...)
    return Database.executeAsync(queryStr, callback, ...)
end

function insertAsync(queryStr, callback, ...)
    return Database.insertAsync(queryStr, callback, ...)
end

-- Helper function to get database connection (legacy compatibility)
function getDBConnection()
    return Database.getConnection()
end

-- Legacy variable for backward compatibility
DBConnection = nil

-- Update the legacy connection variable when database connects
addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, function()
    DBConnection = Database.getConnection()
end)
