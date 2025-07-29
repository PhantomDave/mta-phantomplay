ADMIN_LEVELS = {
    [0] = "User",
    [1] = "Moderator",
    [2] = "Admin"
}

function getAdminLevel(player)
    local account = getElementData(player, "account")
    if account then
        return account.admin_level
    end
    return 0
end

function isPlayerAdmin(player)
    return getAdminLevel(player) > 0
end