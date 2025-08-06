local Item = Item or {}

local weaponItems = {}
local weaponsInitialized = false

function initializeWeaponItems()
    if weaponsInitialized then
        return
    end
    
    -- Initialize weapon items table with references to weapon data
    local weaponReferences = {
        Colt45,
        DesertEagle,
        MP5,
        AK47,
        Shotgun,
        BaseballBat
    }
    
    -- Filter out nil values and ensure valid weapon data
    weaponItems = {}
    for _, weapon in ipairs(weaponReferences) do
        if weapon and weapon.id then
            table.insert(weaponItems, weapon)
        end
    end
    
    weaponsInitialized = true
    iprint("Initialized " .. #weaponItems .. " weapon items")
end

local function ensureWeaponsInitialized()
    if not weaponsInitialized then
        initializeWeaponItems()
    end
end

-- Call initialization when the script loads
-- Add a small delay to ensure other weapon files are loaded first
setTimer(initializeWeaponItems, 100, 1)

Weapon = {}
Weapon.__index = Weapon
setmetatable(Weapon, {__index = Item})

function Weapon:new(itemData)
    local obj = Item:new(itemData)
    setmetatable(obj, self)
    
    obj.category = "weapon"
    obj.usable = true
    obj.weaponType = itemData.weaponType or 0 -- MTA weapon ID
    obj.damage = itemData.damage or 10
    obj.range = itemData.range or 35
    obj.accuracy = itemData.accuracy or 1.0
    obj.fireRate = itemData.fireRate or 1000
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
    iprint("Using weapon: " .. self.name)
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
    
    -- Give weapon to player
    local success = player:giveWeapon(self.weaponType, self.currentAmmo, true)
    
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

-- Function to create a weapon item
function createWeapon(itemId, ammo)
    ensureWeaponsInitialized()
    
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
    ensureWeaponsInitialized()
    return weaponItems
end

-- Function to get weapons by category
function getWeaponsBySlot(slot)
    ensureWeaponsInitialized()
    
    local weapons = {}
    for _, weapon in ipairs(weaponItems) do
        if weapon.weaponSlot == slot then
            table.insert(weapons, weapon)
        end
    end
    return weapons
end

-- Function to get weapons by rarity
function getWeaponsByRarity(rarity)
    ensureWeaponsInitialized()
    
    local weapons = {}
    for _, weapon in ipairs(weaponItems) do
        if weapon.rarity == rarity then
            table.insert(weapons, weapon)
        end
    end
    return weapons
end

-- Function to get a weapon by ID
function getWeaponById(weaponId)
    ensureWeaponsInitialized()
    
    for _, weapon in ipairs(weaponItems) do
        if weapon.id == weaponId then
            return weapon
        end
    end
    return nil
end
