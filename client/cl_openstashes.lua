-- Open Stashes Client - NUI Callbacks

RegisterNUICallback("getStashes", function(data, callback)
    local p = promise.new()

    TriggerCallback("snipe-menu:server:getAllStashes", function(result)
        p:resolve(result)
    end)

    local stashes = Citizen.Await(p)
    callback(stashes)
end)

RegisterNUICallback("getAllOwnedVehicles", function(data, callback)
    local p = promise.new()

    TriggerCallback("snipe-menu:server:getAllOwnedVehicles", function(result)
        p:resolve(result)
    end)

    local vehicles = Citizen.Await(p)
    callback(vehicles)
end)

RegisterNUICallback("openStash", function(data, callback)
    if hasAdminPerms then
        TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
        OpenStash(data.selectedValue.name, data.inputValue)
        callback("ok")
        TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", "Opened Stash " .. data.selectedValue.name)
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)

RegisterNUICallback("openTrunk", function(data, callback)
    if hasAdminPerms then
        local plateId = data.selectedPlayer.id
        local plateName = data.selectedPlayer.name

        TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
        OpenTrunk(plateId, plateName)
        TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", "Opened Trunk for plate: " .. plateName)
        callback("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)

RegisterNUICallback("openGlovebox", function(data, callback)
    if hasAdminPerms then
        local plateName = data.selectedPlayer.name

        TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
        OpenGlovebox(plateName)
        TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", "Opened glovebox for plate: " .. plateName)
        callback("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)
