function registerHandler(username, email, password)
	if not client then return end
	local account = GetUserByEmailOrUsername(email, username, function(account)
		if not account then
			outputDebugString("[DEBUG] Registering new account with email: " .. email)
			RegisterUser(username, email, password)
		else
			outputDebugString("[DEBUG] Email is already registered: " .. email)
			outputChatBox("Email is already registered. Please use a different email.", client)
		end
	end)	
end

addEvent(EVENTS.ACCOUNTS.REGISTER_ACCOUNT,true)
addEventHandler(EVENTS.ACCOUNTS.REGISTER_ACCOUNT,root,registerHandler)