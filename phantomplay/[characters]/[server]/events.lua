function selectCharacterHandler(characterId)
	local player = client or source
	if not player then return end
    GetCharacterById(characterId, function(character)
        if not character then
            outputChatBox("Character not found.", player, 255, 0, 0)
            return
        end

        outputChatBox("You have selected character: " .. character.name, player, 0, 255, 0)
        setElementModel(player, character.skin)
        setPlayerMoney(player, character.cash)
        setPlayerName(player, character.name)
        setElementData(player, "character", character)
        triggerClientEvent(player, EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, player)
    end)
end

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, root, selectCharacterHandler)

function createCharacterHandler(characterData)
	local player = client or source
	if not player then return end
    CreateCharacter(characterData.name, characterData.age, characterData.gender, characterData.skin, characterData.accountId, function(success)
        if not success then
            outputChatBox("Failed to create character. Please try again.", player, 255, 0, 0)
            return
        end
        triggerClientEvent(player, EVENTS.CHARACTERS.OPEN_CHARACTER_CREATION, player)
        GetCharactersByAccountId(characterData.accountId, function(characters)
        local money = GetMoneyByNumberOfCharacters(#characters)
    
        local lastCharacter = characters[#characters]
        if money > 0 then
            lastCharacter.cash = money * 70 / 100
            lastCharacter.bank = money * 30 / 100
        else
            lastCharacter.cash = 0
            lastCharacter.bank = 0
        end
        UpdateCharacter(lastCharacter)
        triggerClientEvent(player, EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, player, characters)
        end)
    end)

end

addEvent(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, true)
addEventHandler(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, root, createCharacterHandler)
