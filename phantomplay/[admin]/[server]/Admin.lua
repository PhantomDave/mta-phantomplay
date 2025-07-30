-- Admin class using MTA OOP system
-- Based on https://wiki.multitheftauto.com/wiki/OOP_Introduction

Admin = {}
Admin.__index = Admin

-- Admin levels
Admin.LEVELS = {
    PLAYER = 0,
    MODERATOR = 1,
    ADMIN = 2,
    SUPER_ADMIN = 3
}

-- Constructor
function Admin:create(player)
    local instance = {}
    setmetatable(instance, Admin)
    
    instance.player = player
    instance.account = Account.getFromPlayer(player)
    
    return instance
end

-- Static method to get admin instance from player
function Admin.getFromPlayer(player)
    if not isElement(player) then
        return nil
    end
    
    local account = Account.getFromPlayer(player)
    if not account then
        return nil
    end
    
    return Admin:create(player)
end

-- Instance method to get admin level
function Admin:getLevel()
    if not self.account then
        return Admin.LEVELS.PLAYER
    end
    return self.account.adminLevel or Admin.LEVELS.PLAYER
end

-- Instance method to check if player has minimum admin level
function Admin:hasLevel(requiredLevel)
    return self:getLevel() >= requiredLevel
end

-- Instance method to check if player is moderator or higher
function Admin:isModerator()
    return self:hasLevel(Admin.LEVELS.MODERATOR)
end

-- Instance method to check if player is admin or higher
function Admin:isAdmin()
    return self:hasLevel(Admin.LEVELS.ADMIN)
end

-- Instance method to check if player is super admin
function Admin:isSuperAdmin()
    return self:hasLevel(Admin.LEVELS.SUPER_ADMIN)
end

-- Instance method to set admin level
function Admin:setLevel(level, callback)
    if not self.account then
        outputDebugString("[DEBUG] Cannot set admin level - no account found")
        if callback then callback(false) end
        return
    end
    
    if level < Admin.LEVELS.PLAYER or level > Admin.LEVELS.SUPER_ADMIN then
        outputDebugString("[DEBUG] Invalid admin level: " .. tostring(level))
        if callback then callback(false) end
        return
    end
    
    self.account.adminLevel = level
    self.account:save(function(success)
        if success then
            outputDebugString("[DEBUG] Admin level updated for " .. (self.account.username or "unknown"))
            if callback then callback(true) end
        else
            outputDebugString("[DEBUG] Failed to update admin level for " .. (self.account.username or "unknown"))
            if callback then callback(false) end
        end
    end)
end

-- Instance method to get level name
function Admin:getLevelName()
    local level = self:getLevel()
    if level == Admin.LEVELS.SUPER_ADMIN then
        return "Super Admin"
    elseif level == Admin.LEVELS.ADMIN then
        return "Admin"
    elseif level == Admin.LEVELS.MODERATOR then
        return "Moderator"
    else
        return "Player"
    end
end

-- Static method to get player from partial name
function Admin.getPlayerFromPartialName(partialName)
    if not partialName or partialName == "" then
        return nil
    end
    
    partialName = string.lower(partialName)
    local players = getElementsByType("player")
    local matches = {}
    
    -- First, try exact match
    for _, player in ipairs(players) do
        local playerName = string.lower(getPlayerName(player))
        if playerName == partialName then
            return player
        end
    end
    
    -- Then try partial matches
    for _, player in ipairs(players) do
        local playerName = string.lower(getPlayerName(player))
        if string.find(playerName, partialName, 1, true) then
            table.insert(matches, player)
        end
    end
    
    if #matches == 1 then
        return matches[1]
    elseif #matches > 1 then
        return nil, "Multiple players found"
    else
        return nil, "Player not found"
    end
end

-- Static method to check admin permission for command
function Admin.checkPermission(player, requiredLevel, commandName)
    local admin = Admin.getFromPlayer(player)
    
    if not admin then
        outputChatBox("You must be logged in to use admin commands.", player, 255, 0, 0)
        return false
    end
    
    if not admin:hasLevel(requiredLevel) then
        outputChatBox("You don't have permission to use " .. (commandName or "this command") .. ". Required level: " .. requiredLevel, player, 255, 0, 0)
        return false
    end
    
    return true
end

-- Static method to log admin action
function Admin.logAction(admin, action, target)
    local logMessage = "[ADMIN] " .. (admin.account.username or "Unknown") .. " (" .. admin:getLevelName() .. ") " .. action
    if target then
        logMessage = logMessage .. " on " .. (getPlayerName(target) or "Unknown")
    end
    
    outputDebugString(logMessage)
    -- You could also save this to a database or file for persistent logging
end
