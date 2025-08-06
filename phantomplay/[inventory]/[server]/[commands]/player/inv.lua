function onPlayerInventoryCommand(player, command, ...)
    local args = {...}
    local fullCommand = table.concat(args, " ")

     if #args < 3 then
        outputChatBox("Usage: /(i)nventory \"(use/drop)\" \"(slot)\" [quantity]", player, 255, 0, 0)
        outputChatBox("Use quotes around names with spaces.", player, 255, 255, 0)
        return
    end    

    local action, slot, quantity = parseQuotedArguments(fullCommand)

    if quantity == nil then quantity = 0 end

    local character = Character.getFromPlayer(player)
    local item = Inventory.getItemBySlot(character.id, slot, function(item)
        if not item then
            outputChatBox("Invalid item or slot.", player, 255, 0, 0)
            return
        end

        if item.quantity < quantity then
            outputChatBox("Not enough items in slot " .. slot .. ".", player, 255, 0, 0)
            return
        end

        if action == "use" then
            iprint("Using item: " .. item.name)
            item:use(player, quantity)
        elseif action == "drop" then
            item:drop(player, quantity)
        else
            outputChatBox("Invalid action. Use 'use' or 'drop'.", player, 255, 0, 0)
        end
    end)
end

addCommandHandler("i", onPlayerInventoryCommand)
addCommandHandler("inv", onPlayerInventoryCommand)
addCommandHandler("inventory", onPlayerInventoryCommand)
