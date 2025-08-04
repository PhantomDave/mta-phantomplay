function createLoginWindow()
	local X = 0.375
	local Y = 0.375
	local Width = 0.25
	local Height = 0.25

	wdwLogin = guiCreateWindow(X, Y, Width, Height, "Please Log In", true)
	
	X = 0.0825
	Y = 0.2
	Width = 0.25
	Height = 0.25
	guiCreateLabel(X, Y, Width, Height, "Username", true, wdwLogin)
	Y = 0.5
	guiCreateLabel(X, Y, Width, Height, "Password", true, wdwLogin)
	

	X = 0.415
	Y = 0.2
	Width = 0.5
	Height = 0.1
	edtUser = guiCreateEdit(X, Y, Width, Height, "", true, wdwLogin)
	Y = 0.5
	edtPass = guiCreateEdit(X, Y, Width, Height, "", true, wdwLogin)
	guiEditSetMasked(edtPass, true)
	guiEditSetMaxLength(edtUser, 50)
	guiEditSetMaxLength(edtPass, 50)
	
	X = 0.415
	Y = 0.7
	Width = 0.25
	Height = 0.2
	local btnLogin = guiCreateButton(X, Y, Width, Height, "Log In", true, wdwLogin)
	local btnRegister = guiCreateButton(X + 0.3, Y, Width, Height, "Register", true, wdwLogin)
	addEventHandler(EVENTS.GUI.ON_GUI_CLICK, btnLogin, clientSubmitLogin, false)	
	addEventHandler(EVENTS.GUI.ON_GUI_CLICK, btnRegister, clientRegisterWindow, false)	
	guiSetVisible(wdwLogin, false)
end

function clientRegisterWindow(button,state)
	if button == "left" and state == "up" then
		toggleRegisterWindow()
		guiSetVisible(wdwLogin, false)
	end
end


function clientSubmitLogin(button,state)
	if button == "left" and state == "up" then
		local username = guiGetText(edtUser)
		local password = guiGetText(edtPass)
		outputDebugString("Login button clicked with username: " .. username .. " and password: " .. password)
		
		if username and username ~= "" and password and password ~= "" then
			triggerServerEvent(EVENTS.ACCOUNTS.LOGIN_ACCOUNT, localPlayer, username, password)
			outputChatBox("Attempting to log in with username: " .. username)
		else
			outputChatBox("Please enter a username and password.")
		end
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(), 
	function ()
		createLoginWindow()
	    if (wdwLogin ~= nil) then
			guiSetVisible(wdwLogin, true)
		else
			outputChatBox("An unexpected error has occurred and the login GUI has not been created.")
	    end 
	    showCursor(true)
		guiSetInputEnabled(true)
	end
)

addEvent(EVENTS.GUI.CLEAR_LOGIN_WINDOW,true)
addEventHandler(EVENTS.GUI.CLEAR_LOGIN_WINDOW, localPlayer,
	function (account)
		outputChatBox("You have successfully logged in. The login window will now close.")
		setAccountData(account)
		if (wdwLogin ~= nil) then
			guiSetVisible(wdwLogin, false)
		end
	end
)




