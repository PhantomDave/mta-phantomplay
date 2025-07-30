function GetCharacterById(characterId, callback)
    Character.getById(characterId, function(character)
        if character then
            callback(character:getData())
        else
            callback(nil)
        end
    end)
end

function GetCharactersByAccountId(accountId, callback)
    Character.getByAccountId(accountId, function(characters)
        if characters then
            local characterData = {}
            for _, character in ipairs(characters) do
                table.insert(characterData, character:getData())
            end
            callback(characterData)
        else
            callback(nil)
        end
    end, accountId)
end

function CreateCharacter(name, age, gender, skin, accountId, callback)
    Character.createNew(name, age, gender, skin, accountId, function(character)
        if character then
            callback(true)
        else
            callback(false)
        end
    end, name, age, gender, skin, accountId)
end

function UpdateCharacter(characterData, callback)
    if not characterData or not characterData.id then
        outputDebugString("[DEBUG] UpdateCharacter called with invalid data.")
        if callback then callback(false) end
        return
    end
    
    Character.getById(characterData.id, function(character)
        if character then
            -- Update character properties
            character.name = characterData.name or character.name
            character.age = characterData.age or character.age
            character.gender = characterData.gender or character.gender
            character.skin = characterData.skin or character.skin
            character.cash = characterData.cash or character.cash
            character.bank = characterData.bank or character.bank
            
            character:save(callback)
        else
            outputDebugString("[DEBUG] Character not found for update.")
            if callback then callback(false) end
        end
    end, characterData.name, characterData.age, characterData.gender, characterData.skin, characterData.cash, characterData.bank, characterData.id)
end

-- Helper function to get character data from player (legacy compatibility)
function getCharacterData(player)
    local character = Character.getFromPlayer(player)
    if character then
        return character:getData()
    end
    return nil
end
