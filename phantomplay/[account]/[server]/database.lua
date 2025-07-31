-- Legacy functions for backward compatibility
-- These functions now use the Account OOP class internally


function loginUser(email, password, callback)
    Account.login(email, password, function(account)
        if account then
            callback(account:getData())
        else
            callback(nil)
        end
    end)
end

function checkUserExists(email, username, callback)
    Account.checkExists(email, username, callback)
end

function createUser(email, username, password, callback)
    Account.register(email, username, password, callback)
end

function updateUserData(player, accountData, callback)
    local account = Account.getFromPlayer(player)
    if not account then
        outputDebugString("[DEBUG] No account data found for player: " .. getPlayerName(player))
        if callback then callback(false) end
        return
    end
    
    -- Update account properties
    for key, value in pairs(accountData) do
        if key == "email" then account.email = value
        elseif key == "username" then account.username = value
        elseif key == "password" then account.password = value
        elseif key == "admin_level" then account.adminLevel = value
        elseif key == "last_login" then account.lastLogin = value
        end
    end
    
    -- Save the account
    account:save(callback)
end

-- Helper function to get account data from player (legacy compatibility)
function getAccountData(player)
    local account = Account.getFromPlayer(player)
    if account then
        return account:getData()
    end
    return nil
end