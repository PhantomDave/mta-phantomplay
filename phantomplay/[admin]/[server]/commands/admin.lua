-- Admin commands using Admin OOP class

-- Command to set admin level
function setAdminCommand(thePlayer, commandName, otherPlayerName, level)
    -- Check if the player has permission to use this command
    if not Admin.checkPermission(thePlayer, Admin.LEVELS.ADMIN, "setadmin") then
        return
    end
    
    if not otherPlayerName or not level then
        outputChatBox("Usage: /setadmin <player> <level>", thePlayer, 255, 255, 0)
        outputChatBox("Levels: 0=Player, 1=Moderator, 2=Admin, 3=Super Admin", thePlayer, 255, 255, 0)
        return
    end
    
    -- Find the target player
    local targetPlayer, error = Admin.getPlayerFromPartialName(otherPlayerName)
    if not targetPlayer then
        outputChatBox(error or ("Player not found: " .. otherPlayerName), thePlayer, 255, 0, 0)
        return
    end
    
    level = tonumber(level)
    if not level or level < Admin.LEVELS.PLAYER or level > Admin.LEVELS.SUPER_ADMIN then
        outputChatBox("Invalid admin level. Please specify a level between 0 and 3.", thePlayer, 255, 0, 0)
        return
    end
    
    -- Get admin instances
    local admin = Admin.getFromPlayer(thePlayer)
    local targetAdmin = Admin.getFromPlayer(targetPlayer)
    
    if not targetAdmin or not targetAdmin.account then
        outputChatBox("The target player does not have an account or is not logged in.", thePlayer, 255, 0, 0)
        return
    end
    
    -- Prevent setting level higher than own level (except super admins)
    if not admin:isSuperAdmin() and level >= admin:getLevel() then
        outputChatBox("You cannot set an admin level equal to or higher than your own.", thePlayer, 255, 0, 0)
        return
    end
    
    -- Set the admin level
    targetAdmin:setLevel(level, function(success)
        if success then
            local targetName = getPlayerName(targetPlayer)
            local levelName = targetAdmin:getLevelName()
            
            outputChatBox("You have set " .. targetName .. "'s admin level to " .. level .. " (" .. levelName .. ").", thePlayer, 0, 255, 0)
            outputChatBox("Your admin level has been set to " .. level .. " (" .. levelName .. ") by " .. getPlayerName(thePlayer), targetPlayer, 0, 255, 0)
            
            -- Log the action
            Admin.logAction(admin, "set admin level " .. level .. " for " .. targetName)
        else
            outputChatBox("Failed to set admin level.", thePlayer, 255, 0, 0)
        end
    end)
end

-- Command to check admin level
function adminLevelCommand(thePlayer, commandName, otherPlayerName)
    local targetPlayer = thePlayer
    
    -- If another player name is provided, check their level (requires moderator+)
    if otherPlayerName then
        if not Admin.checkPermission(thePlayer, Admin.LEVELS.MODERATOR, "adminlevel") then
            return
        end
        
        local target, error = Admin.getPlayerFromPartialName(otherPlayerName)
        if not target then
            outputChatBox(error or ("Player not found: " .. otherPlayerName), thePlayer, 255, 0, 0)
            return
        end
        targetPlayer = target
    end
    
    local admin = Admin.getFromPlayer(targetPlayer)
    if not admin then
        outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
        return
    end
    
    local level = admin:getLevel()
    local levelName = admin:getLevelName()
    local targetName = getPlayerName(targetPlayer)
    
    if targetPlayer == thePlayer then
        outputChatBox("Your admin level: " .. level .. " (" .. levelName .. ")", thePlayer, 0, 255, 255)
    else
        outputChatBox(targetName .. "'s admin level: " .. level .. " (" .. levelName .. ")", thePlayer, 0, 255, 255)
    end
end

-- Command to kick player (moderator+)
function kickCommand(thePlayer, commandName, targetName, ...)
    if not Admin.checkPermission(thePlayer, Admin.LEVELS.MODERATOR, "kick") then
        return
    end
    
    if not targetName then
        outputChatBox("Usage: /kick <player> [reason]", thePlayer, 255, 255, 0)
        return
    end
    
    local targetPlayer, error = Admin.getPlayerFromPartialName(targetName)
    if not targetPlayer then
        outputChatBox(error or ("Player not found: " .. targetName), thePlayer, 255, 0, 0)
        return
    end
    
    local reason = table.concat({...}, " ")
    if reason == "" then
        reason = "No reason specified"
    end
    
    local admin = Admin.getFromPlayer(thePlayer)
    local targetPlayerName = getPlayerName(targetPlayer)
    
    -- Prevent kicking higher level admins
    local targetAdmin = Admin.getFromPlayer(targetPlayer)
    if targetAdmin and targetAdmin:getLevel() >= admin:getLevel() then
        outputChatBox("You cannot kick an admin with equal or higher level.", thePlayer, 255, 0, 0)
        return
    end
    
    kickPlayer(targetPlayer, thePlayer, reason)
    outputChatBox("Player " .. targetPlayerName .. " has been kicked. Reason: " .. reason, thePlayer, 0, 255, 0)
    
    -- Log the action
    Admin.logAction(admin, "kicked " .. targetPlayerName .. " (Reason: " .. reason .. ")")
end

-- Command to ban player (admin+)
function banCommand(thePlayer, commandName, targetName, ...)
    if not Admin.checkPermission(thePlayer, Admin.LEVELS.ADMIN, "ban") then
        return
    end
    
    if not targetName then
        outputChatBox("Usage: /ban <player> [reason]", thePlayer, 255, 255, 0)
        return
    end
    
    local targetPlayer, error = Admin.getPlayerFromPartialName(targetName)
    if not targetPlayer then
        outputChatBox(error or ("Player not found: " .. targetName), thePlayer, 255, 0, 0)
        return
    end
    
    local reason = table.concat({...}, " ")
    if reason == "" then
        reason = "No reason specified"
    end
    
    local admin = Admin.getFromPlayer(thePlayer)
    local targetPlayerName = getPlayerName(targetPlayer)
    
    -- Prevent banning higher level admins
    local targetAdmin = Admin.getFromPlayer(targetPlayer)
    if targetAdmin and targetAdmin:getLevel() >= admin:getLevel() then
        outputChatBox("You cannot ban an admin with equal or higher level.", thePlayer, 255, 0, 0)
        return
    end
    
    banPlayer(targetPlayer, true, false, true, thePlayer, reason)
    outputChatBox("Player " .. targetPlayerName .. " has been banned. Reason: " .. reason, thePlayer, 0, 255, 0)
    
    -- Log the action
    Admin.logAction(admin, "banned " .. targetPlayerName .. " (Reason: " .. reason .. ")")
end

-- Register command handlers
addCommandHandler("setadmin", setAdminCommand)
addCommandHandler("adminlevel", adminLevelCommand)
addCommandHandler("kick", kickCommand)
addCommandHandler("ban", banCommand)
