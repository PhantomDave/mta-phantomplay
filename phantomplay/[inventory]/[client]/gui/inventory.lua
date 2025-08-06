
InventoryGUI = {
    gridList = {},
    window = {}
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        InventoryGUI.window.main = GuiWindow(10, 432, 208, 214, "Inventory", false)
        InventoryGUI.window.main:setSizable(false)

        InventoryGUI.gridList.items = GuiGridList(9, 24, 216, 193, false, InventoryGUI.window.main)
        InventoryGUI.gridList.items:addColumn("ID", 0.3)
        InventoryGUI.gridList.items:addColumn("Item", 0.3)
        InventoryGUI.gridList.items:addColumn("Quantity", 0.3)
        for rowIndex = 1, 10 do
            InventoryGUI.gridList.items:addRow()
        end
        for rowIndex = 0, 9 do
            InventoryGUI.gridList.items:setItemText(rowIndex, 1, "-", false, false)
            InventoryGUI.gridList.items:setItemText(rowIndex, 2, "-", false, false)
            InventoryGUI.gridList.items:setItemText(rowIndex, 3, "-", false, false)
        end
    end
)


addEvent(EVENTS.GUI.ON_INVENTORY_TOGGLED, true)
addEventHandler(EVENTS.GUI.ON_INVENTORY_TOGGLED, root,
    function()
        InventoryGUI.window.main:setVisible(not InventoryGUI.window.main:isVisible())
    end
)