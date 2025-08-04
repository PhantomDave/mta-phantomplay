local chatRadius = 20

function onPlayerChatSendMessageToNearbyPlayers(messageText, messageType)
	local normalMessage = (messageType == 0 or messageType == 1)

	if (not normalMessage) then
		outputChatBox("This chat is disabled.", source, 255, 0, 0)
		return false
	end

	local playerName = getPlayerName(source)
	local playerX, playerY, playerZ = getElementPosition(source)
	local playerInterior = getElementInterior(source)
	local playerDimension = getElementDimension(source)
    if(playerDimension ~= 0) then
        chatRadius = 15
    end
	local nearbyPlayers = getElementsWithinRange(playerX, playerY, playerZ, chatRadius, "player", playerInterior, playerDimension)
	local messageToOutput = playerName..": "..messageText

	outputChatBox(messageToOutput, nearbyPlayers, 255, 255, 255, true) 
    outputServerLog("[CHAT] " .. messageToOutput)
	cancelEvent() 
end
addEventHandler("onPlayerChat", root, onPlayerChatSendMessageToNearbyPlayers)