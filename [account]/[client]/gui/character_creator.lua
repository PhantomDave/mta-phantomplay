function createCharacterCreationWindow()
	local X = 0.375
	local Y = 0.375
	local Width = 0.25
	local Height = 0.25

    wdwCharCreation = guiCreateWindow(X, Y, Width, Height, "Character Creation", true)

	X = 0.0825
	Y = 0.2
	Width = 0.25
	Height = 0.25
    guiCreateLabel(X, Y, Width, Height, "Character Name", true, wdwCharCreation)
    guiCreateLabel(X, Y + 0.10, Width, Height, "Age", true, wdwCharCreation)
    guiCreateLabel(X, Y + 0.20, Width, Height, "Gender", true, wdwCharCreation)
    guiCreateLabel(X, Y + 0.30, Width, Height, "Skin ID", true, wdwCharCreation)

    X = 0.415
	Y = 0.2
	Width = 0.5
	Height = 0.1
    edtCharName = guiCreateEdit(X, Y, Width, Height, "", true, wdwCharCreation)
    edtCharAge = guiCreateEdit(X, Y + 0.10, Width, Height, "", true, wdwCharCreation)
    edtCharGender = guiCreateEdit(X, Y + 0.20, Width, Height, "", true, wdwCharCreation)
    edtCharSkin = guiCreateEdit(X, Y + 0.30, Width, Height, "", true, wdwCharCreation)

    guiEditSetMaxLength(edtCharName, 50)
    guiEditSetMaxLength(edtCharAge, 3)
    guiEditSetMaxLength(edtCharGender, 16)
    guiEditSetMaxLength(edtCharSkin, 3)

    local btnCreate = guiCreateButton(0.05, 0.85, 0.4, 0.1, "Create Character", true, wdwCharCreation)

    addEventHandler(EVENTS.GUI.ON_GUI_CLICK, btnCreate, CreateCharacter, false)
end

function CreateCharacter(button, state)
    if button == "left" and state == "up" then
        local name = guiGetText(edtCharName)
        local age = tonumber(guiGetText(edtCharAge))
        local gender = guiGetText(edtCharGender)
        local skin = guiGetText(edtCharSkin)

        if name and age and gender and skin then
			triggerServerEvent(EVENTS.CHARACTERS.ON_CHARACTER_CREATED, localPlayer, {
                name = name,
                age = age,
                gender = gender,
                skin = skin,
                accountId = getAccountData().id
            })
        else
            outputChatBox("Please fill in all fields.")
        end
    end
end

addEvent(EVENTS.CHARACTERS.OPEN_CHARACTER_CREATION, false)
addEventHandler(EVENTS.CHARACTERS.OPEN_CHARACTER_CREATION, localPlayer, 
    function ()
        if not wdwCharCreation then
            createCharacterCreationWindow()
        end

        guiSetVisible(wdwCharCreation, true)
    end
)