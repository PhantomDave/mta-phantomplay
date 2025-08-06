-- Import the base Item class
local Item = Item or {}

-- Clothing class that inherits from Item
Clothing = {}
Clothing.__index = Clothing
setmetatable(Clothing, {__index = Item})

-- Constructor for Clothing items
function Clothing:new(itemData)
    -- Call parent constructor
    local obj = Item:new(itemData)
    setmetatable(obj, self)
    
    -- Clothing-specific properties
    obj.category = "clothing"
    obj.usable = true
    obj.clothingType = itemData.clothingType or "shirt" -- shirt, pants, shoes, hat, etc.
    obj.bodyPart = itemData.bodyPart or 0 -- MTA clothing body part
    obj.texture = itemData.texture or 0 -- MTA clothing texture
    obj.model = itemData.model or 0 -- MTA clothing model
    obj.armor = itemData.armor or 0 -- armor protection value
    obj.warmth = itemData.warmth or 0 -- warmth value for weather
    obj.style = itemData.style or 0 -- style points
    obj.gender = itemData.gender or "unisex" -- male, female, unisex
    obj.equipped = false
    
    -- Set durability for clothing items
    if not obj.durability and obj.maxDurability then
        obj.durability = obj.maxDurability
    end
    
    return obj
end

-- Override the use method for clothing (equip/unequip)
function Clothing:use(player, ...)
    if not self.usable then
        return false, "This item cannot be used"
    end
    
    if not player or not isElement(player) then
        return false, "Invalid player"
    end
    
    -- Check if clothing is broken
    if self:isBroken() then
        return false, "This clothing is too damaged to wear"
    end
    
    -- Check gender compatibility
    if self.gender ~= "unisex" then
        local playerGender = getElementModel(player) == 0 and "male" or "female"
        if self.gender ~= playerGender then
            return false, "This clothing is not suitable for your gender"
        end
    end
    
    if not self.equipped then
        -- Equip the clothing
        local success = addPedClothes(player, self.texture, self.model, self.bodyPart)
        if success then
            self.equipped = true
            
            -- Apply armor if any
            if self.armor > 0 then
                local currentArmor = getPedArmor(player)
                setPedArmor(player, math.min(100, currentArmor + self.armor))
            end
            
            return true, "Equipped " .. self.name
        else
            return false, "Failed to equip clothing"
        end
    else
        -- Unequip the clothing
        local success = removePedClothes(player, self.bodyPart)
        if success then
            self.equipped = false
            
            -- Remove armor if any
            if self.armor > 0 then
                local currentArmor = getPedArmor(player)
                setPedArmor(player, math.max(0, currentArmor - self.armor))
            end
            
            return true, "Unequipped " .. self.name
        else
            return false, "Failed to unequip clothing"
        end
    end
end

-- Get clothing type
function Clothing:getType()
    return "clothing"
end

-- Get clothing-specific info
function Clothing:getInfo()
    local info = Item.getInfo(self) -- Call parent method
    
    -- Add clothing-specific properties
    info.clothingType = self.clothingType
    info.bodyPart = self.bodyPart
    info.texture = self.texture
    info.model = self.model
    info.armor = self.armor
    info.warmth = self.warmth
    info.style = self.style
    info.gender = self.gender
    info.equipped = self.equipped
    
    return info
end

-- Validate clothing-specific data
function Clothing:validate()
    local isValid, message = Item.validate(self) -- Call parent validation
    
    if not isValid then
        return false, message
    end
    
    if self.bodyPart < 0 or self.bodyPart > 17 then
        return false, "Invalid body part"
    end
    
    if self.armor < 0 then
        return false, "Armor value cannot be negative"
    end
    
    if self.gender ~= "male" and self.gender ~= "female" and self.gender ~= "unisex" then
        return false, "Invalid gender specification"
    end
    
    return true, "Clothing is valid"
end

-- Check if clothing provides protection
function Clothing:providesProtection()
    return self.armor > 0
end

-- Get style bonus
function Clothing:getStyleBonus()
    if self:isDamaged() then
        return math.floor(self.style * 0.5) -- Damaged clothes give less style
    end
    return self.style
end

-- Example clothing items
local clothingItems = {
    -- Shirts
    {
        id = 3001,
        name = "White T-Shirt",
        description = "A simple white t-shirt",
        icon = "white_tshirt.png",
        weight = 0.3,
        value = 15,
        clothingType = "shirt",
        bodyPart = 0, -- Torso
        texture = 0,
        model = 0,
        style = 2,
        maxDurability = 200,
        durability = 200,
        gender = "unisex",
        rarity = "common"
    },
    
    {
        id = 3002,
        name = "Leather Jacket",
        description = "A stylish leather jacket that provides some protection",
        icon = "leather_jacket.png",
        weight = 1.2,
        value = 200,
        clothingType = "jacket",
        bodyPart = 0, -- Torso
        texture = 1,
        model = 1,
        armor = 5,
        warmth = 15,
        style = 25,
        maxDurability = 500,
        durability = 500,
        gender = "unisex",
        rarity = "uncommon"
    },
    
    -- Pants
    {
        id = 3003,
        name = "Blue Jeans",
        description = "Classic blue denim jeans",
        icon = "blue_jeans.png",
        weight = 0.6,
        value = 40,
        clothingType = "pants",
        bodyPart = 2, -- Legs
        texture = 0,
        model = 0,
        style = 10,
        maxDurability = 300,
        durability = 300,
        gender = "unisex",
        rarity = "common"
    },
    
    -- Shoes
    {
        id = 3004,
        name = "Sneakers",
        description = "Comfortable running sneakers",
        icon = "sneakers.png",
        weight = 0.8,
        value = 80,
        clothingType = "shoes",
        bodyPart = 3, -- Feet
        texture = 0,
        model = 0,
        style = 15,
        maxDurability = 400,
        durability = 400,
        gender = "unisex",
        rarity = "common"
    },
    
    {
        id = 3005,
        name = "Combat Boots",
        description = "Heavy-duty boots that provide protection",
        icon = "combat_boots.png",
        weight = 1.5,
        value = 150,
        clothingType = "boots",
        bodyPart = 3, -- Feet
        texture = 1,
        model = 1,
        armor = 3,
        style = 20,
        maxDurability = 600,
        durability = 600,
        gender = "unisex",
        rarity = "uncommon"
    },
    
    -- Hats
    {
        id = 3006,
        name = "Baseball Cap",
        description = "A casual baseball cap",
        icon = "baseball_cap.png",
        weight = 0.2,
        value = 25,
        clothingType = "hat",
        bodyPart = 16, -- Hat
        texture = 0,
        model = 0,
        style = 8,
        maxDurability = 150,
        durability = 150,
        gender = "unisex",
        rarity = "common"
    },
    
    -- Armor
    {
        id = 3007,
        name = "Bulletproof Vest",
        description = "A vest that provides significant protection against bullets",
        icon = "bulletproof_vest.png",
        weight = 2.5,
        value = 1000,
        clothingType = "armor",
        bodyPart = 1, -- Torso armor
        texture = 0,
        model = 0,
        armor = 40,
        style = -5, -- Looks bulky
        maxDurability = 300,
        durability = 300,
        gender = "unisex",
        requiresLicense = true,
        rarity = "epic"
    },
    
    -- Accessories
    {
        id = 3008,
        name = "Sunglasses",
        description = "Cool sunglasses that boost your style",
        icon = "sunglasses.png",
        weight = 0.1,
        value = 60,
        clothingType = "glasses",
        bodyPart = 1, -- Face
        texture = 0,
        model = 0,
        style = 30,
        maxDurability = 100,
        durability = 100,
        gender = "unisex",
        rarity = "uncommon"
    }
}

-- Function to create a clothing item
function createClothing(itemId)
    for _, itemData in ipairs(clothingItems) do
        if itemData.id == itemId then
            return Clothing:new(itemData), 1
        end
    end
    
    return nil, 0
end

-- Function to get all clothing items
function getAllClothing()
    return clothingItems
end

-- Function to get clothing by type
function getClothingByType(clothingType)
    local clothing = {}
    for _, item in ipairs(clothingItems) do
        if item.clothingType == clothingType then
            table.insert(clothing, item)
        end
    end
    return clothing
end

-- Function to get clothing by body part
function getClothingByBodyPart(bodyPart)
    local clothing = {}
    for _, item in ipairs(clothingItems) do
        if item.bodyPart == bodyPart then
            table.insert(clothing, item)
        end
    end
    return clothing
end
