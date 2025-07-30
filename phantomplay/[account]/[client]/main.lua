-- Client-side Account management
-- Updated to work with server-side OOP Account class

local account = {}

function getAccountData()
    return account
end

function setAccountData(data)
    account = data or {}
end

-- Helper function to get account ID (commonly used)
function getAccountId()
    return account.id
end

-- Helper function to check if player is logged in
function isLoggedIn()
    return account.id ~= nil
end

-- Helper function to get username
function getUsername()
    return account.username
end

-- Helper function to check if account is admin
function isAdmin()
    return account.admin_level and account.admin_level > 0
end
