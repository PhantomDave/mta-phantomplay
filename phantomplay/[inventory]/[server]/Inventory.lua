-- Inventory Database Handler
-- Manages player inventory items in the database

---@class Inventory
---@field __index Inventory
Inventory = {}
Inventory.__index = Inventory

---@class InventoryItem
---@field ID number The database ID of the item
---@field Item string The name of the item
---@field Quantity number The quantity of the item
---@field Slot number The slot position of the item

---@alias InventoryCallback fun(success: boolean, message: string?, quantity: number?, slot: number?, id: number?)
---@alias InventoryItemCallback fun(item: InventoryItem?)
---@alias InventoryListCallback fun(items: InventoryItem[]?)
---@alias SlotCallback fun(slot: number?)
---@alias HasItemCallback fun(hasItem: boolean, currentQuantity: number?)

---Helper function to create proper item instance from item name
---@param itemName string The name of the item
---@param dbItem table The database item record
---@return table? itemInstance The proper item class instance or nil
local function createItemInstance(itemName, dbItem)
    if not itemName then
        return nil
    end
    
    -- Get item data from the item system
    local itemTemplate = Item.GetItemFromName(itemName)
    if not itemTemplate then
        outputDebugString("[WARNING] Item template not found for: " .. tostring(itemName))
        return nil
    end
    
    -- Create the appropriate item instance based on category
    local itemInstance = nil
    
    -- Check if it's a consumable
    if getAllConsumables then
        local consumables = getAllConsumables()
        for _, consumableData in ipairs(consumables) do
            if consumableData.name == itemName then
                itemInstance = Consumable:new(consumableData)
                break
            end
        end
    end
    
    -- Check if it's a weapon
    if not itemInstance and getAllWeapons then
        local weapons = getAllWeapons()
        for _, weaponData in ipairs(weapons) do
            if weaponData.name == itemName then
                itemInstance = Weapon:new(weaponData)
                break
            end
        end
    end
    
    -- Check if it's clothing
    if not itemInstance and getAllClothing then
        local clothing = getAllClothing()
        for _, clothingData in ipairs(clothing) do
            if clothingData.name == itemName then
                itemInstance = Clothing:new(clothingData)
                break
            end
        end
    end
    
    -- Fall back to basic Item if no specific type found
    if not itemInstance then
        itemInstance = Item:new(itemTemplate)
    end
    
    -- Add database-specific properties to the item instance
    if itemInstance and dbItem then
        itemInstance.dbID = dbItem.ID
        itemInstance.slot = dbItem.Slot
        itemInstance.quantity = dbItem.Quantity
    end
    
    return itemInstance
end

---Initialize the inventory database table
---@return boolean success True if initialization started successfully
function Inventory.initializeDatabase()
    if not Database.isReady() then
        outputDebugString("[ERROR] Database not ready for inventory initialization")
        return false
    end
    
    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS player_items (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            OwnerID INT NOT NULL REFERENCES characters(ID) ON DELETE CASCADE,
            Item VARCHAR(100) NOT NULL,
            Quantity INT NOT NULL DEFAULT 1,
            Slot INT NOT NULL DEFAULT 1,
            UNIQUE KEY unique_owner_item (OwnerID, Item),
            UNIQUE KEY unique_owner_slot (OwnerID, Slot)
        )
    ]]
    
    Database.executeAsync(createTableQuery, function(affectedRows)
        if affectedRows >= 0 then
            outputDebugString("[DEBUG] Inventory table initialized successfully")
        else
            outputDebugString("[ERROR] Failed to initialize inventory table")
        end
    end)
    
    return true
end

---Get character ID from player element
---@param player userdata The player element
---@return number? characterID The character ID or nil if not found
function Inventory.getCharacterID(player)
    if not player or not isElement(player) then
        return nil
    end
    
    local character = getElementData(player, "character")
    if character and character.id then
        return character.id
    end
    
    return nil
end

---Get the next available inventory slot for a character
---@param characterID number The character's ID
---@param callback SlotCallback Function to call with the next available slot
---@return boolean success True if the operation was initiated successfully
function Inventory.getNextAvailableSlot(characterID, callback)
    if not characterID then
        if callback then callback(nil) end
        return false
    end
    
    local query = "SELECT Slot FROM player_items WHERE OwnerID = ? ORDER BY Slot ASC"
    
    Database.queryAsync(query, function(result)
        if result then
            local usedSlots = {}
            for _, item in ipairs(result) do
                usedSlots[item.Slot] = true
            end
            
            -- Find first available slot
            local nextSlot = 1
            while usedSlots[nextSlot] do
                nextSlot = nextSlot + 1
            end
            
            if callback then callback(nextSlot) end
        else
            if callback then callback(1) end -- Default to slot 1 if query fails
        end
    end, characterID)
    
    return true
end

---Add item to character's inventory
---@param characterID number The character's ID
---@param item string The name of the item to add
---@param quantity number The quantity to add
---@param slot number? Optional specific slot number
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.addItem(characterID, itemName, quantity, slot, callback)
    -- Handle optional parameters (slot and callback can be swapped)
    if type(slot) == "function" then
        callback = slot
        slot = nil
    end
    
    if not characterID or not itemName or not quantity then
        outputDebugString("[ERROR] Invalid parameters for addItem")
        if callback then callback(false, "Invalid parameters") end
        return false
    end
    
    quantity = math.max(1, tonumber(quantity) or 1)
    
    -- First, check if the item already exists
    local checkQuery = "SELECT ID, Quantity, Slot FROM player_items WHERE OwnerID = ? AND Item = ?"
    
    Database.queryAsync(checkQuery, function(result)
        if result and #result > 0 then
            -- Item exists, update quantity
            local currentQuantity = result[1].Quantity
            local newQuantity = currentQuantity + quantity
            local existingSlot = result[1].Slot
            
            local updateQuery = "UPDATE player_items SET Quantity = ? WHERE ID = ?"
            Database.executeAsync(updateQuery, function(affectedRows)
                if affectedRows > 0 then
                    outputDebugString("[DEBUG] Updated item quantity for " .. itemName .. " (Character: " .. characterID .. ")")
                    if callback then callback(true, "Item quantity updated", newQuantity, existingSlot) end
                else
                    outputDebugString("[ERROR] Failed to update item quantity")
                    if callback then callback(false, "Failed to update quantity") end
                end
            end, newQuantity, result[1].ID)
        else
            -- Item doesn't exist, insert new
            if slot then
                -- Check if slot is available
                local slotCheckQuery = "SELECT ID FROM player_items WHERE OwnerID = ? AND Slot = ?"
                Database.queryAsync(slotCheckQuery, function(slotResult)
                    if slotResult and #slotResult > 0 then
                        -- Slot taken, find next available
                        Inventory.getNextAvailableSlot(characterID, function(nextSlot)
                            if nextSlot then
                                local insertQuery = "INSERT INTO player_items (OwnerID, Item, Quantity, Slot) VALUES (?, ?, ?, ?)"
                                Database.insertAsync(insertQuery, function(insertID)
                                    if insertID then
                                        outputDebugString("[DEBUG] Added new item " .. itemName .. " to inventory slot " .. nextSlot .. " (Character: " .. characterID .. ")")
                                        if callback then callback(true, "Item added successfully", quantity, nextSlot, insertID) end
                                    else
                                        outputDebugString("[ERROR] Failed to add item to inventory")
                                        if callback then callback(false, "Failed to add item") end
                                    end
                                end, characterID, itemName, quantity, nextSlot)
                            else
                                if callback then callback(false, "Could not find available slot") end
                            end
                        end)
                    else
                        -- Slot available, use it
                        local insertQuery = "INSERT INTO player_items (OwnerID, Item, Quantity, Slot) VALUES (?, ?, ?, ?)"
                        Database.insertAsync(insertQuery, function(insertID)
                            if insertID then
                                outputDebugString("[DEBUG] Added new item " .. itemName .. " to inventory slot " .. slot .. " (Character: " .. characterID .. ")")
                                if callback then callback(true, "Item added successfully", quantity, slot, insertID) end
                            else
                                outputDebugString("[ERROR] Failed to add item to inventory")
                                if callback then callback(false, "Failed to add item") end
                            end
                        end, characterID, itemName, quantity, slot)
                    end
                end, characterID, slot)
            else
                -- No specific slot, find next available
                Inventory.getNextAvailableSlot(characterID, function(nextSlot)
                    if nextSlot then
                        local insertQuery = "INSERT INTO player_items (OwnerID, Item, Quantity, Slot) VALUES (?, ?, ?, ?)"
                        Database.insertAsync(insertQuery, function(insertID)
                            if insertID then
                                outputDebugString("[DEBUG] Added new item " .. itemName .. " to inventory slot " .. nextSlot .. " (Character: " .. characterID .. ")")
                                if callback then callback(true, "Item added successfully", quantity, nextSlot, insertID) end
                            else
                                outputDebugString("[ERROR] Failed to add item to inventory")
                                if callback then callback(false, "Failed to add item") end
                            end
                        end, characterID, itemName, quantity, nextSlot)
                    else
                        if callback then callback(false, "Could not find available slot") end
                    end
                end)
            end
        end
    end, characterID, itemName)
    
    return true
end

---Remove item from character's inventory
---@param characterID number The character's ID
---@param itemName string The name of the item to remove
---@param quantity number The quantity to remove
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.removeItem(characterID, itemName, quantity, callback)
    if not characterID or not itemName or not quantity then
        outputDebugString("[ERROR] Invalid parameters for removeItem")
        if callback then callback(false, "Invalid parameters") end
        return false
    end
    
    quantity = math.max(1, tonumber(quantity) or 1)
    
    -- Check current quantity
    local checkQuery = "SELECT ID, Quantity, Slot FROM player_items WHERE OwnerID = ? AND Item = ?"
    
    Database.queryAsync(checkQuery, function(result)
        if result and #result > 0 then
            local currentQuantity = result[1].Quantity
            local itemID = result[1].ID
            local itemSlot = result[1].Slot
            
            if currentQuantity >= quantity then
                local newQuantity = currentQuantity - quantity
                
                if newQuantity > 0 then
                    -- Update quantity
                    local updateQuery = "UPDATE player_items SET Quantity = ? WHERE ID = ?"
                    Database.executeAsync(updateQuery, function(affectedRows)
                        if affectedRows > 0 then
                            outputDebugString("[DEBUG] Removed " .. quantity .. " of " .. itemName .. " from inventory (Character: " .. characterID .. ")")
                            if callback then callback(true, "Item quantity updated", newQuantity, itemSlot) end
                        else
                            outputDebugString("[ERROR] Failed to update item quantity")
                            if callback then callback(false, "Failed to update quantity") end
                        end
                    end, newQuantity, itemID)
                else
                    -- Remove item completely
                    local deleteQuery = "DELETE FROM player_items WHERE ID = ?"
                    Database.executeAsync(deleteQuery, function(affectedRows)
                        if affectedRows > 0 then
                            outputDebugString("[DEBUG] Completely removed " .. itemName .. " from inventory slot " .. itemSlot .. " (Character: " .. characterID .. ")")
                            if callback then callback(true, "Item removed completely", 0, itemSlot) end
                        else
                            outputDebugString("[ERROR] Failed to remove item")
                            if callback then callback(false, "Failed to remove item") end
                        end
                    end, itemID)
                end
            else
                outputDebugString("[ERROR] Not enough quantity to remove")
                if callback then callback(false, "Insufficient quantity") end
            end
        else
            outputDebugString("[ERROR] Item not found in inventory")
            if callback then callback(false, "Item not found") end
        end
    end, characterID, itemName)
    
    return true
end

---Get character's complete inventory
---@param characterID number The character's ID
---@param callback InventoryListCallback Function to call with the inventory items
---@return boolean success True if the operation was initiated successfully
function Inventory.getCharacterInventory(characterID, callback)
    if not characterID then
        outputDebugString("[ERROR] Invalid characterID for getCharacterInventory")
        if callback then callback(nil) end
        return false
    end
    
    local query = "SELECT ID, Item, Quantity, Slot FROM player_items WHERE OwnerID = ? ORDER BY Slot ASC"
    
    Database.queryAsync(query, function(result)
        if result then
            outputDebugString("[DEBUG] Retrieved inventory for character " .. characterID .. " (" .. #result .. " items)")
            if callback then callback(result) end
        else
            outputDebugString("[ERROR] Failed to retrieve inventory")
            if callback then callback(nil) end
        end
    end, characterID)
    
    return true
end

---Get specific item from character's inventory
---@param characterID number The character's ID
---@param itemName string The name of the item to find
---@param callback InventoryItemCallback Function to call with the item data
---@return boolean success True if the operation was initiated successfully
function Inventory.getCharacterItem(characterID, itemName, callback)
    if not characterID or not itemName then
        outputDebugString("[ERROR] Invalid parameters for getCharacterItem")
        if callback then callback(nil) end
        return false
    end
    
    local query = "SELECT ID, Item, Quantity, Slot FROM player_items WHERE OwnerID = ? AND Item = ?"
    
    Database.queryAsync(query, function(result)
        if result and #result > 0 then
            outputDebugString("[DEBUG] Retrieved item " .. itemName .. " for character " .. characterID)
            if callback then callback(result[1]) end
        else
            outputDebugString("[DEBUG] Item " .. itemName .. " not found for character " .. characterID)
            if callback then callback(nil) end
        end
    end, characterID, itemName)
    
    return true
end

---Get item by slot number
---@param characterID number The character's ID
---@param slot number The slot number to check
---@param callback InventoryItemCallback Function to call with the item data
---@return boolean success True if the operation was initiated successfully
function Inventory.getItemBySlot(characterID, slot, callback)
    if not characterID or not slot then
        outputDebugString("[ERROR] Invalid parameters for getItemBySlot")
        if callback then callback(nil) end
        return false
    end
    
    local query = "SELECT ID, Item, Quantity, Slot FROM player_items WHERE OwnerID = ? AND Slot = ?"
    
    Database.queryAsync(query, function(result)
        if result and #result > 0 then
            local dbItem = result[1]
            outputDebugString("[DEBUG] Retrieved item from slot " .. slot .. " for character " .. characterID)
            -- Create proper item instance instead of returning raw database record
            local itemInstance = createItemInstance(dbItem.Item, dbItem)
            if callback then callback(itemInstance) end
        else
            outputDebugString("[DEBUG] No item found in slot " .. slot .. " for character " .. characterID)
            if callback then callback(nil) end
        end
    end, characterID, slot)
    
    return true
end

---Set item quantity (overwrite existing quantity)
---@param characterID number The character's ID
---@param itemName string The name of the item
---@param quantity number The new quantity to set
---@param slot number? Optional specific slot number
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.setItemQuantity(characterID, itemName, quantity, slot, callback)
    -- Handle optional parameters
    if type(slot) == "function" then
        callback = slot
        slot = nil
    end
    
    if not characterID or not itemName or not quantity then
        outputDebugString("[ERROR] Invalid parameters for setItemQuantity")
        if callback then callback(false, "Invalid parameters") end
        return false
    end
    
    quantity = math.max(0, tonumber(quantity) or 0)
    
    if quantity == 0 then
        -- Remove item if quantity is 0
        return Inventory.removeItem(characterID, itemName, 999999, callback) -- Large number to ensure complete removal
    end
    
    -- Check if item exists
    local checkQuery = "SELECT ID, Slot FROM player_items WHERE OwnerID = ? AND Item = ?"
    
    Database.queryAsync(checkQuery, function(result)
        if result and #result > 0 then
            -- Update existing item
            local itemSlot = result[1].Slot
            local updateQuery = "UPDATE player_items SET Quantity = ? WHERE ID = ?"
            Database.executeAsync(updateQuery, function(affectedRows)
                if affectedRows > 0 then
                    outputDebugString("[DEBUG] Set quantity of " .. itemName .. " to " .. quantity .. " (Character: " .. characterID .. ")")
                    if callback then callback(true, "Quantity updated", quantity, itemSlot) end
                else
                    outputDebugString("[ERROR] Failed to update item quantity")
                    if callback then callback(false, "Failed to update quantity") end
                end
            end, quantity, result[1].ID)
        else
            -- Create new item
            if slot then
                -- Check if slot is available
                local slotCheckQuery = "SELECT ID FROM player_items WHERE OwnerID = ? AND Slot = ?"
                Database.queryAsync(slotCheckQuery, function(slotResult)
                    if slotResult and #slotResult > 0 then
                        -- Slot taken, find next available
                        Inventory.getNextAvailableSlot(characterID, function(nextSlot)
                            if nextSlot then
                                local insertQuery = "INSERT INTO player_items (OwnerID, Item, Quantity, Slot) VALUES (?, ?, ?, ?)"
                                Database.insertAsync(insertQuery, function(insertID)
                                    if insertID then
                                        outputDebugString("[DEBUG] Created new item " .. itemName .. " with quantity " .. quantity .. " in slot " .. nextSlot .. " (Character: " .. characterID .. ")")
                                        if callback then callback(true, "Item created", quantity, nextSlot, insertID) end
                                    else
                                        outputDebugString("[ERROR] Failed to create item")
                                        if callback then callback(false, "Failed to create item") end
                                    end
                                end, characterID, itemName, quantity, nextSlot)
                            else
                                if callback then callback(false, "Could not find available slot") end
                            end
                        end)
                    else
                        -- Slot available, use it
                        local insertQuery = "INSERT INTO player_items (OwnerID, Item, Quantity, Slot) VALUES (?, ?, ?, ?)"
                        Database.insertAsync(insertQuery, function(insertID)
                            if insertID then
                                outputDebugString("[DEBUG] Created new item " .. itemName .. " with quantity " .. quantity .. " in slot " .. slot .. " (Character: " .. characterID .. ")")
                                if callback then callback(true, "Item created", quantity, slot, insertID) end
                            else
                                outputDebugString("[ERROR] Failed to create item")
                                if callback then callback(false, "Failed to create item") end
                            end
                        end, characterID, itemName, quantity, slot)
                    end
                end, characterID, slot)
            else
                -- Find next available slot
                Inventory.getNextAvailableSlot(characterID, function(nextSlot)
                    if nextSlot then
                        local insertQuery = "INSERT INTO player_items (OwnerID, Item, Quantity, Slot) VALUES (?, ?, ?, ?)"
                        Database.insertAsync(insertQuery, function(insertID)
                            if insertID then
                                outputDebugString("[DEBUG] Created new item " .. itemName .. " with quantity " .. quantity .. " in slot " .. nextSlot .. " (Character: " .. characterID .. ")")
                                if callback then callback(true, "Item created", quantity, nextSlot, insertID) end
                            else
                                outputDebugString("[ERROR] Failed to create item")
                                if callback then callback(false, "Failed to create item") end
                            end
                        end, characterID, itemName, quantity, nextSlot)
                    else
                        if callback then callback(false, "Could not find available slot") end
                    end
                end)
            end
        end
    end, characterID, itemName)
    
    return true
end

---Move item to different slot
---@param characterID number The character's ID
---@param itemName string The name of the item to move
---@param newSlot number The target slot number
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.moveItemToSlot(characterID, itemName, newSlot, callback)
    if not characterID or not itemName or not newSlot then
        outputDebugString("[ERROR] Invalid parameters for moveItemToSlot")
        if callback then callback(false, "Invalid parameters") end
        return false
    end
    
    -- Check if target slot is available
    local slotCheckQuery = "SELECT ID, Item FROM player_items WHERE OwnerID = ? AND Slot = ?"
    
    Database.queryAsync(slotCheckQuery, function(slotResult)
        if slotResult and #slotResult > 0 then
            if callback then callback(false, "Target slot is occupied by " .. slotResult[1].Item) end
        else
            -- Slot is available, update item
            local updateQuery = "UPDATE player_items SET Slot = ? WHERE OwnerID = ? AND Item = ?"
            Database.executeAsync(updateQuery, function(affectedRows)
                if affectedRows > 0 then
                    outputDebugString("[DEBUG] Moved " .. itemName .. " to slot " .. newSlot .. " (Character: " .. characterID .. ")")
                    if callback then callback(true, "Item moved successfully", newSlot) end
                else
                    outputDebugString("[ERROR] Failed to move item or item not found")
                    if callback then callback(false, "Failed to move item") end
                end
            end, newSlot, characterID, itemName)
        end
    end, characterID, newSlot)
    
    return true
end

---Swap items between two slots
---@param characterID number The character's ID
---@param slot1 number The first slot number
---@param slot2 number The second slot number
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.swapItemSlots(characterID, slot1, slot2, callback)
    if not characterID or not slot1 or not slot2 then
        outputDebugString("[ERROR] Invalid parameters for swapItemSlots")
        if callback then callback(false, "Invalid parameters") end
        return false
    end
    
    if slot1 == slot2 then
        if callback then callback(false, "Cannot swap item with itself") end
        return false
    end
    
    -- Get items in both slots
    local getItemsQuery = "SELECT ID, Item, Slot FROM player_items WHERE OwnerID = ? AND (Slot = ? OR Slot = ?) ORDER BY Slot"
    
    Database.queryAsync(getItemsQuery, function(result)
        if result and #result == 2 then
            -- Both slots have items, swap them
            local item1, item2 = result[1], result[2]
            
            -- Temporarily set one item to a high slot number to avoid constraint conflicts
            local tempSlot = 9999
            local updateQuery1 = "UPDATE player_items SET Slot = ? WHERE ID = ?"
            
            Database.executeAsync(updateQuery1, function(affectedRows1)
                if affectedRows1 > 0 then
                    -- Now swap the slots
                    local updateQuery2 = "UPDATE player_items SET Slot = ? WHERE ID = ?"
                    Database.executeAsync(updateQuery2, function(affectedRows2)
                        if affectedRows2 > 0 then
                            local updateQuery3 = "UPDATE player_items SET Slot = ? WHERE ID = ?"
                            Database.executeAsync(updateQuery3, function(affectedRows3)
                                if affectedRows3 > 0 then
                                    outputDebugString("[DEBUG] Swapped items between slots " .. slot1 .. " and " .. slot2 .. " (Character: " .. characterID .. ")")
                                    if callback then callback(true, "Items swapped successfully") end
                                else
                                    if callback then callback(false, "Failed to complete swap") end
                                end
                            end, item1.Slot, item1.ID) -- Put item1 in item2's original slot
                        else
                            if callback then callback(false, "Failed during swap") end
                        end
                    end, item2.Slot, item2.ID) -- Put item2 in item1's original slot
                else
                    if callback then callback(false, "Failed to initiate swap") end
                end
            end, tempSlot, item1.ID)
        elseif result and #result == 1 then
            -- Only one slot has an item, move it to the empty slot
            local item = result[1]
            local targetSlot = (item.Slot == slot1) and slot2 or slot1
            
            local updateQuery = "UPDATE player_items SET Slot = ? WHERE ID = ?"
            Database.executeAsync(updateQuery, function(affectedRows)
                if affectedRows > 0 then
                    outputDebugString("[DEBUG] Moved " .. item.Item .. " from slot " .. item.Slot .. " to slot " .. targetSlot .. " (Character: " .. characterID .. ")")
                    if callback then callback(true, "Item moved successfully") end
                else
                    if callback then callback(false, "Failed to move item") end
                end
            end, targetSlot, item.ID)
        else
            if callback then callback(false, "No items found in specified slots") end
        end
    end, characterID, slot1, slot2)
    
    return true
end

---Clear character's entire inventory
---@param characterID number The character's ID
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.clearCharacterInventory(characterID, callback)
    if not characterID then
        outputDebugString("[ERROR] Invalid characterID for clearCharacterInventory")
        if callback then callback(false, "Invalid parameters") end
        return false
    end
    
    local query = "DELETE FROM player_items WHERE OwnerID = ?"
    
    Database.executeAsync(query, function(affectedRows)
        if affectedRows >= 0 then
            outputDebugString("[DEBUG] Cleared inventory for character " .. characterID .. " (" .. affectedRows .. " items removed)")
            if callback then callback(true, "Inventory cleared", affectedRows) end
        else
            outputDebugString("[ERROR] Failed to clear inventory")
            if callback then callback(false, "Failed to clear inventory") end
        end
    end, characterID)
    
    return true
end

---Check if character has specified item with required quantity
---@param characterID number The character's ID
---@param itemName string The name of the item to check for
---@param requiredQuantity number? The minimum quantity required (default: 1)
---@param callback HasItemCallback Function to call with the result
---@return boolean success True if the operation was initiated successfully
function Inventory.hasItem(characterID, itemName, requiredQuantity, callback)
    if not characterID or not itemName then
        outputDebugString("[ERROR] Invalid parameters for hasItem")
        if callback then callback(false) end
        return false
    end
    
    requiredQuantity = tonumber(requiredQuantity) or 1
    
    Inventory.getCharacterItem(characterID, itemName, function(item)
        if item and item.Quantity >= requiredQuantity then
            if callback then callback(true, item.Quantity) end
        else
            if callback then callback(false, item and item.Quantity or 0) end
        end
    end)
    
    return true
end

-- Convenience functions that work with player elements

---Add item using player element
---@param player userdata The player element
---@param itemName string The name of the item to add
---@param quantity number The quantity to add
---@param slot number? Optional specific slot number
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.addItemToPlayer(player, itemName, quantity, slot, callback)
    local characterID = Inventory.getCharacterID(player)
    if not characterID then
        outputDebugString("[ERROR] Could not get character ID from player element")
        if callback then callback(false, "Invalid character ID") end
        return false
    end
    
    return Inventory.addItem(characterID, itemName, quantity, slot, callback)
end

---Remove item using player element
---@param player userdata The player element
---@param itemName string The name of the item to remove
---@param quantity number The quantity to remove
---@param callback InventoryCallback? Optional callback function
---@return boolean success True if the operation was initiated successfully
function Inventory.removeItemFromPlayer(player, itemName, quantity, callback)
    local characterID = Inventory.getCharacterID(player)
    if not characterID then
        outputDebugString("[ERROR] Could not get character ID from player element")
        if callback then callback(false, "Invalid character ID") end
        return false
    end
    
    return Inventory.removeItem(characterID, itemName, quantity, callback)
end

---Get player inventory using player element
---@param player userdata The player element
---@param callback InventoryListCallback Function to call with the inventory items
---@return boolean success True if the operation was initiated successfully
function Inventory.getPlayerInventory(player, callback)
    local characterID = Inventory.getCharacterID(player)
    if not characterID then
        outputDebugString("[ERROR] Could not get character ID from player element")
        if callback then callback(nil) end
        return false
    end
    
    return Inventory.getCharacterInventory(characterID, callback)
end

function Inventory.updateInventoryGUI(player)
    local characterID = Inventory.getCharacterID(player)
    if not characterID then
        outputDebugString("[ERROR] Could not get character ID from player element")
        return false
    end

    Inventory.getPlayerInventory(player, function(items)
        if items then
            triggerClientEvent(player, EVENTS.INVENTORY.ON_INVENTORY_REFRESH, player, items)
        else
            outputDebugString("[ERROR] Failed to retrieve inventory for GUI update")
        end
    end)
end

---Check if player has item using player element
---@param player userdata The player element
---@param itemName string The name of the item to check for
---@param requiredQuantity number? The minimum quantity required (default: 1)
---@param callback HasItemCallback Function to call with the result
---@return boolean success True if the operation was initiated successfully
function Inventory.playerHasItem(player, itemName, requiredQuantity, callback)
    local characterID = Inventory.getCharacterID(player)
    if not characterID then
        outputDebugString("[ERROR] Could not get character ID from player element")
        if callback then callback(false) end
        return false
    end
    
    return Inventory.hasItem(characterID, itemName, requiredQuantity, callback)
end

-- Initialize inventory system when database connects
addEventHandler(EVENTS.ON_DATABASE_CONNECTED, root, function()
    Inventory.initializeDatabase()
end)