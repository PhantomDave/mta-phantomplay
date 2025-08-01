
bankMoney = 00000000

addEventHandler("onClientRender", root,
    function()
        dxDrawText("$" .. bankMoney, 1499 - 1, 306 - 1, 1824 - 1, 361 - 1, tocolor(0, 0, 0, 255), 2.00, "pricedown", "right", "bottom", false, false, false, false, false)
        dxDrawText("$" .. bankMoney, 1499 + 1, 306 - 1, 1824 + 1, 361 - 1, tocolor(0, 0, 0, 255), 2.00, "pricedown", "right", "bottom", false, false, false, false, false)
        dxDrawText("$" .. bankMoney, 1499 - 1, 306 + 1, 1824 - 1, 361 + 1, tocolor(0, 0, 0, 255), 2.00, "pricedown", "right", "bottom", false, false, false, false, false)
        dxDrawText("$" .. bankMoney, 1499 + 1, 306 + 1, 1824 + 1, 361 + 1, tocolor(0, 0, 0, 255), 2.00, "pricedown", "right", "bottom", false, false, false, false, false)
        dxDrawText("$" .. bankMoney, 1499, 306, 1824, 361, tocolor(55, 147, 55, 255), 2.00, "pricedown", "right", "bottom", false, false, false, false, false)
    end
)



addEvent("updateBankMoney", true)
addEventHandler("updateBankMoney", localPlayer,
    function(newBankMoney)
        bankMoney = newBankMoney
    end
)
