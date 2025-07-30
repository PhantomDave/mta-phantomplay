-- Login events using Account OOP class

-- Handle login request from client
local function onLoginRequest(email, password)
    local player = client
    if not player or not isElement(player) then
        return
    end
    local hashedPassword = sha256(email .. password)
    Account.login(email, hashedPassword, function(account)
        if account then
            -- Login successful
            account:setPlayer(player)
            account:updateLastLogin()
            
            outputDebugString("[DEBUG] Player " .. getPlayerName(player) .. " logged in successfully")
            
            -- Clear login window first
            triggerClientEvent(player, EVENTS.GUI.CLEAR_LOGIN_WINDOW, player)
            
            -- Get characters for this account using the new Character OOP system
            Character.getByAccountId(account.id, function(characters)
                if characters and #characters > 0 then
                    -- Player has characters, show character selection
                    local characterData = {}
                    for _, character in ipairs(characters) do
                        table.insert(characterData, character:getData())
                    end
                    triggerClientEvent(player, EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, player, characterData)
                else
                    -- No characters, show character creation
                    triggerClientEvent(player, EVENTS.CHARACTERS.OPEN_CHARACTER_CREATION, player)
                end
            end)
        else
            -- Login failed
            outputDebugString("[DEBUG] Login failed for player: " .. getPlayerName(player))
            -- You could trigger a client event here to show error message
        end
    end)
end

-- Handle registration request from client
local function onRegisterRequest(email, username, password)
    local player = client
    if not player or not isElement(player) then
        return
    end
    
    -- First check if user already exists
    Account.checkExists(email, username, function(exists)
        if exists then
            outputDebugString("[DEBUG] Registration failed - user already exists: " .. username)
            -- You could trigger a client event here to show error message
            return
        end
        
        -- Hash the password (using the sha256 function from sha256.lua)
        local hashedPassword = sha256(email .. password)

        -- Create the account
        Account.register(email, username, hashedPassword, function(success)
            if success then
                outputDebugString("[DEBUG] Registration successful for user: " .. username)
                -- You could trigger a client event here to show success message
                -- and automatically log them in or return to login screen
            else
                outputDebugString("[DEBUG] Registration failed for user: " .. username)
                -- You could trigger a client event here to show error message
            end
        end)
    end)
end

-- Handle player quit to clean up account data
local function onPlayerQuit()
    local player = source
    local account = Account.getFromPlayer(player)
    
    if account then
        outputDebugString("[DEBUG] Player " .. getPlayerName(player) .. " with account " .. account.username .. " disconnected")
        -- Clean up any account-related data if needed
    end
end

-- Register events
addEvent(EVENTS.ACCOUNTS.LOGIN_ACCOUNT, true)
addEventHandler(EVENTS.ACCOUNTS.LOGIN_ACCOUNT, root, onLoginRequest)

addEvent(EVENTS.ACCOUNTS.REGISTER_ACCOUNT, true)
addEventHandler(EVENTS.ACCOUNTS.REGISTER_ACCOUNT, root, onRegisterRequest)

addEventHandler("onPlayerQuit", root, onPlayerQuit)
