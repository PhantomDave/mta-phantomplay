
function createRegisterWindow()
    registerWdv = guiCreateWindow(730, 322, 494, 427, "", false)
    guiWindowSetSizable(registerWdv, false)

    usernameLabel = guiCreateLabel(213, 100, 66, 16, "Username", false, registerWdv)
    guiLabelSetHorizontalAlign(usernameLabel, "center", false)
    guiLabelSetVerticalAlign(usernameLabel, "center")
    emailInput = guiCreateEdit(172, 196, 149, 37, "", false, registerWdv)
    emailLabel = guiCreateLabel(213, 170, 66, 16, "Email", false, registerWdv)
    guiLabelSetHorizontalAlign(emailLabel, "center", false)
    guiLabelSetVerticalAlign(emailLabel, "center")
    usernameInput = guiCreateEdit(172, 123, 149, 37, "", false, registerWdv)
    passwordInput = guiCreateEdit(172, 269, 149, 37, "", false, registerWdv)
    guiEditSetMasked(passwordInput, true)
    guiEditSetMaxLength(passwordInput, 65535)
    passwordLabel = guiCreateLabel(213, 243, 66, 16, "Password", false, registerWdv)
    guiLabelSetHorizontalAlign(passwordLabel, "center", false)
    guiLabelSetVerticalAlign(passwordLabel, "center")
    headerText = guiCreateLabel(0, 29, 494, 61, "Welcome to PhantomPlay\nPlease register", false, registerWdv)
    guiLabelSetHorizontalAlign(headerText, "center", false)
    guiLabelSetVerticalAlign(headerText, "center")
    registerButton = guiCreateButton(183, 332, 128, 43, "Register", false, registerWdv)
    backButton = guiCreateButton(16, 43, 96, 37, "< Back", false, registerWdv)

    guiSetVisible(registerWdv, false)

	addEventHandler(EVENTS.GUI.ON_GUI_CLICK, registerButton, clientSubmitRegister, false)
end

addEventHandler("onClientResourceStart", resourceRoot, createRegisterWindow)

function toggleRegisterWindow()
    if guiGetVisible(registerWdv) then
        guiSetVisible(registerWdv, false)
        showCursor(false)
    else
        guiSetVisible(registerWdv, true)
        showCursor(true)
    end
end

function clientSubmitRegister(button,state)
	if button == "left" and state == "up" then
		local username = guiGetText(emailInput)
		local password = guiGetText(passwordInput)
        local email = guiGetText(usernameInput)
		outputDebugString("Register button clicked with username: " .. username .. " and password: " .. password .. " and email: " .. email)
		if username and username ~= "" and password and password ~= "" and email and email ~= "" then
			triggerServerEvent(EVENTS.ACCOUNTS.REGISTER_ACCOUNT, localPlayer, username, email, password)
			outputChatBox("Attempting to register with username: " .. username)
            toggleRegisterWindow()
	        guiSetVisible(wdwLogin, true)

		else
			outputChatBox("Please enter a username, password, and email.")
		end
	end
end