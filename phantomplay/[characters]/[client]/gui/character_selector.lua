function createCharacterSelectionWindow()
	local sWidth, sHeight = guiGetScreenSize()

    local Width,Height = 376,259
	local X = (sWidth/2) - (Width/2)
	local Y = (sHeight/2) - (Height/2)

    wdwCharSelection = guiCreateWindow(X, Y, Width, Height, "Character Selection", false)

    gridListCharacters = guiCreateGridList(0.05, 0.1, 0.9, 0.7, true, wdwCharSelection)
    guiGridListAddColumn(gridListCharacters, "Character Name", 0.5)
    guiGridListAddColumn(gridListCharacters, "Age", 0.2)
    guiGridListAddColumn(gridListCharacters, "Gender", 0.2)

    local btnCreate = guiCreateButton(0.05, 0.85, 0.4, 0.1, "Create Character", true, wdwCharSelection)
    local btnSelect = guiCreateButton(0.55, 0.85, 0.4, 0.1, "Select Character", true, wdwCharSelection)

    addEventHandler(EVENTS.GUI.ON_GUI_CLICK, btnCreate, OnCreateCharacter, false)
    addEventHandler(EVENTS.GUI.ON_GUI_CLICK, btnSelect, OnSelectCharacter, false)
end

function OnCreateCharacter(button, state)
    if button == "left" and state == "up" then
        -- Trigger the client event to open the character creation window
        triggerEvent(EVENTS.CHARACTERS.OPEN_CHARACTER_CREATION, localPlayer)
        guiSetVisible(wdwCharSelection, false)
    end
end

function OnSelectCharacter(button, state)
    if button == "left" and state == "up" then
        local selectedRow = guiGridListGetSelectedItem(gridListCharacters)
        if selectedRow ~= -1 then
            local characterName = guiGridListGetItemText(gridListCharacters, selectedRow, 1)
            outputChatBox("You have selected character: " .. characterName)
            -- Here you would typically trigger a server event to handle the character selection
            triggerServerEvent(EVENTS.CHARACTERS.ON_CHARACTER_SELECTED, localPlayer, Characters[selectedRow+1].id)
            setCharacterData(Characters[selectedRow+1])
        else
            outputChatBox("Please select a character first.")
        end
    end
end


addEvent(EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, true)
addEventHandler(EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, localPlayer, 
    function (characters)
        if not wdwCharSelection then
            createCharacterSelectionWindow()
        end

        if(guiGetVisible(wdwCharCreation)) then
            guiSetVisible(wdwCharCreation, false)
        end

        guiGridListClear(gridListCharacters)
        
        if characters and isTableNotEmpty(characters) then
            Characters = characters or {}
            for _, char in ipairs(characters) do
                local row = guiGridListAddRow(gridListCharacters)
                guiGridListSetItemText(gridListCharacters, row, 1, char.name, false, false)
                guiGridListSetItemText(gridListCharacters, row, 2, tostring(char.age), false, false)
                guiGridListSetItemText(gridListCharacters, row, 3, char.gender, false, false)
            end
        end

        guiSetVisible(wdwCharSelection, true)
        showCursor(true)
        guiSetInputEnabled(true)
    end
)

addEvent(EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, true)
addEventHandler(EVENTS.GUI.CLEAR_CHARACTER_SELECTION_WINDOW, localPlayer,
    function ()
        if wdwCharSelection then
            guiSetVisible(wdwCharSelection, false)
            showCursor(false)
            guiSetInputEnabled(false)
        end
    end
)