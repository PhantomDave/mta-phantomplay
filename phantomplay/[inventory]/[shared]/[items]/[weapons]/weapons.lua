-- Import the base Item class
local Item = Item or {}

-- Weapon class that inherits from Item
Weapon = {}
Weapon.__index = Weapon
setmetatable(Weapon, {__index = Item})

-- Constructor for Weapon items
function Weapon:new(itemData)
    -- Call parent constructor
    local obj = Item:new(itemData)
    setmetatable(obj, self)
    
    -- Weapon-specific properties
    obj.category = "weapon"
    obj.usable = true
    obj.weaponType = itemData.weaponType or 0 -- MTA weapon ID
    obj.damage = itemData.damage or 10
    obj.range = itemData.range or 35
    obj.accuracy = itemData.accuracy or 1.0
    obj.fireRate = itemData.fireRate or 1000 -- milliseconds between shots
    obj.ammoType = itemData.ammoType or nil
    obj.maxAmmo = itemData.maxAmmo or 0
    obj.currentAmmo = itemData.currentAmmo or 0
    obj.skill = itemData.skill or "poor" -- poor, std, pro
    obj.weaponSlot = itemData.weaponSlot or 0
    obj.requiresLicense = itemData.requiresLicense or false
    obj.isAutomatic = itemData.isAutomatic or false
    obj.reloadTime = itemData.reloadTime or 3000
    
    -- Set durability if not specified (weapons typically have durability)
    if not obj.durability and obj.maxDurability then
        obj.durability = obj.maxDurability
    end
    
    return obj
end

-- Override the use method for weapons (equip weapon)
function Weapon:use(player, ...)
    if not self.usable then
        return false, "This weapon cannot be used"
    end
    
    if not player or not isElement(player) then
        return false, "Invalid player"
    end
    
    -- Check if weapon is broken
    if self:isBroken() then
        return false, "This weapon is broken and cannot be used"
    end
    
    -- Check if player has a license (if required)
    if self.requiresLicense then
        -- This would check your license system
        -- Example: if not player:hasWeaponLicense() then return false, "You need a weapon license" end
    end
    
    -- Give weapon to player
    local success = giveWeapon(player, self.weaponType, self.currentAmmo, true)
    
    if success then
        -- Set weapon skill if applicable
        if self.skill then
            local skillLevel = 0
            if self.skill == "std" then skillLevel = 500
            elseif self.skill == "pro" then skillLevel = 1000
            end
            setPedStat(player, 69 + self.weaponSlot, skillLevel) -- MTA weapon skills
        end
        
        return true, "Equipped " .. self.name
    else
        return false, "Failed to equip weapon"
    end
end

-- Reload the weapon
function Weapon:reload(ammoAmount)
    if not self.ammoType then
        return false, "This weapon cannot be reloaded"
    end
    
    if self.currentAmmo >= self.maxAmmo then
        return false, "Weapon is already fully loaded"
    end
    
    local ammoNeeded = self.maxAmmo - self.currentAmmo
    local ammoToAdd = math.min(ammoNeeded, ammoAmount or ammoNeeded)
    
    self.currentAmmo = self.currentAmmo + ammoToAdd
    
    return true, "Reloaded " .. ammoToAdd .. " rounds", ammoToAdd
end

-- Fire the weapon (reduce ammo and durability)
function Weapon:fire()
    if self.currentAmmo <= 0 then
        return false, "No ammo"
    end
    
    if self:isBroken() then
        return false, "Weapon is broken"
    end
    
    self.currentAmmo = self.currentAmmo - 1
    
    -- Damage weapon slightly each time it's fired
    if self.durability and self.maxDurability then
        self:damage(0.1)
    end
    
    return true, "Weapon fired"
end

-- Get weapon type
function Weapon:getType()
    return "weapon"
end

-- Get weapon-specific info
function Weapon:getInfo()
    local info = Item.getInfo(self) -- Call parent method
    
    -- Add weapon-specific properties
    info.weaponType = self.weaponType
    info.damage = self.damage
    info.range = self.range
    info.accuracy = self.accuracy
    info.fireRate = self.fireRate
    info.ammoType = self.ammoType
    info.maxAmmo = self.maxAmmo
    info.currentAmmo = self.currentAmmo
    info.skill = self.skill
    info.weaponSlot = self.weaponSlot
    info.requiresLicense = self.requiresLicense
    info.isAutomatic = self.isAutomatic
    info.reloadTime = self.reloadTime
    
    return info
end

-- Validate weapon-specific data
function Weapon:validate()
    local isValid, message = Item.validate(self) -- Call parent validation
    
    if not isValid then
        return false, message
    end
    
    if self.weaponType < 0 or self.weaponType > 46 then
        return false, "Invalid weapon type"
    end
    
    if self.damage <= 0 then
        return false, "Weapon damage must be greater than 0"
    end
    
    if self.currentAmmo > self.maxAmmo then
        return false, "Current ammo cannot exceed max ammo"
    end
    
    if self.fireRate <= 0 then
        return false, "Fire rate must be greater than 0"
    end
    
    return true, "Weapon is valid"
end

-- Get ammo percentage
function Weapon:getAmmoPercentage()
    if self.maxAmmo <= 0 then
        return 0
    end
    return (self.currentAmmo / self.maxAmmo) * 100
end

-- Check if weapon needs ammo
function Weapon:needsAmmo()
    return self.maxAmmo > 0 and self.currentAmmo < self.maxAmmo
end

-- Example weapon items
local weaponItems = {
    -- Pistols
    {
        id = 2001,
        name = "Colt 45",
        description = "A reliable pistol with moderate damage",
        icon = "colt45.png",
        weight = 1.2,
        value = 500,
        weaponType = 22, -- MTA weapon ID for Colt 45
        damage = 25,
        range = 35,
        accuracy = 0.8,
        fireRate = 800,
        ammoType = "9mm",
        maxAmmo = 17,
        currentAmmo = 17,
        weaponSlot = 2,
        maxDurability = 1000,
        durability = 1000,
        rarity = "common"
    },
    
    {
        id = 2002,
        name = "Desert Eagle",
        description = "A powerful pistol with high damage",
        icon = "deagle.png",
        weight = 1.8,
        value = 1200,
        weaponType = 24, -- MTA weapon ID for Desert Eagle
        damage = 50,
        range = 35,
        accuracy = 0.9,
        fireRate = 1200,
        ammoType = ".50AE",
        maxAmmo = 7,
        currentAmmo = 7,
        weaponSlot = 2,
        maxDurability = 800,
        durability = 800,
        requiresLicense = true,
        rarity = "uncommon"
    },
    
    -- SMGs
    {
        id = 2003,
        name = "MP5",
        description = "A versatile submachine gun",
        icon = "mp5.png",
        weight = 2.5,
        value = 2000,
        weaponType = 29, -- MTA weapon ID for MP5
        damage = 20,
        range = 45,
        accuracy = 0.7,
        fireRate = 150,
        ammoType = "9mm",
        maxAmmo = 30,
        currentAmmo = 30,
        weaponSlot = 4,
        isAutomatic = true,
        maxDurability = 1200,
        durability = 1200,
        requiresLicense = true,
        rarity = "rare"
    },
    
    -- Assault Rifles
    {
        id = 2004,
        name = "AK-47",
        description = "A powerful assault rifle",
        icon = "ak47.png",
        weight = 3.8,
        value = 5000,
        weaponType = 30, -- MTA weapon ID for AK-47
        damage = 35,
        range = 70,
        accuracy = 0.6,
        fireRate = 100,
        ammoType = "7.62mm",
        maxAmmo = 30,
        currentAmmo = 30,
        weaponSlot = 5,
        isAutomatic = true,
        maxDurability = 1500,
        durability = 1500,
        requiresLicense = true,
        rarity = "epic"
    },
    
    -- Shotguns
    {
        id = 2005,
        name = "Shotgun",
        description = "A close-range weapon with devastating power",
        icon = "shotgun.png",
        weight = 3.2,
        value = 1500,
        weaponType = 25, -- MTA weapon ID for Shotgun
        damage = 80,
        range = 25,
        accuracy = 0.9,
        fireRate = 2000,
        ammoType = "12gauge",
        maxAmmo = 6,
        currentAmmo = 6,
        weaponSlot = 3,
        maxDurability = 1000,
        durability = 1000,
        rarity = "uncommon"
    },
    
    -- Melee weapons
    {
        id = 2006,
        name = "Baseball Bat",
        description = "A wooden bat, perfect for close combat",
        icon = "baseball_bat.png",
        weight = 1.0,
        value = 50,
        weaponType = 5, -- MTA weapon ID for Baseball Bat
        damage = 30,
        range = 5,
        accuracy = 1.0,
        fireRate = 1500,
        weaponSlot = 1,
        maxDurability = 500,
        durability = 500,
        rarity = "common"
    }
}

-- Function to create a weapon item
function createWeapon(itemId, ammo)
    for _, itemData in ipairs(weaponItems) do
        if itemData.id == itemId then
            local weaponData = {}
            for k, v in pairs(itemData) do
                weaponData[k] = v
            end
            
            if ammo then
                weaponData.currentAmmo = math.min(ammo, weaponData.maxAmmo)
            end
            
            return Weapon:new(weaponData), 1
        end
    end
    
    return nil, 0
end

-- Function to get all weapon items
function getAllWeapons()
    return weaponItems
end

-- Function to get weapons by category
function getWeaponsBySlot(slot)
    local weapons = {}
    for _, weapon in ipairs(weaponItems) do
        if weapon.weaponSlot == slot then
            table.insert(weapons, weapon)
        end
    end
    return weapons
end
