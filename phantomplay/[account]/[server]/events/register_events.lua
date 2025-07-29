function registerHandler(email ,password)
	if not client then return end
	local account = GetUserByEmail(email )

	if not isTableNotEmpty(account) then
        outputChatBox("Registering new account with email: " .. email, client)
        RegisterUser(email, password)
	else
		outputChatBox("Email is already registered. Please use a different email.", client)
	end			
end

addEvent(EVENTS.ACCOUNTS.REGISTER_ACCOUNT,true)
addEventHandler(EVENTS.ACCOUNTS.REGISTER_ACCOUNT,root,registerHandler)