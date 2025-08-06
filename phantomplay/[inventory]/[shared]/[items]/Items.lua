---@class ItemData
---@field id number The unique ID of the item
---@field name string The display name of the item
---@field description string? The description of the item
---@field icon string? The icon path or name
---@field weight number? The weight of the item
---@field maxStack number? Maximum stack size
---@field stackable boolean? Whether the item can be stacked
---@field usable boolean? Whether the item can be used
---@field tradeable boolean? Whether the item can be traded
---@field droppable boolean? Whether the item can be dropped
---@field value number? The monetary value of the item
---@field rarity string? The rarity level of the item
---@field category string? The item category
---@field durability number? Current durability
---@field maxDurability number? Maximum durability
---@field metadata table? Additional metadata

---@class Item
---@field __index Item
---@field id number The unique ID of the item
---@field name string The display name of the item
---@field description string The description of the item
---@field icon string The icon path or name
---@field weight number The weight of the item
---@field maxStack number Maximum stack size
---@field stackable boolean Whether the item can be stacked
---@field usable boolean Whether the item can be used
---@field tradeable boolean Whether the item can be traded
---@field droppable boolean Whether the item can be dropped
---@field value number The monetary value of the item
---@field rarity string The rarity level of the item
---@field category string The item category
---@field durability number? Current durability
---@field maxDurability number? Maximum durability
---@field metadata table Additional metadata
Item = {}
Item.__index = Item

---Create a new item instance
---@param itemData ItemData The item data to initialize with
---@return Item item The new item instance
function Item:new(itemData)
    local obj = {}
    setmetatable(obj, self)
    
    obj.id = itemData.id or 0
    obj.name = itemData.name or "Unknown Item"
    obj.description = itemData.description or ""
    obj.icon = itemData.icon or ""
    obj.weight = itemData.weight or 0
    obj.maxStack = itemData.maxStack or 1
    obj.stackable = itemData.stackable or false
    obj.usable = itemData.usable or false
    obj.category = itemData.category or "misc"
    obj.durability = itemData.durability or nil
    obj.maxDurability = itemData.maxDurability or nil
    obj.metadata = itemData.metadata or {}
    
    return obj
end

---Get item information as a table
---@return ItemData itemData Complete item data
function Item:getInfo()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        icon = self.icon,
        weight = self.weight,
        maxStack = self.maxStack,
        stackable = self.stackable,
        usable = self.usable,
        tradeable = self.tradeable,
        droppable = self.droppable,
        value = self.value,
        rarity = self.rarity,
        category = self.category,
        durability = self.durability,
        maxDurability = self.maxDurability,
        metadata = self.metadata
    }
end

---Use the item (to be overridden by subclasses)
---@param player userdata The player using the item
---@param ... any Additional parameters
---@return boolean success Whether the item was used successfully
---@return string message Result message
function Item:use(player, ...)
    if not self.usable then
        return false, "This item cannot be used"
    end
    
    -- Base implementation - subclasses should override this
    return true, "Item used"
end

---Drop the item (can be overridden by subclasses)
---@param player userdata The player dropping the item
---@param position table? The position to drop the item at
---@return boolean success Whether the item was dropped successfully
---@return string message Result message
function Item:drop(player, position)
    if not self.droppable then
        return false, "This item cannot be dropped"
    end
    
    -- Base implementation - actual dropping logic would be implemented elsewhere
    return true, "Item dropped"
end

---Check if item is damaged (has durability)
---@return boolean damaged True if the item has durability and is damaged
function Item:isDamaged()
    if not self.durability or not self.maxDurability then
        return false
    end
    
    return self.durability < self.maxDurability
end

---Check if item is broken (durability reached 0)
---@return boolean broken True if the item has 0 durability
function Item:isBroken()
    if not self.durability then
        return false
    end
    
    return self.durability <= 0
end

---Damage the item
---@param amount number The amount of damage to apply
---@return boolean success Whether the damage was applied
---@return string message Result message
function Item:damage(amount)
    if not self.durability or not self.maxDurability then
        return false, "Item has no durability"
    end
    
    self.durability = math.max(0, self.durability - amount)
    
    if self.durability <= 0 then
        return true, "Item is now broken"
    end
    
    return true, "Item damaged"
end

---Repair the item
---@param amount number The amount to repair
---@return boolean success Whether the repair was successful
---@return string message Result message
function Item:repair(amount)
    if not self.durability or not self.maxDurability then
        return false, "Item has no durability"
    end
    
    self.durability = math.min(self.maxDurability, self.durability + amount)
    
    return true, "Item repaired"
end

---Get item display name with quantity (for UI)
---@param quantity number? The quantity to display (default: 1)
---@return string displayName The formatted display name
function Item:getDisplayName(quantity)
    quantity = quantity or 1
    if quantity > 1 then
        return self.name .. " (" .. quantity .. ")"
    end
    return self.name
end

---Set metadata value
---@param key string The metadata key
---@param value any The value to set
function Item:setMetadata(key, value)
    self.metadata[key] = value
end

---Get metadata value
---@param key string The metadata key
---@return any value The metadata value or nil if not found
function Item:getMetadata(key)
    return self.metadata[key]
end

---Check if item has specific metadata
---@param key string The metadata key to check
---@return boolean hasMetadata True if the metadata key exists
function Item:hasMetadata(key)
    return self.metadata[key] ~= nil
end

---Get item type (to be overridden by subclasses)
---@return string type The item type
function Item:getType()
    return "item"
end

---Validate item data
---@return boolean valid True if the item data is valid
---@return string message Validation result message
function Item:validate()
    if not self.id or self.id <= 0 then
        return false, "Invalid item ID"
    end
    
    if not self.name or self.name == "" then
        return false, "Item name cannot be empty"
    end
    
    if self.weight < 0 then
        return false, "Item weight cannot be negative"
    end
    
    if self.maxStack <= 0 then
        return false, "Max stack must be greater than 0"
    end
    
    if self.durability and self.maxDurability then
        if self.durability > self.maxDurability then
            return false, "Durability cannot exceed max durability"
        end
    end
    
    return true, "Item is valid"
end

---Clone the item (create a copy)
---@return Item clonedItem A new item instance with the same data
function Item:clone()
    return Item:new(self:getInfo())
end

---Get item by name from all item types
---@param itemName string The name of the item to find
---@return ItemData? itemData The item data if found, nil otherwise
function Item.GetItemFromName(itemName)
    if not itemName or itemName == "" then
        return nil
    end
    
    -- Check consumables if available
    if getAllConsumables then
        local consumables = getAllConsumables()
        for _, itemData in ipairs(consumables) do
            if itemData.name == itemName then
                return itemData
            end
        end
    end
    
    -- Check weapons if available
    if getAllWeapons then
        local weapons = getAllWeapons()
        for _, itemData in ipairs(weapons) do
            if itemData.name == itemName then
                return itemData
            end
        end
    end
    
    -- Check clothing if available
    if getAllClothing then
        local clothing = getAllClothing()
        for _, itemData in ipairs(clothing) do
            if itemData.name == itemName then
                return itemData
            end
        end
    end
    
    return nil
end

