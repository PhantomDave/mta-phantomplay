function createDealershipCommand(player, command, name)

    local account = Account.getFromPlayer(player)

    if not account or account:getAdminLevel() < 2 then
        outputChatBox("You do not have permission to create a dealership.", player, 255, 0, 0)
        return
    end

    if not name or name == "" then
        outputChatBox("Usage: /" .. command .. " [name]", player, 255, 255, 0)
        return
    end

    local x, y, z = getElementPosition(player)
    local dimension = getElementDimension(player)

    -- Create the dealership instance
    local dealership = Dealership:create({
        name = name,
        x = x,
        y = y,
        z = z,
    })

    -- Save to database
    dealership:save(function(success)
        if success then
            outputChatBox("Dealership '" .. name .. "' created successfully!", player, 0, 255, 0)
            dealership:createVisuals()
        else
            outputChatBox("Failed to create dealership. Please try again.", player, 255, 0, 0)
        end
    end)
end

addCommandHandler("createdealership", createDealershipCommand)