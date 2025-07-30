function setAdminCommand(thePlayer, otherPlayer, level)
    local adminLevel = getAdminLevel(thePlayer)
    
    if adminLevel < 2 then
        outputChatBox("You do not have permission to set admin levels.", thePlayer, 255, 0, 0)
        return
    end
    
    if not otherPlayer or not level then
        outputChatBox("Usage: /setadmin <player> <level>", thePlayer, 255, 255, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(otherPlayer)
    
    if not targetPlayer then
        outputChatBox("Player not found: " .. otherPlayer, thePlayer, 255, 0, 0)
        return
    end
    
    level = tonumber(level)
    if not level or level < 0 or level > 2 then
        outputChatBox("Invalid admin level. Please specify a level between 0 and 2.", thePlayer, 255, 0, 0)
        return
    end
    
    local account = getElementData(targetPlayer, "account")
    if not account then
        outputChatBox("The target player does not have an account or is not loggedIn", thePlayer, 255, 0, 0)
        return
    end
    
    account.adminLevel = level
    setElementData(targetPlayer, "account", account)
    UpdateAccount(targetPlayer)
    outputChatBox("You have set " .. otherPlayer .. "'s admin level to " .. level .. ".", thePlayer, 0, 255, 0)
    
end


addCommandHandler("setadmin", setAdminCommand)

