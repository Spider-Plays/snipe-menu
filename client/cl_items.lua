-- Items Management Client - NUI Callbacks

RegisterNUICallback("getAllItems", function(data, callback)
    local items = GetItemsWithNameAndLabel()
    callback(items)
end)

RegisterNUICallback("giveitem", function(data, callback)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        local amount = tonumber(data.amount)
        local itemName = data.selectedItem.id

        TriggerServerEvent("sp-adminmenu:server:giveItem", targetId, itemName, amount)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.give_item_exploit)
    end

    callback("ok")
end)

RegisterNUICallback("giveMoney", function(data, callback)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        local amount = tonumber(data.amount)
        local moneyType = data.selectedItem.id

        TriggerServerEvent("sp-adminmenu:server:giveMoney", targetId, amount, moneyType)
        callback("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.give_money_exploit)
    end
end)
