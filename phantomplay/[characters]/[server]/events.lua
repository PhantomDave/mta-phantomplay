local function onCharacterSelected(characterId)
    local player = client
    if not player or not isElement(player) then
        return
    end
    
    Character.getById(characterId, function(character)
        if character then
            -- Associate character with player
            character:setPlayer(player)
            
            -- Spawn the character
            character:spawn(126.7494430542, 1105.8229980469, 14)
            
            outputDebugString("[DEBUG] Character " .. character.name .. " selected and spawned for player " .. getPlayerName(player))
            
            -- Clear character selection window
            triggerClientEvent(player, EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, player)
        else
            outputDebugString("[DEBUG] Character not found for selection: " .. tostring(characterId))
        end
    end)
end

-- Handle character creation from client
local function onCharacterCreated(characterData)
    local player = client
    if not player or not isElement(player) then
        return
    end
    
    -- Get the player's account
    local account = Account.getFromPlayer(player)
    if not account then
        outputDebugString("[DEBUG] No account found for character creation")
        return
    end
    
    -- Create the character
    Character.createNew(
        characterData.name,
        characterData.age,
        characterData.gender,
        characterData.skin,
        account.id,
        function(character)
            if character then
                outputDebugString("[DEBUG] Character created successfully: " .. character.name)
                
                -- Notify client of successful creation
                triggerClientEvent(player, EVENTS.CHARACTERS.ON_CHARACTER_CREATION_COMPLETED, player, character:getData())
                
                -- Automatically spawn the new character
                character:setPlayer(player)
                character:spawn(126.7494430542, 1105.8229980469, 14)
                
                -- Clear character creation window
                triggerClientEvent(player, EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, player)
            else
                outputDebugString("[DEBUG] Character creation failed for: " .. characterData.name)
                -- You could trigger a client event here to show error message
            end
        end
    )
end

-- Handle player login - show character selection or creation
local function onPlayerLoginSuccess()
    local player = source
    if not player or not isElement(player) then
        return
    end
    
    -- Get the player's account
    local account = Account.getFromPlayer(player)
    if not account then
        outputDebugString("[DEBUG] No account found for character selection")
        return
    end
    
    -- Get characters for this account
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
end

-- Handle player quit to clean up character data
local function onPlayerQuit()
    local player = source
    local character = Character.getFromPlayer(player)
    
    if character then
        -- Save character data before player quits
        character:save(function(success)
            if success then
                outputDebugString("[DEBUG] Character data saved for " .. character.name)
            else
                outputDebugString("[DEBUG] Failed to save character data for " .. character.name)
            end
        end)
    end
end

-- Register events
addEvent(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, root, onCharacterSelected)

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, root, onCharacterCreated)

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_DELETED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_DELETED, root, onCharacterDeleted)

addEvent(EVENTS.ACCOUNTS.ON_ACCOUNT_DATABASE_CONNECTED, true)

addEventHandler("onPlayerQuit", root, onPlayerQuit)
