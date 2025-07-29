function selectCharacterHandler(characterId)
    if not client then return end
    
    GetCharacterById(characterId, function(character)
        if not character then
            outputChatBox("Character not found.", client, 255, 0, 0)
            return
        end

        outputChatBox("You have selected character: " .. character.name, client, 0, 255, 0)
        setElementModel(client, character.skin)
        triggerClientEvent(client, EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, client)
    end)
end

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, root, selectCharacterHandler)

function createCharacterHandler(characterData)
    if not client then return end
    
    CreateCharacter(characterData.name, characterData.age, characterData.gender, characterData.skin, characterData.accountId, function(success)
        if success then
            outputChatBox("Character created successfully!", client, 0, 255, 0)
            -- Get account data to reload character selection
            local account = getAccountData() -- You'll need to implement this or get account ID from somewhere
            if account and account.id then
                GetCharactersByAccountId(account.id, function(characters)
                    triggerClientEvent(client, EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, client, characters)
                end)
            else
                triggerClientEvent(client, EVENTS.CHARACTERS.OPEN_CHARACTER_CREATION, client)
            end
        else
            outputChatBox("Failed to create character. Please try again.", client, 255, 0, 0)
        end
    end)
end

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, root, createCharacterHandler)
