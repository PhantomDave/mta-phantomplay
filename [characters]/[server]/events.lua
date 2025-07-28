function selectCharacterHandler(characterId)
    outputDebugString("[DEBUG] selectCharacterHandler called with characterId: " .. tostring(characterId))
end
addEvent(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, root, selectCharacterHandler)

function createCharacterHandler(characterData)
    CreateCharacter(characterData.name, characterData.age, characterData.gender, characterData.skin, characterData.accountId)
    
end

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, root, createCharacterHandler)
