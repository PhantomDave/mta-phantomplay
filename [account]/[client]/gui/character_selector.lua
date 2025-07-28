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
end


addEvent("openCharacterSelection",true)
addEventHandler("openCharacterSelection", root, 
    function (characters)
        if not wdwCharSelection then
            createCharacterSelectionWindow()
        end

        guiGridListClear(gridListCharacters)

        if characters and isTableNotEmpty(characters) then
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

addEventHandler("onClientResourceStart", getResourceRootElement(), 
	function ()
		createCharacterSelectionWindow()
        guiSetVisible(wdwCharSelection, false)
	end
)