function loginHandler(username,password)
	if not client then return end
	local account = loginUser(username, password)

	if isTableNotEmpty(account) then
		-- the player has successfully logged in, so spawn them
		spawnPlayer(client, 1959.55, -1714.46, 10)
		fadeCamera(client, true)
		setCameraTarget(client, client)
		outputChatBox("Welcome to My Server.", client)
		triggerClientEvent("clearLoginWindow", client)
	else
		-- if the username or password are not correct, output a message to the player
		outputChatBox("Invalid username and password. Please re-connect and try again.", client)
	end			
end

addEvent("submitLogin",true)
addEventHandler("submitLogin",root,loginHandler)