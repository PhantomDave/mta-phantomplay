-- Database initialization using Database OOP class

function connect()
    outputDebugString("[DEBUG] Attempting to connect to database...")
    
    if Database.initialize() then
        outputDebugString("[DEBUG] Database initialization successful")
    else
        outputDebugString("[ERROR] Database initialization failed")
    end
end

-- Clean up database connection on resource stop
function disconnect()
    Database.close()
end

-- Initialize database connection when resource starts
addEventHandler("onResourceStart", resourceRoot, connect)
addEventHandler("onResourceStop", resourceRoot, disconnect)
