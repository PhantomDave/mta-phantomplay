function selectCharacterHandler(characterId)
    if not client then return end
    local character = GetCharacterById(characterId)
    if not character then
        outputChatBox("Character not found.", client, 255, 0, 0)
        return
    end

    outputChatBox("You have selected character: " .. character.name, client, 0, 255, 0)
    setElementModel(client, character.skin)
    triggerClientEvent(client, EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, client)
end

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, root, selectCharacterHandler)

function createCharacterHandler(characterData)
    if not client then return end
    CreateCharacter(characterData.name, characterData.age, characterData.gender, characterData.skin, characterData.accountId)
    triggerClientEvent(client, EVENTS.CHARACTERS.OPEN_CHARACTER_CREATION, client)
	triggerClientEvent(client, EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, client, GetCharactersByAccountId(account.id))

end

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, root, createCharacterHandler)
