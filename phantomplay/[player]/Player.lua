-- Player class using MTA OOP system
-- Based on https://wiki.multitheftauto.com/wiki/OOP_Introduction
-- This class manages player state and integrates with Account, Character, and other systems

Player = {}
Player.__index = Player

-- Static player registry
Player.registry = {}

-- Constructor
function Player:create(playerElement)
    local instance = {}
    setmetatable(instance, Player)
    
    instance.element = playerElement
    instance.account = nil
    instance.character = nil
    instance.loginTime = getRealTime().timestamp
    instance.lastActivity = getRealTime().timestamp
    instance.isAFK = false
    instance.permissions = {}
    instance.temporaryData = {}
    
    -- Register the player
    Player.registry[playerElement] = instance
    setElementData(playerElement, "playerInstance", instance)
    
    return instance
end

-- Static method to get Player instance from element
function Player.getFromElement(playerElement)
    if not isElement(playerElement) or getElementType(playerElement) ~= "player" then
        return nil
    end
    
    local instance = Player.registry[playerElement]
    if not instance then
        -- Create new instance if doesn't exist
        instance = Player:create(playerElement)
    end
    
    return instance
end

-- Static method to get all online players
function Player.getAllOnline()
    local players = {}
    for element, playerInstance in pairs(Player.registry) do
        if isElement(element) then
            table.insert(players, playerInstance)
        end
    end
    return players
end

-- Instance method to set account
function Player:setAccount(account)
    self.account = account
    if account then
        account:setPlayer(self.element)
        outputDebugString("[DEBUG] Account " .. account.username .. " associated with player " .. getPlayerName(self.element))
    end
end

-- Instance method to get account
function Player:getAccount()
    return self.account
end

-- Instance method to set character
function Player:setCharacter(character)
    self.character = character
    if character then
        character:setPlayer(self.element)
        outputDebugString("[DEBUG] Character " .. character.name .. " associated with player " .. getPlayerName(self.element))
    end
end

-- Instance method to get character
function Player:getCharacter()
    return self.character
end

-- Instance method to check if player is logged in
function Player:isLoggedIn()
    return self.account ~= nil
end

-- Instance method to check if player has character selected
function Player:hasCharacter()
    return self.character ~= nil
end

-- Instance method to update activity
function Player:updateActivity()
    self.lastActivity = getRealTime().timestamp
    if self.isAFK then
        self.isAFK = false
        outputChatBox("Welcome back! You are no longer AFK.", self.element, 0, 255, 0)
    end
end

-- Instance method to set AFK status
function Player:setAFK(isAFK)
    if self.isAFK ~= isAFK then
        self.isAFK = isAFK
        if isAFK then
            outputChatBox("You are now marked as AFK.", self.element, 255, 255, 0)
        end
    end
end

-- Instance method to check if player is AFK
function Player:isPlayerAFK()
    local currentTime = getRealTime().timestamp
    local afkThreshold = 300 -- 5 minutes
    
    if currentTime - self.lastActivity > afkThreshold then
        self:setAFK(true)
        return true
    end
    return self.isAFK
end

-- Instance method to get play time (current session)
function Player:getSessionTime()
    return getRealTime().timestamp - self.loginTime
end

-- Instance method to set permission
function Player:setPermission(permission, value)
    self.permissions[permission] = value
end

-- Instance method to check permission
function Player:hasPermission(permission)
    -- Check temporary permissions first
    if self.permissions[permission] ~= nil then
        return self.permissions[permission]
    end
    
    -- Check account admin level
    if self.account then
        local admin = Admin.getFromPlayer(self.element)
        if admin then
            -- Admin permissions
            if permission == "kick" then
                return admin:isModerator()
            elseif permission == "ban" then
                return admin:isAdmin()
            elseif permission == "setadmin" then
                return admin:isAdmin()
            elseif permission == "createhouse" then
                return admin:isAdmin()
            end
        end
    end
    
    return false
end

-- Instance method to send message
function Player:sendMessage(message, r, g, b)
    outputChatBox(message, self.element, r or 255, g or 255, b or 255)
end

-- Instance method to send private message
function Player:sendPrivateMessage(fromPlayer, message)
    local fromName = getPlayerName(fromPlayer.element)
    local toName = getPlayerName(self.element)
    
    outputChatBox("[PM from " .. fromName .. "]: " .. message, self.element, 255, 255, 0)
    outputChatBox("[PM to " .. toName .. "]: " .. message, fromPlayer.element, 255, 255, 0)
    
    outputDebugString("[PM] " .. fromName .. " -> " .. toName .. ": " .. message)
end

-- Instance method to teleport player
function Player:teleportTo(x, y, z, interior, dimension)
    interior = interior or 0
    dimension = dimension or 0
    
    setElementPosition(self.element, x, y, z)
    setElementInterior(self.element, interior)
    setElementDimension(self.element, dimension)
    
    outputDebugString("[DEBUG] Player " .. getPlayerName(self.element) .. " teleported to " .. x .. ", " .. y .. ", " .. z)
end

-- Instance method to get position
function Player:getPosition()
    local x, y, z = getElementPosition(self.element)
    return {x = x, y = y, z = z}
end

-- Instance method to set temporary data
function Player:setTempData(key, value)
    self.temporaryData[key] = value
end

-- Instance method to get temporary data
function Player:getTempData(key)
    return self.temporaryData[key]
end

-- Instance method to save player state
function Player:save(callback)
    local saved = 0
    local toSave = 0
    
    local function checkComplete()
        saved = saved + 1
        if saved >= toSave then
            if callback then callback(true) end
        end
    end
    
    -- Save account if exists
    if self.account then
        toSave = toSave + 1
        self.account:save(checkComplete)
    end
    
    -- Save character if exists
    if self.character then
        toSave = toSave + 1
        self.character:save(checkComplete)
    end
    
    -- If nothing to save, call callback immediately
    if toSave == 0 then
        if callback then callback(true) end
    end
end

-- Static method to cleanup player on disconnect
function Player.onPlayerQuit(playerElement)
    local playerInstance = Player.registry[playerElement]
    if playerInstance then
        -- Save player data before removing
        playerInstance:save(function(success)
            if success then
                outputDebugString("[DEBUG] Player data saved successfully for " .. getPlayerName(playerElement))
            else
                outputDebugString("[ERROR] Failed to save player data for " .. getPlayerName(playerElement))
            end
            
            -- Clean up registry
            Player.registry[playerElement] = nil
        end)
    end
end

-- Static method to handle player activity
function Player.onPlayerActivity(playerElement)
    local playerInstance = Player.getFromElement(playerElement)
    if playerInstance then
        playerInstance:updateActivity()
    end
end

-- Register event handlers
addEventHandler("onPlayerQuit", root, function()
    Player.onPlayerQuit(source)
end)

addEventHandler("onPlayerChat", root, function()
    Player.onPlayerActivity(source)
end)

addEventHandler("onPlayerCommand", root, function()
    Player.onPlayerActivity(source)
end)
