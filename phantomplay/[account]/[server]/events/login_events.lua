
function loginHandler(username, password)
	local player = client or source
	if not player then return end
	loginUser(username, password, function(account)
		if isTableNotEmpty(account) then
			outputDebugString("[DEBUG] Player " .. account.email .. " has logged in with account ID: " .. account.id)
			spawnPlayer(player, 1959.55, -1714.46, 10)
			fadeCamera(player, true)
			setCameraTarget(player, player)
			outputChatBox("Welcome to My Server.", player)
			triggerClientEvent(player, EVENTS.GUI.CLEAR_LOGIN_WINDOW, player, account)
			GetCharactersByAccountId(account.id, function(characters)
				triggerClientEvent(player, EVENTS.CHARACTERS.OPEN_CHARACTER_SELECTION, player, characters)
			end)
		else
			-- if the username or password are not correct, output a message to the player
			outputChatBox("Invalid username and password. Please re-connect and try again.", player)
		end
	end)
end

addEvent(EVENTS.ACCOUNTS.LOGIN_ACCOUNT, true)
addEventHandler(EVENTS.ACCOUNTS.LOGIN_ACCOUNT, root, loginHandler)