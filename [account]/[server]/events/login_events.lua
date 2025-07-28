function loginHandler(username,password)
	if not client then return end
	local account = loginUser(username, password)

	if isTableNotEmpty(account) then
		outputDebugString("[DEBUG] Player " .. getPlayerName(client) .. " has logged in with account ID: " .. account.id)
		spawnPlayer(client, 1959.55, -1714.46, 10)
		fadeCamera(client, true)
		setCameraTarget(client, client)
		outputChatBox("Welcome to My Server.", client)
		triggerClientEvent("clearLoginWindow", client, account)
		triggerClientEvent(client, EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, client, GetCharactersByAccountId(account.id))
	else
		-- if the username or password are not correct, output a message to the player
		outputChatBox("Invalid username and password. Please re-connect and try again.", client)
	end			
end

addEvent(EVENTS.ACCOUNTS.LOGIN_ACCOUNT, true)
addEventHandler(EVENTS.ACCOUNTS.LOGIN_ACCOUNT, root, loginHandler)