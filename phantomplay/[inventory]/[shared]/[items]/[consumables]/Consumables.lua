-- Import the base Item class
local Item = Item or {}

-- Consumable class that inherits from Item
Consumable = {}
Consumable.__index = Consumable
setmetatable(Consumable, {__index = Item})

-- Constructor for Consumable items
function Consumable:new(itemData)
    -- Call parent constructor
    local obj = Item:new(itemData)
    setmetatable(obj, self)
    
    -- Consumable-specific properties
    obj.category = "consumable"
    obj.usable = true
    obj.healAmount = itemData.healAmount or 0
    obj.hungerAmount = itemData.hungerAmount or 0
    obj.thirstAmount = itemData.thirstAmount or 0
    obj.energyAmount = itemData.energyAmount or 0
    obj.effects = itemData.effects or {} -- status effects like speed boost, etc.
    obj.useTime = itemData.useTime or 1000 -- time in milliseconds to consume
    obj.consumeOnUse = itemData.consumeOnUse ~= false -- default true
    
    return obj
end

-- Override the use method for consumables
function Consumable:use(player, ...)
    if not self.usable then
        return false, "This item cannot be used"
    end
    
    if not player or not isElement(player) then
        return false, "Invalid player"
    end
    
    -- Apply healing
    if self.healAmount > 0 then
        local currentHealth = getElementHealth(player)
        local newHealth = math.min(100, currentHealth + self.healAmount)
        setElementHealth(player, newHealth)
    end
    
    -- Apply hunger (assuming you have a hunger system)
    if self.hungerAmount > 0 then
        -- This would interface with your hunger system
        -- Example: player:addHunger(self.hungerAmount)
    end
    
    -- Apply thirst (assuming you have a thirst system)
    if self.thirstAmount > 0 then
        -- This would interface with your thirst system
        -- Example: player:addThirst(self.thirstAmount)
    end
    
    -- Apply energy
    if self.energyAmount > 0 then
        -- This would interface with your energy system
        -- Example: player:addEnergy(self.energyAmount)
    end
    
    -- Apply effects
    for effectName, effectData in pairs(self.effects) do
        -- This would interface with your effects system
        -- Example: player:addEffect(effectName, effectData.duration, effectData.strength)
    end
    
    local message = "Consumed " .. self.name
    
    if self.healAmount > 0 then
        message = message .. " (+" .. self.healAmount .. " health)"
    end
    
    return true, message
end

-- Get item type
function Consumable:getType()
    return "consumable"
end

-- Get consumable-specific info
function Consumable:getInfo()
    local info = Item.getInfo(self) -- Call parent method
    
    -- Add consumable-specific properties
    info.healAmount = self.healAmount
    info.hungerAmount = self.hungerAmount
    info.thirstAmount = self.thirstAmount
    info.energyAmount = self.energyAmount
    info.effects = self.effects
    info.useTime = self.useTime
    info.consumeOnUse = self.consumeOnUse
    
    return info
end

-- Validate consumable-specific data
function Consumable:validate()
    local isValid, message = Item.validate(self) -- Call parent validation
    
    if not isValid then
        return false, message
    end
    
    if self.healAmount < 0 then
        return false, "Heal amount cannot be negative"
    end
    
    if self.useTime <= 0 then
        return false, "Use time must be greater than 0"
    end
    
    return true, "Consumable is valid"
end

-- Example consumable items
local consumableItems = {
    -- Food items
    {
        id = 1001,
        name = "Burger",
        description = "A delicious burger that restores health and hunger",
        icon = "burger.png",
        weight = 0.5,
        value = 10,
        healAmount = 25,
        hungerAmount = 50,
        useTime = 3000
    },
    
    {
        id = 1002,
        name = "Water Bottle",
        description = "A bottle of clean water",
        icon = "water_bottle.png",
        weight = 0.3,
        value = 5,
        thirstAmount = 40,
        useTime = 2000
    },
    
    {
        id = 1003,
        name = "Energy Drink",
        description = "Boosts energy and provides a temporary speed increase",
        icon = "energy_drink.png",
        weight = 0.2,
        value = 15,
        energyAmount = 30,
        thirstAmount = 20,
        effects = {
            speed = {duration = 30000, strength = 1.2}
        },
        useTime = 1500
    },
    
    -- Medical items
    {
        id = 1004,
        name = "First Aid Kit",
        description = "A medical kit that restores a significant amount of health",
        icon = "first_aid.png",
        weight = 1.0,
        value = 50,
        healAmount = 75,
        useTime = 5000,
        rarity = "uncommon"
    },
    
    {
        id = 1005,
        name = "Pain Killer",
        description = "Reduces pain and slowly restores health over time",
        icon = "painkillers.png",
        weight = 0.1,
        value = 25,
        healAmount = 10,
        effects = {
            regeneration = {duration = 60000, strength = 0.5}
        },
        useTime = 2000
    }
}

-- Function to create a consumable item
function createConsumable(itemId, quantity)
    quantity = quantity or 1
    
    for _, itemData in ipairs(consumableItems) do
        if itemData.id == itemId then
            return Consumable:new(itemData), quantity
        end
    end
    
    return nil, 0
end

-- Function to get all consumable items
function getAllConsumables()
    return consumableItems
end