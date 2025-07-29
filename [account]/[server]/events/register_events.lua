function registerHandler(email ,password)
	if not client then return end
	
	GetUserByEmail(email, function(account)
		if not isTableNotEmpty(account) then
			outputChatBox("Registering new account with email: " .. email, client)
			RegisterUser(email, password, function(success)
				if success then
					outputChatBox("Registration successful! You can now login.", client)
				else
					outputChatBox("Registration failed. Please try again.", client)
				end
			end)
		else
			outputChatBox("Email is already registered. Please use a different email.", client)
		end
	end)
end

addEvent("submitRegister",true)
addEventHandler("submitRegister",root,registerHandler)