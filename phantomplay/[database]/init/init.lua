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


addEventHandler (EVENTS.ON_RESOURCE_START, root, connect)
addEvent(EVENTS.ON_DATABASE_CONNECTED, false)