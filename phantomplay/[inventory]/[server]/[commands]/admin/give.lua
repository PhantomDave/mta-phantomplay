function givePlayerItem(player, command, otherName, itemName, quantity)

    local account = Account.getFromPlayer(player)
    
    if not account or account:getAdminLevel() < 2 then
        outputChatBox("You do not have permission to use this command.", player, 255, 0, 0)
        return
    end

    if not itemName or not quantity then
        outputChatBox("Usage: /giveitem [playername] [itemName] [quantity]", player, 255, 0, 0)
        return
    end

    local targetPlayer = otherName and getPlayerFromName(otherName)
    if not targetPlayer then
        outputChatBox("Player not found. Please specify a valid player name.", player, 255, 0, 0)
        return
    end

    local characterID = Inventory.getCharacterID(targetPlayer)
    if not characterID then
        outputChatBox("Target player does not have a character assigned.", player, 255, 0, 0)
        return
    end

    local item = Item.GetItemFromName(itemName)
    if not item then
        outputChatBox("Item not found. Please specify a valid item name.", player, 255, 0, 0)
        return
    end

    Inventory.addItem(characterID, item.name, tonumber(quantity) or 1, function(success)
        if success then
            outputChatBox("You have been given " .. quantity .. " " .. item.name .. "(s).", player, 0, 255, 0)
            Inventory.updateInventoryGUI(targetPlayer)
        else
            outputChatBox("Failed to give item. Please try again.", player, 255, 0, 0)
        end
    end)
end

addCommandHandler("giveitem", givePlayerItem)